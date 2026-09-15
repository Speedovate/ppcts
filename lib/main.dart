import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'zoomable_book.dart';
import 'program_layout.dart';
import 'sponsor_content.dart';
import 'speaker_photos.dart';
import 'package:url_launcher/url_launcher.dart';
export 'program_layout.dart'
    show
        programPageCount,
        programSpreadCount,
        programFaceCount,
        programClosingSpread;
import 'package:flutter/services.dart';

void main() => runApp(const MyApp());

const ink = Color(0xFF132051);
const paper = Color(0xFFFFFFFF);
const royalBlue = Color(0xFF0845B5);
const gold = Color(0xFFE4AA19);

Offset constrainPageDrag(Offset point, Offset corner) {
  // The grabbed corner cannot stretch farther from either spine endpoint
  // than the original sheet allows. This keeps the fold off the bound edge.
  final nearSpine = Offset(0, corner.dy);
  final farSpine = Offset(0, BookPainter.h - corner.dy);
  Offset insideCircle(Offset p, Offset center, double radius) {
    final delta = p - center;
    return delta.distance > radius
        ? center + delta * (radius / delta.distance)
        : p;
  }

  // Project onto the larger circle first. The near endpoint lies inside it,
  // so the second projection preserves both distance constraints.
  final bounded = insideCircle(point, farSpine, (corner - farSpine).distance);
  return insideCircle(bounded, nearSpine, BookPainter.w);
}

class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
    this.animateSponsors = true,
    this.animateLoading = true,
  });
  final bool animateSponsors;
  final bool animateLoading;
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'PPC Tourism Summit 2026',
    debugShowCheckedModeBanner: false,
    builder: (context, child) => AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Color(0xFFD6F0FA),
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: Color(0xFFD6F0FA),
        systemNavigationBarIconBrightness: Brightness.dark,
        systemNavigationBarDividerColor: Color(0xFFD6F0FA),
      ),
      child: child!,
    ),
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: royalBlue,
        primary: royalBlue,
        surface: paper,
      ),
      useMaterial3: true,
    ),
    home: Flipbook(
      animateSponsors: animateSponsors,
      animateLoading: animateLoading,
    ),
  );
}

class Flipbook extends StatefulWidget {
  const Flipbook({
    super.key,
    this.animateSponsors = true,
    this.animateLoading = true,
  });
  final bool animateSponsors;
  final bool animateLoading;
  @override
  State<Flipbook> createState() => _FlipbookState();
}

class _FlipbookState extends State<Flipbook> with TickerProviderStateMixin {
  int get spreads => programSpreadCount;
  late final AnimationController _animation;
  late final AnimationController _sponsorPulse;
  late final AnimationController _loadingAnimation;
  int _spread = -1;
  int? _visiblePage;
  final _expandedSponsors = <int>{};
  int _direction = 0;
  Offset _corner = const Offset(510, 660);
  final _dragPosition = ValueNotifier<Offset>(const Offset(510, 660));
  final _pageCache = PageRasterCache();
  final _zoomableBookKey = GlobalKey<ZoomableBookState>();
  Offset get _drag => _dragPosition.value;
  set _drag(Offset value) => _dragPosition.value = value;
  Offset _start = Offset.zero;
  Offset _from = Offset.zero;
  Offset _to = Offset.zero;
  double _scale = 1;
  bool _commit = false;

