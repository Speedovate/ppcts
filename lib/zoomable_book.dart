import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

/// Keeps zoom and pointer coordinates inside the reading area. A single input
/// owner avoids competing page-pan and pinch recognizers on the same surface.
class ZoomableBook extends StatefulWidget {
  const ZoomableBook({
    super.key,
    required this.bookSize,
    required this.spread,
    required this.pageCount,
    required this.child,
    this.closedCover = false,
    this.pageTurning = false,
    required this.onPageStart,
    required this.onPageUpdate,
    required this.onPageEnd,
    required this.onPageCancel,
    required this.onZoomChanged,
    this.onVisiblePageChanged,
    this.onBookTap,
  });

  static const padding = EdgeInsets.fromLTRB(16, 12, 16, 16);
  static EdgeInsets paddingForWidth(double width) =>
      width >= 600 ? const EdgeInsets.fromLTRB(16, 24, 16, 28) : padding;

  final Size bookSize;
  final int spread;
  final int pageCount;
  final bool closedCover;
  final bool pageTurning;
  final Widget child;
  final bool Function(DragStartDetails) onPageStart;
  final ValueChanged<DragUpdateDetails> onPageUpdate;
  final ValueChanged<DragEndDetails> onPageEnd;
  final VoidCallback onPageCancel;
  final ValueChanged<double> onZoomChanged;
  final ValueChanged<int?>? onVisiblePageChanged;
  final void Function(Offset pagePosition, Offset globalPosition)? onBookTap;

  @override
  ZoomableBookState createState() => ZoomableBookState();
}