  @override
  void initState() {
    super.initState();
    _loadingAnimation = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    if (widget.animateLoading) _loadingAnimation.repeat();
    _pageCache.addListener(_syncLoadingAnimation);
    _sponsorPulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );
    _animation =
        AnimationController(
            vsync: this,
            duration: const Duration(milliseconds: 650),
          )
          ..addListener(() {
            _zoomableBookKey.currentState?.updateTurnPosition(
              Curves.easeInOutCubic.transform(_animation.value),
            );
            _drag = Offset.lerp(
              _from,
              _to,
              Curves.easeInOutCubic.transform(_animation.value),
            )!;
          })
          ..addStatusListener((status) {
            if (status == AnimationStatus.completed) {
              setState(() {
                if (_commit) _spread += _direction;
                _direction = 0;
              });
            }
          });
  }

  @override
  void dispose() {
    _pageCache.removeListener(_syncLoadingAnimation);
    _loadingAnimation.dispose();
    _sponsorPulse.dispose();
    _animation.dispose();
    _dragPosition.dispose();
    _pageCache.dispose();
    super.dispose();
  }

  void _syncLoadingAnimation() {
    if (_pageCache.allFacesReady) _loadingAnimation.stop();
  }

  Future<void> _sponsorTap(Offset position, Offset globalPosition) async {
    if (_spread < 0 || _spread * 2 >= sponsorPageCount || _direction != 0) {
      return;
    }
    final point = position / _scale;
    final side = point.dx < 510 ? 0 : 1;
    final pageIndex = _spread * 2 + side;
    if (pageIndex != 3) return;
    final local = Offset(point.dx - side * 510, point.dy);
    final index = sponsors.indexWhere(
      (sponsor) => sponsor.interactive && sponsor.cardBounds.contains(local),
    );
    if (index < 0) return;
    final expanded = _expandedSponsors.contains(index);
    final sponsor = sponsors[index];
    if (!sponsor.interactive) return;
    if (expanded &&
        sponsor.videoUrl != null &&
        sponsor.playButtonBounds.contains(local)) {
      var opened = false;
      try {
        opened = await launchUrl(
          Uri.parse(sponsor.videoUrl!),
          webOnlyWindowName: '_blank',
        );
      } catch (_) {
        opened = false;
      }
      if (!opened && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not open the video. Please try again.'),
          ),
        );
      }
      return;
    }
    final logo = expanded
        ? sponsors[index].expandedLogoBounds
        : sponsor.collapsedLogoBounds;
    if (logo.contains(local)) {
      setState(() {
        if (expanded) {
          _expandedSponsors.remove(index);
        } else {
          _expandedSponsors.add(index);
        }
      });
      return;
    }
    if (!expanded || !sponsors[index].contactBounds.contains(local)) return;
    final row = ((local.dy - sponsors[index].contactBounds.top) / 18).floor();
    if (row < 0 || row >= sponsor.contacts.length) return;
    final contact = sponsors[index].contacts[row];
    final overlay =
        Overlay.of(context).context.findRenderObject()! as RenderBox;
    final at = overlay.globalToLocal(globalPosition);
    final selected = await showMenu<String>(
      context: context,
      color: Colors.white,
      surfaceTintColor: Colors.transparent,
      menuPadding: EdgeInsets.zero,
      position: RelativeRect.fromRect(
        at & const Size(1, 1),
        Offset.zero & overlay.size,
      ),
      items: [
        const PopupMenuItem(value: 'copy', child: Text('Copy')),
        PopupMenuItem<String>(
          value: 'open',
          enabled: contact.url != null,
          child: Text(
            contact.url == null
                ? '${contact.action} (placeholder)'
                : contact.action,
          ),
        ),
      ],
    );
    if (selected == 'open' && contact.url != null) {
      var opened = false;
      try {
        opened = await launchUrl(
          Uri.parse(contact.url!),
          webOnlyWindowName: '_blank',
        );
      } catch (_) {
        opened = false;
      }
      if (!opened && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Could not open ${contact.value}. You can copy it instead.',
            ),
          ),
        );
      }
    }
    if (selected == 'copy') {
      await Clipboard.setData(ClipboardData(text: contact.value));
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Copied')));
      }
    }
  }

  bool _canTurn(int direction) =>
      direction > 0 ? _spread < programClosingSpread : _spread >= 0;

  @override
  void reassemble() {
    super.reassemble();
    _pageCache.invalidateSponsorDetails();
  }

  void _settle(bool commit) {
    _commit = commit;
    _from = _drag;
    _to = Offset(commit ? -510 : 510, _corner.dy);
    if (commit) _zoomableBookKey.currentState?.beginTurnPosition(_direction);
    _animation.forward(from: 0);
  }

  void _turn(int direction) {
    if (_direction != 0 || !_canTurn(direction)) return;
    if (_zoomableBookKey.currentState?.positionBeforeTurn(direction) ?? false) {
      return;
    }
    setState(() {
      _direction = direction;
      _corner = const Offset(510, 660);
      _drag = const Offset(505, 650);
    });
    _settle(true);
  }

  bool _begin(DragStartDetails details) {
    if (_direction != 0) return false;
    final p = details.localPosition / _scale;
    // Keep the grab target usable on phones, without swallowing the page body.
    final edgeWidth = math.min(225.0, math.max(85.0, 44 / _scale));
    final direction = p.dx > 510 ? 1 : -1;
    if (p.dy < 0 || p.dy > 660 || p.dx < 0 || p.dx > 1020) return false;
    if (_spread == -1 && (p.dx < 765 - edgeWidth || p.dx > 765)) return false;
    if (_spread == programClosingSpread &&
        (p.dx < 255 || p.dx > 255 + edgeWidth)) {
      return false;
    }
    if ((_spread >= 0 &&
            _spread < programClosingSpread &&
            p.dx > edgeWidth &&
            p.dx < 1020 - edgeWidth) ||
        !_canTurn(direction)) {
      return false;
    }
    setState(() {
      _direction = direction;
      _start = p;
      _corner = Offset(510, p.dy < 330 ? 0 : 660);
      _drag = _corner - const Offset(0.1, 0);
    });
    return true;
  }

  void _move(DragUpdateDetails details) {
    if (_direction == 0 || _animation.isAnimating) return;
    final delta = details.localPosition / _scale - _start;
    _drag = constrainPageDrag(
      Offset(510 + delta.dx * _direction, _corner.dy + delta.dy),
      _corner,
    );
  }

  Widget _navigationButton(int direction) {
    final enabled = _direction == 0 && _canTurn(direction);
    return SizedBox(
      key: Key(direction > 0 ? 'next-button-slot' : 'previous-button-slot'),
      width: 48,
      height: 48,
      child: IconButton(
        style: IconButton.styleFrom(
          backgroundColor: ink,
          disabledBackgroundColor: _canTurn(direction)
              ? ink
              : ink.withValues(alpha: 0.1),
          foregroundColor: paper,
          disabledForegroundColor: paper,
          shape: const CircleBorder(),
        ),
        onPressed: enabled ? () => _turn(direction) : null,
        tooltip: enabled
            ? (direction > 0 ? 'Next pages' : 'Previous pages')
            : null,
        icon: Icon(
          direction > 0 ? Icons.arrow_forward : Icons.arrow_back,
          size: 19,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final animate =
        widget.animateSponsors &&
        _spread >= 0 &&
        _spread * 2 < sponsorPageCount &&
        _direction == 0 &&
        !MediaQuery.disableAnimationsOf(context);
    if (animate && !_sponsorPulse.isAnimating) {
      _sponsorPulse.repeat();
    } else if (!animate && _sponsorPulse.isAnimating) {
      _sponsorPulse.stop();
    }
    return Scaffold(
      backgroundColor: const Color(0xFFD6F0FA),
      body: SafeArea(
        child: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFD6F0FA), Color(0xFF8BC8FA), Color(0xFFD6F0FA)],
            ),
          ),
          child: CallbackShortcuts(
            bindings: {
              const SingleActivator(LogicalKeyboardKey.arrowRight): () =>
                  _turn(1),
              const SingleActivator(LogicalKeyboardKey.arrowLeft): () =>
                  _turn(-1),
            },
            child: Focus(
              autofocus: true,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(28, 28, 28, 8),
                    child: Row(
                      children: [
                        Image.asset(
                          'assets/images/ctc.png',
                          key: const Key('ctc-logo'),
                          height: 40,
                          fit: BoxFit.contain,
                          semanticLabel: 'City Tourism Council Puerto Princesa',
                        ),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'CITY TOURISM COUNCIL',
                                  style: TextStyle(
                                    color: ink,
                                    fontSize: 14,
                                    height: 1,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                Text(
                                  'Puerto Princesa',
                                  style: TextStyle(
                                    color: ink,
                                    fontSize: 15,
                                    height: 1,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Image.asset(
                          'assets/images/ltp.png',
                          height: 32,
                          fit: BoxFit.contain,
                          semanticLabel: 'Love the Philippines',
                        ),
                      ],
                    ),
                  ),

                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final bookPadding = ZoomableBook.paddingForWidth(
                          constraints.maxWidth,
                        );
                        _scale = math
                            .min(
                              (constraints.maxWidth - bookPadding.horizontal) /
                                  1020,
                              (constraints.maxHeight - bookPadding.vertical) /
                                  660,
                            )
                            .clamp(0.05, 1.2);
                        _pageCache.warm(
                          _scale * MediaQuery.devicePixelRatioOf(context),
                        );
                        return ZoomableBook(
                          key: _zoomableBookKey,
                          spread: _spread,
                          pageCount: programPageCount,
                          pageTurning: _direction != 0,
                          closedCover:
                              _spread == -1 || _spread == programClosingSpread,
                          bookSize: Size(1020 * _scale, 660 * _scale),
                          onPageStart: _begin,
                          onPageUpdate: _move,
                          onPageEnd: (details) {
                            if (_direction != 0 && !_animation.isAnimating) {
                              final velocity =
                                  details.velocity.pixelsPerSecond.dx *
                                  _direction;
                              _settle(
                                velocity < -450 ||
                                    (velocity < 450 && _drag.dx < 120),
                              );
                            }
                          },
                          onPageCancel: () {
                            if (_direction != 0 && !_animation.isAnimating) {
                              _settle(false);
                            }
                          },
                          onBookTap: _sponsorTap,
                          onVisiblePageChanged: (page) {
                            if (_visiblePage != page) {
                              setState(() => _visiblePage = page);
                            }
                          },
                          onZoomChanged: (zoom) => _pageCache.warm(
                            _scale *
                                MediaQuery.devicePixelRatioOf(context) *
                                zoom,
                          ),
                          child: Semantics(
                            label: _spread == -1
                                ? 'Closed book. Puerto Princesa Tourism Summit 2026 front cover. Drag the right edge to open.'
                                : _spread == spreads
                                ? 'Closed book. Puerto Princesa Tourism Summit 2026 back cover. Drag the left edge to reopen.'
                                : _spread == programClosingSpread
                                ? 'Closed book, page $programPageCount. Drag the left edge to reopen.'
                                : 'Open book, pages ${_spread * 2 + 1} and ${math.min(_spread * 2 + 2, programPageCount)}. Drag an outer edge to turn a page.',
                            child: MouseRegion(
                              cursor: _direction == 0
                                  ? SystemMouseCursors.grab
                                  : SystemMouseCursors.grabbing,
                              child: RepaintBoundary(
                                child: CustomPaint(
                                  size: Size(1020 * _scale, 660 * _scale),
                                  painter: BookPainter(
                                    spread: _spread,
                                    direction: _direction,
                                    corner: _corner,
                                    drag: _drag,
                                    dragPosition: _dragPosition,
                                    cache: _pageCache,
                                    sponsorPulse: _sponsorPulse,
                                    loadingAnimation: _loadingAnimation,
                                    expandedSponsors: Set.of(_expandedSponsors),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _navigationButton(-1),
                      const SizedBox(width: 12),
                      Flexible(
                        child: SizedBox(
                          width: 180,
                          height: 24,
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              _spread == -1
                                  ? 'Front Cover'
                                  : _spread == spreads
                                  ? 'Back Cover'
                                  : _visiblePage != null
                                  ? 'Page $_visiblePage out of $programPageCount'
                                  : _spread * 2 + 2 > programPageCount
                                  ? 'Page ${_spread * 2 + 1} out of $programPageCount'
                                  : 'Pages ${_spread * 2 + 1} - ${_spread * 2 + 2} out of $programPageCount',
                              style: const TextStyle(
                                color: ink,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 2,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      _navigationButton(1),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Owns the paginated program and cover faces. Raster work happens once, outside drag frames.
/// Resolution is bucketed and capped at 2x.
class PageRasterCache extends ChangeNotifier {
  PageRasterCache({AssetBundle? assetBundle})
    : _assetBundle = assetBundle ?? rootBundle;
  final AssetBundle _assetBundle;
  final _pictures = <int, ui.Picture>{};
  final _images = <int, ui.Image>{};
  final _imagePaint = Paint()..filterQuality = FilterQuality.low;
  Future<void>? _pending;
  Future<void>? _coverLoading;
  Future<void>? _backCoverLoading;
  Future<void>? _pageAssetsLoading;
  Future<void>? _speakerPhotosLoading;
  ui.Image? _coverImage;
  ui.Image? _backCoverImage;
  ui.Image? _brandingImage;
  final _pageLogos = <ui.Image>[];
  final _sponsors = <ui.Image>[];
  final _speakerImages = <String, ui.Image>{};
  final _sponsorDetails = <int, ui.Picture>{};
  double _targetRatio = 0;
  int _generation = 0;
  bool _disposed = false;

  @visibleForTesting
  int get recordedFaces => _pictures.length;
  @visibleForTesting
  int get rasterizedFaces => _images.length;

  bool get allFacesReady => _images.length == programFaceCount + 2;

  ui.Picture _picture(int index) => _pictures.putIfAbsent(index, () {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final renderer = BookPainter(
      coverImage: _coverImage,
      backCoverImage: _backCoverImage,
      brandingImage: _brandingImage,
      pageLogos: _pageLogos,
      speakerImages: _speakerImages,
      spread: 0,
      direction: 0,
      corner: const Offset(510, 660),
      drag: const Offset(510, 660),
    );
    if (index == -1 || index == programFaceCount) {
      renderer.cover(canvas, back: index == programFaceCount);
    } else {
      renderer.page(canvas, index);
    }
    return recorder.endRecording();
  });

  void draw(Canvas canvas, int index, {double loadingProgress = 0}) {
    final image = _images[index];
    if (image == null) {
      final isCover = index == -1 || index == programFaceCount;
      canvas.drawRect(
        const Rect.fromLTWH(0, 0, BookPainter.w, BookPainter.h),
        Paint()..color = isCover ? ink : paper,
      );
      final color = isCover ? Colors.white : ink;
      final stroke = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round
        ..color = color.withValues(alpha: .15);
      const center = Offset(BookPainter.w / 2, BookPainter.h / 2);
      canvas.drawCircle(center, 18, stroke);
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: 18),
        loadingProgress * math.pi * 2 - math.pi / 2,
        math.pi * 1.4,
        false,
        stroke..color = color,
      );
    } else {
      canvas.drawImageRect(
        image,
        Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
        const Rect.fromLTWH(0, 0, BookPainter.w, BookPainter.h),
        _imagePaint,
      );
    }
  }

  void drawSponsor(
    Canvas canvas,
    int index,
    double progress, {
    bool expanded = false,
    bool supportedExpanded = false,
  }) {
    if (index < 0 ||
        index >= sponsors.length ||
        index >= _sponsors.length ||
        !_images.containsKey(index < 3 ? index : 3)) {
      return;
    }
    if (index == 3 || index == 4) {
      _paintSponsorLabel(
        canvas,
        sponsors[index].heading,
        index == 4 ? 388 : sponsors[index].cardBounds.top,
        index == 4
            ? const Rect.fromLTWH(24, 388, 462, 222)
            : sponsors[index].cardBounds,
        12,
        bold: index == 4 ? !supportedExpanded : !expanded,
      );
    }
    final image = _sponsors[index];
    final pulse = sponsors[index].interactive
        ? (1 - math.cos(progress * math.pi * 2)) / 2
        : 0.0;
    final info = sponsors[index];
    final baseBounds = index < 3
        ? const Rect.fromLTWH(115, 250, 280, 280)
        : expanded
        ? info.expandedLogoBounds
        : info.collapsedLogoBounds;
    final size = baseBounds.width * (1 + .035 * pulse);
    final bounds = Rect.fromCenter(
      center: baseBounds.center,
      width: size,
      height: size,
    );
    canvas.save();
    canvas.clipRRect(
      RRect.fromRectAndRadius(bounds, const Radius.circular(16)),
    );
    canvas.drawImageRect(
      image,
      Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
      bounds,
      Paint()..filterQuality = FilterQuality.medium,
    );
    canvas.restore();
    if (expanded) {
      canvas.drawPicture(
        _sponsorDetails.putIfAbsent(index, () => _recordSponsorDetails(index)),
      );
      if (sponsors[index].videoUrl != null) {
        final bounds = sponsors[index].playButtonBounds;
        canvas.save();
        canvas.translate(bounds.center.dx, bounds.center.dy);
        canvas.scale(1 + .08 * pulse);
        canvas.translate(-bounds.center.dx, -bounds.center.dy);
        canvas.drawCircle(
          bounds.center,
          bounds.width / 2,
          Paint()..color = ink,
        );
        final triangle = Path()
          ..moveTo(bounds.center.dx - 3.5, bounds.center.dy - 6)
          ..lineTo(bounds.center.dx + 6, bounds.center.dy)
          ..lineTo(bounds.center.dx - 3.5, bounds.center.dy + 6)
          ..close();
        canvas.drawPath(triangle, Paint()..color = paper);
        canvas.restore();
      }
    }
  }

  void invalidateSponsorDetails() {
    for (final picture in _sponsorDetails.values) {
      picture.dispose();
    }
    _sponsorDetails.clear();
    notifyListeners();
  }

  void _paintSponsorLabel(
    Canvas canvas,
    String text,
    double y,
    Rect card,
    double size, {
    bool bold = false,
    Color color = ink,
    bool singleLine = false,
  }) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: size,
          fontFamily: 'sans-serif',
          fontWeight: bold ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    )..layout(maxWidth: singleLine ? double.infinity : card.width);
    final scale = math.min(1.0, card.width / math.max(1.0, painter.width));
    canvas.save();
    canvas.translate(card.center.dx - painter.width * scale / 2, y);
    canvas.scale(scale);
    painter.paint(canvas, Offset.zero);
    canvas.restore();
    painter.dispose();
  }

  ui.Picture _recordSponsorDetails(int index) {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final info = sponsors[index];
    final card = info.cardBounds;
    _paintSponsorLabel(
      canvas,
      info.name.toUpperCase(),
      card.top + 16,
      card,
      11,
      bold: true,
    );
    for (var i = 0; i < info.contacts.length; i++) {
      final contact = info.contacts[i];
      final y = info.contactBounds.top + i * 18;
      _paintSponsorLabel(
        canvas,
        contact.value,
        y + 1,
        card,
        10,
        singleLine: true,
        color: const Color(0xFF007BFF),
      );
    }
    return recorder.endRecording();
  }

  Future<void> warm(double pixelRatio) {
    if (_disposed) return Future.value();
    final ratio = ((pixelRatio * 2).ceil() / 2).clamp(1.0, 2.0);
    if (ratio <= _targetRatio) return _pending ?? Future.value();
    _targetRatio = ratio;
    return _pending = _rasterize(ratio, ++_generation);
  }

  Future<void> _loadCover({bool back = false}) async {
    if (_disposed) return;
    final data = await _assetBundle.load(
      back ? 'assets/images/back_cover.jpg' : 'assets/images/front_cover.jpg',
    );
    final codec = await ui.instantiateImageCodec(
      data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
      targetHeight: (BookPainter.h * 2).round(),
    );
    try {
      final frame = await codec.getNextFrame();
      if (_disposed) {
        frame.image.dispose();
      } else {
        if (back) {
          _backCoverImage = frame.image;
        } else {
          _coverImage = frame.image;
        }
        _pictures.remove(back ? programFaceCount : -1)?.dispose();
      }
    } finally {
      codec.dispose();
    }
  }

  Future<void> _loadBranding() async {
    if (_disposed) return;
    final data = await _assetBundle.load('assets/images/summit_branding.png');
    final codec = await ui.instantiateImageCodec(
      data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
      targetWidth: 720,
    );
    try {
      final frame = await codec.getNextFrame();
      if (_disposed) {
        frame.image.dispose();
      } else {
        _brandingImage = frame.image;
        for (final index
            in _pictures.keys
                .where((index) => index >= 0 && index < programFaceCount)
                .toList()) {
          _pictures.remove(index)?.dispose();
        }
      }
    } finally {
      codec.dispose();
    }
  }

  Future<void> _loadPageLogos() async {
    final assets = [
      'ctc_logo.png',
      'ppc_logo.png',
      'ct_logo.png',
      ...sponsors.map((sponsor) => sponsor.logoAsset),
    ];
    for (var index = 0; index < assets.length; index++) {
      final name = assets[index];
      if (_disposed) return;
      final isSponsor = index >= 3;
      final data = await _assetBundle.load('assets/images/$name');
      final codec = await ui.instantiateImageCodec(
        data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
        targetHeight: isSponsor ? 640 : 160,
      );
      try {
        final frame = await codec.getNextFrame();
        if (_disposed) {
          frame.image.dispose();
        } else {
          (isSponsor ? _sponsors : _pageLogos).add(frame.image);
        }
      } finally {
        codec.dispose();
      }
    }
  }

  Future<void> _loadSpeakerPhotos() async {
    final assets = {
      for (final entry in speakerPhotos.entries)
        entry.key: 'assets/images/speakers/${entry.value.asset}',
      'mayor_signature': 'assets/images/mayor_signature.png',
    };
    for (final entry in assets.entries) {
      if (_disposed) return;
      final data = await _assetBundle.load(entry.value);
      final codec = await ui.instantiateImageCodec(
        data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
        targetWidth: 384,
      );
      try {
        final frame = await codec.getNextFrame();
        if (_disposed) {
          frame.image.dispose();
        } else {
          _speakerImages[entry.key] = frame.image;
        }
      } finally {
        codec.dispose();
      }
    }
  }

  Future<void> _rasterize(double ratio, int generation) async {
    // Publish covers before loading any interior-page assets or speaker photos.
    for (final index in [
      -1,
      programFaceCount,
      for (var i = 0; i < programFaceCount; i++) i,
    ]) {
      if (_disposed || generation != _generation) return;
      if (index == -1) {
        await (_coverLoading ??= _loadCover());
      } else if (index == programFaceCount) {
        await (_backCoverLoading ??= _loadCover(back: true));
      } else {
        await (_pageAssetsLoading ??= _loadBranding().then(
          (_) => _loadPageLogos(),
        ));
        if (index >= bioStartIndex && index < programPageCount) {
          await (_speakerPhotosLoading ??= _loadSpeakerPhotos());
        }
      }
      if (_disposed || generation != _generation) return;
      final recorder = ui.PictureRecorder();
      Canvas(recorder)
        ..scale(ratio)
        ..drawPicture(_picture(index));
      final picture = recorder.endRecording();
      late final ui.Image image;
      try {
        image = await picture.toImage(
          (BookPainter.w * ratio).ceil(),
          (BookPainter.h * ratio).ceil(),
        );
      } finally {
        picture.dispose();
      }
      if (_disposed || generation != _generation) {
        image.dispose();
        return;
      }
      _images.remove(index)?.dispose();
      _images[index] = image;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _generation++;
    for (final image in _images.values) {
      image.dispose();
    }
    for (final picture in _pictures.values) {
      picture.dispose();
    }
    _coverImage?.dispose();
    _backCoverImage?.dispose();
    _brandingImage?.dispose();
    for (final logo in _pageLogos) {
      logo.dispose();
    }
    _pageLogos.clear();
    for (final image in _speakerImages.values) {
      image.dispose();
    }
    _speakerImages.clear();
    for (final image in _sponsors) {
      image.dispose();
    }
    _sponsors.clear();
    for (final picture in _sponsorDetails.values) {
      picture.dispose();
    }
    _sponsorDetails.clear();
    _images.clear();
    _pictures.clear();
    super.dispose();
  }
}

class BookPainter extends CustomPainter {
  BookPainter({
    required this.spread,
    required this.direction,
    required this.corner,
    required Offset drag,
    this.dragPosition,
    this.cache,
    this.coverImage,
    this.backCoverImage,
    this.brandingImage,
    this.pageLogos = const [],
    this.speakerImages = const {},
    this.sponsorPulse,
    this.loadingAnimation,
    this.expandedSponsors = const {},
  }) : _initialDrag = drag,
       super(
         repaint: Listenable.merge([
           dragPosition,
           cache,
           sponsorPulse,
           loadingAnimation,
         ]),
       );
  final int spread;
  final int direction;
  final Offset corner;
  final Offset _initialDrag;
  final ValueListenable<Offset>? dragPosition;
  final PageRasterCache? cache;
  final ui.Image? coverImage;
  final ui.Image? backCoverImage;
  final ui.Image? brandingImage;
  final List<ui.Image> pageLogos;
  final Map<String, ui.Image> speakerImages;
  final Animation<double>? sponsorPulse;
  final Animation<double>? loadingAnimation;
  final Set<int> expandedSponsors;
  Offset get drag =>
      constrainPageDrag(dragPosition?.value ?? _initialDrag, corner);
  // US Letter: 8.5 × 11 inches at 60 logical units per inch.
  static const w = 510.0;
  static const h = 660.0;

  void text(
    Canvas c,
    String value,
    Offset at,
    double size, {
    Color color = ink,
    double width = 390,
    String font = 'Georgia',
    double spacing = 0,
    FontWeight weight = FontWeight.normal,
  }) {
    final p = TextPainter(
      text: TextSpan(
        text: value,
        style: TextStyle(
          color: color,
          fontSize: size,
          fontFamily: font,
          height: 1.45,
          letterSpacing: spacing,
          fontWeight: weight,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: width);
    p.paint(c, at);
    p.dispose();
  }

  void landscape(Canvas c, Rect r, int variant) {
    c.save();
    c.clipRect(r);
    c.drawRect(
      r,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0845B5), Color(0xFFFFFFFF)],
        ).createShader(r),
    );
    c.drawCircle(
      Offset(r.left + r.width * .72, r.top + r.height * .23),
      29,
      Paint()..color = const Color(0xFFE4AA19),
    );
    for (var layer = 0; layer < 5; layer++) {
      final path = Path()..moveTo(r.left, r.bottom);
      for (var x = 0.0; x <= r.width + 5; x += 4) {
        final y =
            r.top +
            r.height * (.38 + layer * .13) +
            math.sin(x / (65 - layer * 8) + layer * 1.7 + variant) *
                (29 - layer * 3) +
            math.cos(x / 35 + layer) * 10;
        path.lineTo(r.left + x, y);
      }
      path.lineTo(r.right, r.bottom);
      path.close();
      c.drawPath(
        path,
        Paint()
          ..color = [
            const Color(0xFFCAD5F6),
            const Color(0xFF8DA5ED),
            const Color(0xFF0845B5),
            const Color(0xFF24458B),
            ink,
          ][layer],
      );
    }
    // Fine grain keeps the illustration and paper from feeling digitally flat.
    final random = math.Random(42);
    for (int i = 0; i < 2200; i++) {
      c.drawCircle(
        Offset(
          r.left + random.nextDouble() * r.width,
          r.top + random.nextDouble() * r.height,
        ),
        .55,
        Paint()..color = Colors.white.withValues(alpha: .10),
      );
    }
    c.restore();
  }

  void page(Canvas c, int index, {bool mirrored = false}) {
    if (index < 0 || index >= programPageCount) return;
    c.save();
    if (mirrored) {
      c.translate(w, 0);
      c.scale(-1, 1);
    }
    if (cache case final cached?) {
      cached.draw(c, index, loadingProgress: loadingAnimation?.value ?? 0);
      if (index < sponsorPageCount) {
        for (final sponsorIndex in index == 3 ? [3, 4, 5, 6] : [index]) {
          cached.drawSponsor(
            c,
            sponsorIndex,
            direction == 0 ? (sponsorPulse?.value ?? 0) : 0,
            expanded: expandedSponsors.contains(sponsorIndex),
            supportedExpanded: expandedSponsors.any((i) => i >= 4 && i <= 6),
          );
        }
      }
    } else {
      _paintPage(c, index);
    }
    c.restore();
  }

  void _paintPage(Canvas c, int index) {
    c.save();
    c.clipRect(const Rect.fromLTWH(0, 0, w, h));
    final layout = ProgramLayout(
      index,
      brandingImage: brandingImage,
      pageLogos: pageLogos,
      speakerImages: speakerImages,
    );
    layout.paint(c);
    layout.dispose();
    c.restore();
  }

  Path polygon(List<Offset> points) => Path()..addPolygon(points, true);

  List<Offset> halfPlane(
    List<Offset> points,
    Offset middle,
    Offset normal,
    bool positive,
  ) {
    final result = <Offset>[];
    double distance(Offset p) =>
        (p.dx - middle.dx) * normal.dx + (p.dy - middle.dy) * normal.dy;
    for (int i = 0; i < points.length; i++) {
      final a = points[i], b = points[(i + 1) % points.length];
      final da = distance(a), db = distance(b);
      final insideA = positive ? da >= 0 : da <= 0;
      final insideB = positive ? db >= 0 : db <= 0;
      if (insideA) result.add(a);
      if (insideA != insideB) result.add(Offset.lerp(a, b, da / (da - db))!);
    }
    return result;
  }

  void cover(Canvas canvas, {bool back = false}) {
    if (cache case final cached?) {
      cached.draw(
        canvas,
        back ? programFaceCount : -1,
        loadingProgress: loadingAnimation?.value ?? 0,
      );
    } else {
      _paintCover(canvas, back: back);
    }
  }

  void _paintCover(Canvas canvas, {bool back = false}) {
    final image = back ? backCoverImage : coverImage;
    canvas.drawRect(const Rect.fromLTWH(0, 0, w, h), Paint()..color = ink);
    if (image == null) return;
    final source = Size(image.width.toDouble(), image.height.toDouble());
    final fitted = applyBoxFit(BoxFit.fitWidth, source, const Size(w, h));
    canvas.drawImageRect(
      image,
      Alignment.center.inscribe(fitted.source, Offset.zero & source),
      Alignment.center.inscribe(
        fitted.destination,
        const Rect.fromLTWH(0, 0, w, h),
      ),
      Paint()..filterQuality = FilterQuality.medium,
    );
  }

  // The cover and inner pages share the same pointer-driven paper fold.
  void paintSheet(
    Canvas canvas, {
    required void Function(Canvas) drawFront,
    required void Function(Canvas) drawBack,
  }) {
    final normalRaw = corner - drag;
    final length = normalRaw.distance;
    if (length <= .001) {
      drawFront(canvas);
      return;
    }
    {
      final n = normalRaw / length;
      final middle = (corner + drag) / 2;
      final rect = [
        Offset.zero,
        const Offset(w, 0),
        const Offset(w, h),
        const Offset(0, h),
      ];
      final flat = halfPlane(rect, middle, n, false);
      final folded = halfPlane(rect, middle, n, true);
      canvas.save();
      canvas.clipPath(polygon(flat));
      // Cached faces are already opaque; no offscreen compositing pass is needed.
      canvas.drawPaint(Paint()..color = paper);
      drawFront(canvas);
      canvas.restore();
      Offset reflect(Offset p) =>
          p - n * (2 * ((p.dx - middle.dx) * n.dx + (p.dy - middle.dy) * n.dy));
      final flap = polygon(folded.map(reflect).toList());
      final d = middle.dx * n.dx + middle.dy * n.dy;
      canvas.save();
      canvas.clipPath(flap);
      canvas.drawPaint(Paint()..color = paper);
      canvas.transform(
        Float64List.fromList([
          1 - 2 * n.dx * n.dx,
          -2 * n.dx * n.dy,
          0,
          0,
          -2 * n.dx * n.dy,
          1 - 2 * n.dy * n.dy,
          0,
          0,
          0,
          0,
          1,
          0,
          2 * n.dx * d,
          2 * n.dy * d,
          0,
          1,
        ]),
      );
      canvas.translate(w, 0);
      canvas.scale(-1, 1);
      drawBack(canvas);
      canvas.restore();
      canvas.save();
      canvas.clipPath(flap);
      final lift = math.sin(math.pi * ((510 - drag.dx) / 1020)).clamp(0.0, 1.0);
      canvas.drawPaint(
        Paint()
          ..shader = ui.Gradient.linear(
            middle - n * (12 + 23 * lift),
            middle + n * 2,
            [
              Colors.transparent,
              Colors.black.withValues(alpha: .04 * lift),
              Colors.black.withValues(alpha: .18 * lift),
            ],
            [0, .62, 1],
          ),
      );
      canvas.restore();
    }
  }

  void paintCoverTurn(Canvas canvas, {bool back = false}) {
    final closed = back ? spread == programClosingSpread : spread == -1;
    final closingFace = programPageCount.isOdd
        ? programPageCount - 1
        : programFaceCount;
    final reversePage = back ? closingFace - 1 : 0;
    void drawCover(Canvas c) {
      c.save();
      if (back) {
        c.translate(w, 0);
        c.scale(-1, 1);
      }
      if (back && programPageCount.isOdd) {
        page(c, closingFace);
      } else {
        cover(c, back: back);
      }
      c.restore();
    }

    if (back) {
      // Mirror the cover motion at the far end of the book, keeping print upright.
      canvas.translate(1020, 0);
      canvas.scale(-1, 1);
    }
    final turn = ((510 - drag.dx) / 1020).clamp(0.0, 1.0);
    final progress = closed ? (direction == 0 ? 0.0 : turn) : 1 - turn;
    canvas.translate(-255 * (1 - progress), 0);
    canvas.save();
    canvas.clipRect(const Rect.fromLTWH(510, 0, w, h), doAntiAlias: false);
    canvas.save();
    canvas.translate(w, 0);
    page(canvas, back ? closingFace - 2 : 1, mirrored: back);
    canvas.restore();
    canvas.restore();
    canvas.save();
    canvas.translate(w, 0);
    if (direction == 0) {
      drawCover(canvas);
    } else if (closed) {
      paintSheet(
        canvas,
        drawFront: drawCover,
        drawBack: (c) => page(c, reversePage, mirrored: back),
      );
    } else {
      canvas.scale(-1, 1);
      paintSheet(
        canvas,
        drawFront: (c) => page(c, reversePage, mirrored: !back),
        drawBack: (c) {
          c.save();
          c.translate(w, 0);
          c.scale(-1, 1);
          drawCover(c);
          c.restore();
        },
      );
    }
    canvas.restore();
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 1020);
    if (spread == -1 || (spread == 0 && direction == -1)) {
      paintCoverTurn(canvas);
      canvas.restore();
      return;
    }
    if (spread == programClosingSpread ||
        (spread == programClosingSpread - 1 && direction == 1)) {
      paintCoverTurn(canvas, back: true);
      canvas.restore();
      return;
    }
    if (direction >= 0) page(canvas, spread * 2);
    if (direction <= 0) {
      canvas.save();
      canvas.translate(w, 0);
      page(canvas, spread * 2 + 1);
      canvas.restore();
    }
    canvas.save();
    // On an odd final page the other half is empty, including its spine shade.
    if (spread * 2 + 1 >= programPageCount && direction == 0) {
      canvas.clipRect(const Rect.fromLTWH(0, 0, w, h));
    }
    canvas.drawRect(
      const Rect.fromLTWH(482, 0, 56, h),
      Paint()
        ..shader = const LinearGradient(
          colors: [
            Colors.transparent,
            Color(0x18000000),
            Color(0x35000000),
            Color(0x09FFFFFF),
            Colors.transparent,
          ],
          stops: [0, .4, .5, .6, 1],
        ).createShader(const Rect.fromLTWH(482, 0, 56, h)),
    );
    canvas.restore();
    if (direction != 0) {
      canvas.save();
      canvas.translate(w, 0);
      if (direction < 0) canvas.scale(-1, 1);
      final front = direction > 0 ? spread * 2 + 1 : spread * 2;
      final back = direction > 0 ? front + 1 : front - 1;
      final under = direction > 0 ? front + 2 : front - 2;
      page(canvas, under, mirrored: direction < 0);
      paintSheet(
        canvas,
        drawFront: (c) => page(c, front, mirrored: direction < 0),
        drawBack: (c) => page(c, back, mirrored: direction < 0),
      );
      canvas.restore();
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(BookPainter old) =>
      !setEquals(expandedSponsors, old.expandedSponsors) ||
      spread != old.spread ||
      direction != old.direction ||
      corner != old.corner ||
      drag != old.drag ||
      cache != old.cache ||
      dragPosition != old.dragPosition;
}