class ZoomableBookState extends State<ZoomableBook>
    with SingleTickerProviderStateMixin {
  final _transform = TransformationController();
  final _pointers = <int, Offset>{};
  late final AnimationController _animation;
  Size _viewport = Size.zero;
  Offset _down = Offset.zero;
  Offset _last = Offset.zero;
  Offset _panOrigin = Offset.zero;
  Offset _doubleTap = Offset.zero;
  Offset _pinchAnchor = Offset.zero;
  Offset _animationFromOffset = Offset.zero;
  Offset _animationToOffset = Offset.zero;
  double _pageFocusX = .5;
  double _pinchDistance = 1;
  double _pinchZoom = 1;
  double _animationFromZoom = 1;
  double _animationToZoom = 1;
  bool _recognized = false;
  bool _turning = false;
  bool _pinching = false;
  VelocityTracker? _velocity;

  double get _zoom => _transform.value.getMaxScaleOnAxis();
  Offset get _offset =>
      Offset(_transform.value.entry(0, 3), _transform.value.entry(1, 3));
  EdgeInsets get _padding => ZoomableBook.paddingForWidth(_viewport.width);
  Size get _frameSize => Size(
    widget.bookSize.width + _padding.horizontal,
    widget.bookSize.height + _padding.vertical,
  );
  Offset get _frameOrigin => Offset(
    (_viewport.width - _frameSize.width) / 2,
    (_viewport.height - _frameSize.height) / 2,
  );
  Offset get _bookOrigin => _frameOrigin + Offset(_padding.left, _padding.top);
  Offset _scene(Offset point) => _transform.toScene(point);
  Offset _pagePoint(Offset point) => _scene(point) - _bookOrigin;

  @override
  void initState() {
    super.initState();
    _animation =
        AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 220),
        )..addListener(() {
          final t = Curves.easeOutCubic.transform(_animation.value);
          _apply(
            _animationFromZoom + (_animationToZoom - _animationFromZoom) * t,
            Offset.lerp(_animationFromOffset, _animationToOffset, t)!,
          );
        });
  }

  bool _positioningWithTurn = false;

  void beginTurnPosition(int direction) {
    if (_viewport.width >= 600 || _zoom <= 1.001) return;
    _animation.stop();
    _positioningWithTurn = true;
    _positionAfterTurn(
      direction > 0,
      destinationSpread: widget.spread + direction,
      animate: false,
    );
  }

  void updateTurnPosition(double progress) {
    if (!_positioningWithTurn) return;
    _apply(
      _animationFromZoom + (_animationToZoom - _animationFromZoom) * progress,
      Offset.lerp(_animationFromOffset, _animationToOffset, progress)!,
    );
  }

  @override
  void didUpdateWidget(covariant ZoomableBook oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.spread != oldWidget.spread) {
      if (_positioningWithTurn) {
        _positioningWithTurn = false;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _reportVisiblePage();
        });
        return;
      }
      final forward = widget.spread > oldWidget.spread;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _positionAfterTurn(forward);
          _reportVisiblePage();
        }
      });
    }
  }

  double get _fitPageZoom => math
      .min(
        _viewport.width / (widget.bookSize.width / 2 + _padding.horizontal),
        _viewport.height / _frameSize.height,
      )
      .clamp(1.0, 8.0);

  /// Consumes navigation when the other page must be shown before turning.
  bool positionBeforeTurn(int direction) {
    if (_viewport.width >= 600) return false;
    if (_animation.isAnimating || _pointers.isNotEmpty) return true;
    if (widget.closedCover || _zoom <= 1.001 || _zoom < _fitPageZoom - .001) {
      return false;
    }
    final forward = direction > 0;
    if (forward && widget.spread * 2 + 2 > widget.pageCount) return false;
    final targetX = forward
        ? _viewport.width - (_frameOrigin.dx + _frameSize.width) * _zoom
        : -_frameOrigin.dx * _zoom;
    if ((_offset.dx - targetX).abs() <= 1 && _zoom <= _fitPageZoom + .001) {
      return false;
    }
    _positionAfterTurn(!forward);
    return true;
  }

  void _positionAfterTurn(
    bool forward, {
    int? destinationSpread,
    bool animate = true,
  }) {
    if (_viewport.width >= 600) return;
    if (_zoom <= 1.001 || (animate && _pointers.isNotEmpty)) return;
    final spread = destinationSpread ?? widget.spread;
    final closed = spread < 0 || spread >= widget.pageCount ~/ 2;
    final targetZoom = math.min(_zoom, _fitPageZoom);
    final focusLeft = forward || spread * 2 + 2 > widget.pageCount;
    // Read forward from the first (left) page of the new spread, and backward
    // from its last (right) page. Closed covers always return to the center.
    _pageFocusX = closed
        ? .5
        : focusLeft
        ? .25
        : .75;
    final center =
        _bookOrigin +
        Offset(
          widget.bookSize.width * _pageFocusX,
          widget.bookSize.height / 2 + (_padding.bottom - _padding.top) / 2,
        );
    final centered =
        Offset(_viewport.width / 2, _viewport.height / 2) - center * targetZoom;
    final double x;
    if (closed || _frameSize.width * targetZoom <= _viewport.width) {
      x = centered.dx;
    } else {
      x = focusLeft
          ? -_frameOrigin.dx * targetZoom
          : _viewport.width - (_frameOrigin.dx + _frameSize.width) * targetZoom;
    }
    _animationFromZoom = _zoom;
    _animationToZoom = targetZoom;
    _animationFromOffset = _offset;
    _animationToOffset = _boundedOffset(
      targetZoom,
      Offset(x, closed ? centered.dy : _offset.dy),
      closedCover: closed,
    );
    if (animate) _animation.forward(from: 0);
  }

  @override
  void dispose() {
    _animation.dispose();
    _transform.dispose();
    super.dispose();
  }

  Offset _boundedOffset(double zoom, Offset desired, {bool? closedCover}) {
    if ((closedCover ?? widget.closedCover) && zoom <= _fitPageZoom + .001) {
      final center =
          _frameOrigin + Offset(_frameSize.width / 2, _frameSize.height / 2);
      return Offset(_viewport.width / 2, _viewport.height / 2) - center * zoom;
    }
    double bound(
      double value,
      double viewport,
      double origin,
      double extent, [
      double focus = .5,
    ]) {
      if (extent * zoom <= viewport) {
        final centered = viewport / 2 - (origin + extent / 2) * zoom;
        final focused = viewport / 2 - (origin + extent * focus) * zoom;
        return value.clamp(
          math.min(centered, focused),
          math.max(centered, focused),
        );
      }
      final focused = viewport / 2 - (origin + extent * focus) * zoom;
      return value.clamp(
        math.min(viewport - (origin + extent) * zoom, focused),
        math.max(-origin * zoom, focused),
      );
    }

    return Offset(
      bound(
        desired.dx,
        _viewport.width,
        _frameOrigin.dx,
        _frameSize.width,
        (_padding.left + widget.bookSize.width * _pageFocusX) /
            _frameSize.width,
      ),
      bound(desired.dy, _viewport.height, _frameOrigin.dy, _frameSize.height),
    );
  }

  void _reportVisiblePage() {
    if (_positioningWithTurn) return;
    int? page;
    if (!widget.closedCover && _zoom > 1.001 && _zoom >= _fitPageZoom - .001) {
      final center = _pagePoint(
        Offset(_viewport.width / 2, _viewport.height / 2),
      );
      page =
          widget.spread * 2 + (center.dx < widget.bookSize.width / 2 ? 1 : 2);
    }
    widget.onVisiblePageChanged?.call(
      page == null ? null : math.min(page, widget.pageCount),
    );
  }

  void _apply(double requestedZoom, Offset desired) {
    final zoom = requestedZoom.clamp(1.0, 8.0);
    final offset = _positioningWithTurn
        ? desired
        : _boundedOffset(zoom, desired);
    if ((_zoom - zoom).abs() < .00001 && (_offset - offset).distance < .00001) {
      _reportVisiblePage();
      return;
    }
    _transform.value = Matrix4.identity()
      ..setEntry(0, 0, zoom)
      ..setEntry(1, 1, zoom)
      ..setEntry(0, 3, offset.dx)
      ..setEntry(1, 3, offset.dy);
    widget.onZoomChanged(zoom);
    _reportVisiblePage();
  }

  void _toggleZoom() {
    if (_turning || _pointers.length > 1) return;
    final reset = _zoom > 1.05;
    final target = reset ? 1.0 : _fitPageZoom;
    _pageFocusX = reset || widget.closedCover
        ? .5
        : _pagePoint(_doubleTap).dx < widget.bookSize.width / 2
        ? .25
        : .75;
    final pageCenter =
        _bookOrigin +
        Offset(
          widget.bookSize.width * _pageFocusX,
          widget.bookSize.height / 2 + (_padding.bottom - _padding.top) / 2,
        );
    _animationFromZoom = _zoom;
    _animationFromOffset = _offset;
    _animationToZoom = target;
    _animationToOffset = _boundedOffset(
      target,
      Offset(_viewport.width / 2, _viewport.height / 2) - pageCenter * target,
    );
    _animation.forward(from: 0);
  }

  void _startPinch() {
    if (_turning) {
      widget.onPageCancel();
      _turning = false;
    }
    _pinching = true;
    _pageFocusX = .5;
    final points = _pointers.values.take(2).toList();
    _pinchDistance = math.max(1, (points[0] - points[1]).distance);
    _pinchZoom = _zoom;
    _pinchAnchor = _scene((points[0] + points[1]) / 2);
  }

  double _trackpadZoom = 1;
  Offset _trackpadAnchor = Offset.zero;

  void _prepareDeviceZoom() {
    _animation.stop();
    if (_turning) {
      widget.onPageCancel();
      _turning = false;
    }
    _pageFocusX = .5;
  }

  void _pointerSignal(PointerSignalEvent event) {
    if (_positioningWithTurn) return;
    if (event is! PointerScrollEvent && event is! PointerScaleEvent) return;
    GestureBinding.instance.pointerSignalResolver.register(event, (signal) {
      _prepareDeviceZoom();
      final anchor = _scene(signal.localPosition);
      final factor = signal is PointerScaleEvent
          ? signal.scale
          : math.exp(-(signal as PointerScrollEvent).scrollDelta.dy / 300);
      final target = (_zoom * factor).clamp(1.0, 8.0);
      _apply(target, signal.localPosition - anchor * target);
    });
  }

  void _panZoomStart(PointerPanZoomStartEvent event) {
    if (_positioningWithTurn) return;
    _prepareDeviceZoom();
    _trackpadZoom = _zoom;
    _trackpadAnchor = _scene(event.localPosition);
  }

  void _panZoomUpdate(PointerPanZoomUpdateEvent event) {
    if (_positioningWithTurn) return;
    final target = (_trackpadZoom * event.scale).clamp(1.0, 8.0);
    _apply(
      target,
      event.localPosition + event.localPan - _trackpadAnchor * target,
    );
  }

  void _pointerDown(PointerDownEvent event) {
    if (_positioningWithTurn) return;
    if (event.kind == PointerDeviceKind.mouse &&
        event.buttons != kPrimaryMouseButton) {
      return;
    }
    _animation.stop();
    _pointers[event.pointer] = event.localPosition;
    if (_pointers.length == 1) {
      _down = _last = event.localPosition;
      _panOrigin = _offset;
      _recognized = _turning = _pinching = false;
      _velocity = VelocityTracker.withKind(event.kind)
        ..addPosition(event.timeStamp, event.localPosition);
    } else {
      _startPinch();
    }
  }

  void _pointerMove(PointerMoveEvent event) {
    if (!_pointers.containsKey(event.pointer)) return;
    _pointers[event.pointer] = event.localPosition;
    if (_pointers.length >= 2) {
      final points = _pointers.values.take(2).toList();
      final zoom =
          (_pinchZoom * (points[0] - points[1]).distance / _pinchDistance)
              .clamp(1.0, 8.0);
      _apply(zoom, (points[0] + points[1]) / 2 - _pinchAnchor * zoom);
      return;
    }
    if (_pinching) {
      // A remaining finger may pan, but cannot accidentally begin a page turn.
      _apply(_zoom, _offset + event.localPosition - _last);
      _last = event.localPosition;
      return;
    }
    _velocity?.addPosition(event.timeStamp, event.localPosition);
    if (!_recognized) {
      final slop = event.kind == PointerDeviceKind.mouse ? 4.0 : kTouchSlop;
      if ((event.localPosition - _down).distance <= slop) return;
      _recognized = true;
      _turning = widget.onPageStart(
        DragStartDetails(
          localPosition: _pagePoint(_down),
          globalPosition: event.position - event.localPosition + _down,
          kind: event.kind,
        ),
      );
    }
    if (_turning) {
      widget.onPageUpdate(
        DragUpdateDetails(
          localPosition: _pagePoint(event.localPosition),
          globalPosition: event.position,
          delta: event.localDelta / _zoom,
        ),
      );
    } else {
      _apply(_zoom, _panOrigin + event.localPosition - _down);
    }
    _last = event.localPosition;
  }

  void _pointerUp(PointerUpEvent event) {
    if (_pointers.remove(event.pointer) == null) return;
    if (_pointers.length >= 2) {
      _startPinch();
    } else if (_pointers.isNotEmpty) {
      _last = _pointers.values.first;
    } else {
      if (_turning) {
        _velocity?.addPosition(event.timeStamp, event.localPosition);
        widget.onPageEnd(
          DragEndDetails(
            velocity: Velocity(
              pixelsPerSecond:
                  (_velocity?.getVelocity().pixelsPerSecond ?? Offset.zero) /
                  _zoom,
            ),
          ),
        );
      }
      _turning = _recognized = _pinching = false;
      _velocity = null;
    }
  }

  void _pointerCancel(PointerCancelEvent event) {
    if (!_pointers.containsKey(event.pointer)) return;
    if (_turning) widget.onPageCancel();
    _pointers.clear();
    _turning = _recognized = _pinching = false;
    _velocity = null;
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final size = constraints.biggest;
      if (_viewport != size) {
        _positioningWithTurn = false;
        // Coordinates and animation targets belong to the previous viewport.
        // Refit on resize instead of carrying a desktop pan into mobile layout.
        _animation.stop();
        final cancelTurn = _turning;
        _pointers.clear();
        _turning = _recognized = _pinching = false;
        _velocity = null;
        _pageFocusX = .5;
        _viewport = size;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted || _viewport != size) return;
          if (cancelTurn) widget.onPageCancel();
          final target = size.width < 600 ? _fitPageZoom : 1.0;
          final center =
              _frameOrigin +
              Offset(_frameSize.width / 2, _frameSize.height / 2);
          _apply(
            target,
            Offset(size.width / 2, size.height / 2) - center * target,
          );
          if (!widget.closedCover && target > 1.001) _positionAfterTurn(true);
        });
      }
      return ClipRect(
        key: const Key('book-viewport'),
        clipBehavior: widget.pageTurning ? Clip.none : Clip.hardEdge,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onDoubleTapDown: size.width < 600
              ? (details) => _doubleTap = details.localPosition
              : null,
          onDoubleTap: size.width < 600 ? _toggleZoom : null,
          onTapUp: (details) {
            if (!_positioningWithTurn && !_turning && !_animation.isAnimating) {
              widget.onBookTap?.call(
                _pagePoint(details.localPosition),
                details.globalPosition,
              );
            }
          },
          child: Listener(
            behavior: HitTestBehavior.opaque,
            onPointerDown: _pointerDown,
            onPointerMove: _pointerMove,
            onPointerUp: _pointerUp,
            onPointerCancel: _pointerCancel,
            onPointerSignal: _pointerSignal,
            onPointerPanZoomStart: _panZoomStart,
            onPointerPanZoomUpdate: _panZoomUpdate,
            child: ValueListenableBuilder<Matrix4>(
              valueListenable: _transform,
              child: Center(
                child: Padding(
                  key: const Key('book-padding'),
                  padding: _padding,
                  child: SizedBox(
                    key: const Key('book'),
                    width: widget.bookSize.width,
                    height: widget.bookSize.height,
                    child: widget.child,
                  ),
                ),
              ),
              builder: (context, transform, child) => Transform(
                key: const Key('book-transform'),
                transform: transform,
                child: child,
              ),
            ),
          ),
        ),
      );
    },
  );
}
