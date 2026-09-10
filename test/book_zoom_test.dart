import 'dart:math' as math;
import 'package:flipbook/main.dart';
import 'package:flipbook/zoomable_book.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> doubleTap(WidgetTester tester, Offset point) async {
    await tester.tapAt(point);
    await tester.pump(const Duration(milliseconds: 80));
    await tester.tapAt(point);
    await tester.pumpAndSettle();
  }

  Future<void> mobile(WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      const MyApp(animateSponsors: false, animateLoading: false),
    );
    await tester.pumpAndSettle();
    // These interaction tests begin at overview zoom explicitly.
    await doubleTap(tester, tester.getCenter(find.byKey(const Key('book'))));
  }

  Matrix4 transform(WidgetTester tester) => tester
      .widget<Transform>(find.byKey(const Key('book-transform')))
      .transform;
  EdgeInsets effectivePadding(WidgetTester tester) =>
      ZoomableBook.paddingForWidth(
        tester.getSize(find.byKey(const Key('book-viewport'))).width,
      );

  double fitZoom(WidgetTester tester) {
    final viewport = tester.getRect(find.byKey(const Key('book-viewport')));
    final book = tester.getSize(find.byKey(const Key('book')));
    return math
        .min(
          viewport.width /
              (book.width / 2 + effectivePadding(tester).horizontal),
          viewport.height / (book.height + effectivePadding(tester).vertical),
        )
        .clamp(1.0, 8.0);
  }

  double zoom(WidgetTester tester) => transform(tester).getMaxScaleOnAxis();

  Future<void> pinchMore(WidgetTester tester) async {
    final center = tester.getCenter(find.byKey(const Key('book-viewport')));
    final first = await tester.startGesture(
      center - const Offset(30, 0),
      pointer: 1,
    );
    final second = await tester.startGesture(
      center + const Offset(30, 0),
      pointer: 2,
    );
    await first.moveBy(const Offset(-70, 0));
    await second.moveBy(const Offset(70, 0));
    await first.up();
    await second.up();
    await tester.pumpAndSettle();
  }

  testWidgets('Reposition runs during the turn and finishes with it', (
    tester,
  ) async {
    await mobile(tester);
    await doubleTap(tester, tester.getCenter(find.byKey(const Key('book'))));
    final before = transform(tester).entry(0, 3);
    await tester.tap(find.byTooltip('Next pages'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(transform(tester).entry(0, 3), isNot(closeTo(before, .01)));
    expect(tester.widget<ZoomableBook>(find.byType(ZoomableBook)).spread, -1);
    await tester.pump(const Duration(milliseconds: 370));
    expect(tester.widget<ZoomableBook>(find.byType(ZoomableBook)).spread, 0);
    final finished = Matrix4.copy(transform(tester));
    await tester.pump(const Duration(milliseconds: 300));
    expect(transform(tester), finished);
    expect(find.text('Page 1 out of $programPageCount'), findsOneWidget);
  });

  testWidgets('Mouse wheel and trackpad pinch zoom only the book', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MyApp(animateSponsors: false, animateLoading: false),
    );
    await tester.pumpAndSettle();
    final point = tester.getCenter(find.byKey(const Key('book-viewport')));
    final header = tester.getRect(find.byKey(const Key('ctc-logo')));
    await tester.sendEventToBinding(
      PointerScrollEvent(position: point, scrollDelta: const Offset(0, -180)),
    );
    await tester.pump();
    expect(zoom(tester), greaterThan(1));
    await tester.sendEventToBinding(
      PointerScrollEvent(position: point, scrollDelta: const Offset(0, 1000)),
    );
    await tester.pump();
    expect(zoom(tester), 1);
    await tester.sendEventToBinding(
      PointerPanZoomStartEvent(pointer: 10, position: point),
    );
    await tester.sendEventToBinding(
      PointerPanZoomUpdateEvent(pointer: 10, position: point, scale: 2),
    );
    await tester.pump();
    expect(zoom(tester), 2);
    final state = tester.state<ZoomableBookState>(find.byType(ZoomableBook));
    expect(state.positionBeforeTurn(1), isFalse);
    await tester.sendEventToBinding(
      PointerPanZoomUpdateEvent(pointer: 10, position: point, scale: .5),
    );
    await tester.sendEventToBinding(
      PointerPanZoomEndEvent(pointer: 10, position: point),
    );
    await tester.pump();
    expect(zoom(tester), 1);
    expect(tester.getRect(find.byKey(const Key('ctc-logo'))), header);
    expect(find.text('Front Cover'), findsOneWidget);
  });

  testWidgets('Both covers stay centered until zoomed beyond page fit', (
    tester,
  ) async {
    await mobile(tester);
    for (final back in [false, true]) {
      if (back) {
        for (var i = 0; i <= programClosingSpread; i++) {
          await tester.tap(find.byTooltip('Next pages'));
          await tester.pumpAndSettle();
        }
      }
      final area = tester.getRect(find.byKey(const Key('book-viewport')));
      await doubleTap(tester, area.center);
      final before = tester.getRect(find.byKey(const Key('book')));
      await tester.dragFrom(area.center, const Offset(-65, 30));
      await tester.pumpAndSettle();
      expect(tester.getRect(find.byKey(const Key('book'))), before);
      expect(
        find.text(
          back
              ? (programPageCount.isOdd
                    ? 'Page $programPageCount out of $programPageCount'
                    : 'Back Cover')
              : 'Front Cover',
        ),
        findsOneWidget,
      );
      await pinchMore(tester);
      final offset = transform(tester).entry(0, 3);
      await tester.dragFrom(area.center, const Offset(-45, 0));
      await tester.pumpAndSettle();
      expect(transform(tester).entry(0, 3), lessThan(offset));
      await doubleTap(tester, area.center);
      expect(zoom(tester), 1);
      expect(
        (tester.getRect(find.byKey(const Key('book-padding'))).center -
                area.center)
            .distance,
        lessThan(.01),
      );
    }
  });

  testWidgets('Mobile starts with the cover fitted to one page', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      const MyApp(animateSponsors: false, animateLoading: false),
    );
    await tester.pumpAndSettle();
    expect(zoom(tester), closeTo(fitZoom(tester), .001));
    expect(zoom(tester), greaterThan(1));
    final area = tester.getRect(find.byKey(const Key('book-viewport')));
    expect(
      (tester.getRect(find.byKey(const Key('book-padding'))).center -
              area.center)
          .distance,
      lessThan(.01),
    );
    await tester.tap(find.byTooltip('Next pages'));
    await tester.pumpAndSettle();
    expect(find.text('Page 1 out of $programPageCount'), findsOneWidget);
    await tester.tap(find.byTooltip('Next pages'));
    await tester.pumpAndSettle();
    expect(find.text('Page 2 out of $programPageCount'), findsOneWidget);
  });

  testWidgets(
    'Live browser resizing refits the book and preserves the spread',
    (tester) async {
      await mobile(tester);
      tester.view.physicalSize = const Size(1440, 900);
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Next pages'));
      await tester.pumpAndSettle();
      final viewport = tester.getRect(find.byKey(const Key('book-viewport')));
      final first = await tester.startGesture(
        viewport.center - const Offset(30, 0),
        pointer: 1,
      );
      final second = await tester.startGesture(
        viewport.center + const Offset(30, 0),
        pointer: 2,
      );
      await first.moveBy(const Offset(-60, 0));
      await second.moveBy(const Offset(60, 0));
      await first.up();
      await second.up();
      await tester.pumpAndSettle();
      expect(zoom(tester), greaterThan(1));
      for (final size in [
        const Size(1000, 900),
        const Size(600, 900),
        const Size(390, 844),
        const Size(320, 740),
        const Size(1440, 900),
      ]) {
        tester.view.physicalSize = size;
        await tester.pumpAndSettle();
        expect(
          zoom(tester),
          size.width < 600 ? closeTo(fitZoom(tester), .001) : 1,
        );
        final area = tester.getRect(find.byKey(const Key('book-viewport')));
        final book = tester.getRect(find.byKey(const Key('book')));
        expect((book.width / 2) / book.height, closeTo(8.5 / 11, .00001));
        if (size.width >= 600) {
          expect(
            (tester.getRect(find.byKey(const Key('book-padding'))).center -
                    area.center)
                .distance,
            lessThan(.01),
          );
        }
        expect(
          size.width < 600 ? book.width / 2 : book.width,
          lessThanOrEqualTo(
            area.width - effectivePadding(tester).horizontal + .01,
          ),
        );
        expect(book.height, lessThanOrEqualTo(area.height + .01));
        expect(
          find.text(
            size.width < 600
                ? 'Page 1 out of $programPageCount'
                : 'Pages 1 - 2 out of $programPageCount',
          ),
          findsOneWidget,
        );
        expect(tester.takeException(), isNull);
      }
      await tester.tap(find.byTooltip('Next pages'));
      await tester.pumpAndSettle();
      expect(find.text('Pages 3 - 4 out of $programPageCount'), findsOneWidget);
    },
  );

  testWidgets(
    'Double tap zooms only the book; body drag pans and double tap resets',
    (tester) async {
      await mobile(tester);
      final header = tester.getRect(find.byKey(const Key('ctc-logo')));
      final footer = tester.getRect(find.byKey(const Key('next-button-slot')));
      final originalBook = tester.getRect(find.byKey(const Key('book')));
      final viewport = tester.getRect(find.byKey(const Key('book-viewport')));
      await doubleTap(tester, originalBook.center);
      expect(zoom(tester), closeTo(fitZoom(tester), .001));
      expect(
        tester.getRect(find.byKey(const Key('book'))).width,
        closeTo(originalBook.width * fitZoom(tester), .01),
      );
      expect(tester.getRect(find.byKey(const Key('ctc-logo'))), header);
      expect(tester.getRect(find.byKey(const Key('next-button-slot'))), footer);
      expect(tester.getRect(find.byKey(const Key('book-viewport'))), viewport);
      await pinchMore(tester);
      final beforePan = transform(tester).entry(0, 3);
      await tester.dragFrom(viewport.center, const Offset(-70, 0));
      await tester.pumpAndSettle();
      expect(transform(tester).entry(0, 3), lessThan(beforePan));
      expect(find.text('Front Cover'), findsOneWidget);
      await doubleTap(tester, viewport.center);
      expect(zoom(tester), closeTo(1, .001));
      expect(tester.getRect(find.byKey(const Key('book'))), originalBook);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('External padding scales and moves with the book', (
    tester,
  ) async {
    await mobile(tester);
    void checkPadding() {
      final book = tester.getRect(find.byKey(const Key('book')));
      final padding = tester.getRect(find.byKey(const Key('book-padding')));
      final scale = zoom(tester);
      expect(
        book.left - padding.left,
        closeTo(effectivePadding(tester).left * scale, .01),
      );
      expect(
        book.top - padding.top,
        closeTo(effectivePadding(tester).top * scale, .01),
      );
      expect(
        padding.right - book.right,
        closeTo(effectivePadding(tester).right * scale, .01),
      );
      expect(
        padding.bottom - book.bottom,
        closeTo(effectivePadding(tester).bottom * scale, .01),
      );
    }

    checkPadding();
    final center = tester.getCenter(find.byKey(const Key('book')));
    await doubleTap(tester, center);
    checkPadding();
    await pinchMore(tester);
    final before = tester.getRect(find.byKey(const Key('book-padding')));
    await tester.dragFrom(center, const Offset(-50, 0));
    await tester.pumpAndSettle();
    checkPadding();
    expect(
      tester.getRect(find.byKey(const Key('book-padding'))).left,
      lessThan(before.left),
    );
    expect(find.text('Front Cover'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  for (final size in [
    const Size(320, 740),
    const Size(390, 844),
    const Size(844, 390),
  ]) {
    for (final right in [false, true]) {
      testWidgets(
        'Double tap fits and centers the ${right ? "right" : "left"} page at $size',
        (tester) async {
          tester.view.physicalSize = size;
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          await tester.pumpWidget(
            const MyApp(animateSponsors: false, animateLoading: false),
          );
          await tester.pumpAndSettle();
          if (size.width < 600) {
            await doubleTap(
              tester,
              tester.getCenter(find.byKey(const Key('book'))),
            );
          }
          await tester.tap(find.byTooltip('Next pages'));
          await tester.pumpAndSettle();
          final bookFinder = find.byKey(const Key('book'));
          final before = tester.getRect(bookFinder);
          final viewport = tester.getRect(
            find.byKey(const Key('book-viewport')),
          );
          final header = tester.getRect(find.byKey(const Key('ctc-logo')));
          final footer = tester.getRect(
            find.byKey(const Key('next-button-slot')),
          );
          await doubleTap(
            tester,
            Offset(
              before.left + before.width * (right ? .82 : .18),
              before.top + before.height * .2,
            ),
          );
          final book = tester.getRect(bookFinder);
          if (size.width >= 600) {
            expect(book, before);
            expect(zoom(tester), 1);
            final state = tester.state<ZoomableBookState>(
              find.byType(ZoomableBook),
            );
            expect(state.positionBeforeTurn(1), isFalse);
            expect(state.positionBeforeTurn(-1), isFalse);
            await tester.tap(find.byTooltip('Next pages'));
            await tester.pumpAndSettle();
            expect(
              find.text('Pages 3 - 4 out of $programPageCount'),
              findsOneWidget,
            );
            return;
          }
          final page = Rect.fromLTWH(
            book.left + (right ? book.width / 2 : 0),
            book.top,
            book.width / 2,
            book.height,
          );
          expect(page.width, lessThanOrEqualTo(viewport.width + .01));
          expect(page.height, lessThanOrEqualTo(viewport.height + .01));
          final scale = zoom(tester);
          final paddedPage = Rect.fromLTRB(
            page.left - effectivePadding(tester).left * scale,
            page.top - effectivePadding(tester).top * scale,
            page.right + effectivePadding(tester).right * scale,
            page.bottom + effectivePadding(tester).bottom * scale,
          );
          expect((paddedPage.center - viewport.center).distance, lessThan(.01));
          expect(
            math.min(
              (paddedPage.width - viewport.width).abs(),
              (paddedPage.height - viewport.height).abs(),
            ),
            lessThan(.01),
          );
          expect(tester.getRect(find.byKey(const Key('ctc-logo'))), header);
          expect(
            tester.getRect(find.byKey(const Key('next-button-slot'))).size,
            footer.size,
          );
          expect(
            tester.getRect(find.byKey(const Key('next-button-slot'))).top,
            footer.top,
          );
          expect(tester.takeException(), isNull);
        },
      );
    }
  }

  testWidgets('Two-finger pinch is bounded and never turns a page', (
    tester,
  ) async {
    await mobile(tester);
    final center = tester.getCenter(find.byKey(const Key('book-viewport')));
    final header = tester.getRect(find.byKey(const Key('ctc-logo')));
    final footer = tester.getRect(find.byKey(const Key('next-button-slot')));
    final first = await tester.startGesture(
      center - const Offset(40, 0),
      pointer: 1,
    );
    final second = await tester.startGesture(
      center + const Offset(40, 0),
      pointer: 2,
    );
    await first.moveTo(center - const Offset(80, 0));
    await second.moveTo(center + const Offset(80, 0));
    await tester.pump();
    expect(zoom(tester), closeTo(2, .001));
    await first.moveTo(center - const Offset(400, 0));
    await second.moveTo(center + const Offset(400, 0));
    await tester.pump();
    expect(zoom(tester), closeTo(8, .001));
    await first.moveTo(center - const Offset(10, 0));
    await second.moveTo(center + const Offset(10, 0));
    await tester.pump();
    expect(zoom(tester), closeTo(1, .001));
    await first.up();
    await second.up();
    await tester.pumpAndSettle();
    expect(find.text('Front Cover'), findsOneWidget);
    expect(tester.getRect(find.byKey(const Key('ctc-logo'))), header);
    expect(tester.getRect(find.byKey(const Key('next-button-slot'))), footer);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'Zoomed edge drags still open the book using transformed coordinates',
    (tester) async {
      await mobile(tester);
      var book = tester.getRect(find.byKey(const Key('book')));
      await doubleTap(
        tester,
        Offset(book.left + book.width * .75 - 12, book.center.dy),
      );
      book = tester.getRect(find.byKey(const Key('book')));
      final start = Offset(book.left + book.width * .75 - 3, book.center.dy);
      final viewport = tester.getRect(find.byKey(const Key('book-viewport')));
      expect(viewport.contains(start), isTrue);
      final gesture = await tester.startGesture(start);
      await gesture.moveBy(Offset(-book.width * .65, 0));
      await tester.pump();
      await gesture.up();
      await tester.pumpAndSettle();
      expect(find.text('Page 1 out of $programPageCount'), findsOneWidget);
      expect(zoom(tester), closeTo(fitZoom(tester), .001));
      await tester.tap(find.byTooltip('Next pages'));
      await tester.pumpAndSettle();
      expect(find.text('Page 2 out of $programPageCount'), findsOneWidget);
      await tester.tap(find.byTooltip('Next pages'));
      await tester.pumpAndSettle();
      expect(find.text('Page 3 out of $programPageCount'), findsOneWidget);
      expect(zoom(tester), closeTo(fitZoom(tester), .001));
      expect(tester.takeException(), isNull);
    },
  );

  for (final pinchMore in [false, true]) {
    testWidgets(
      'Zoomed navigation aligns pages and centers both covers (extra pinch: $pinchMore)',
      (tester) async {
        await mobile(tester);
        final viewport = tester.getRect(find.byKey(const Key('book-viewport')));
        final header = tester.getRect(find.byKey(const Key('ctc-logo')));
        final footer = tester.getRect(
          find.byKey(const Key('next-button-slot')),
        );
        await doubleTap(
          tester,
          tester.getCenter(find.byKey(const Key('book'))),
        );
        if (pinchMore) {
          final first = await tester.startGesture(
            viewport.center - const Offset(30, 0),
            pointer: 1,
          );
          final second = await tester.startGesture(
            viewport.center + const Offset(30, 0),
            pointer: 2,
          );
          await first.moveBy(const Offset(-70, 0));
          await second.moveBy(const Offset(70, 0));
          await first.up();
          await second.up();
          await tester.pumpAndSettle();
        }
        final expectedZoom = fitZoom(tester);
        if (pinchMore) expect(zoom(tester), greaterThan(expectedZoom));
        Future<void> navigate(
          bool forward,
          String label, {
          bool keyboard = false,
        }) async {
          Future<void> press() async {
            if (keyboard) {
              await tester.sendKeyEvent(
                forward
                    ? LogicalKeyboardKey.arrowRight
                    : LogicalKeyboardKey.arrowLeft,
              );
            } else {
              await tester.tap(
                find.byTooltip(forward ? 'Next pages' : 'Previous pages'),
              );
            }
            await tester.pumpAndSettle();
          }

          final before = tester.widget<ZoomableBook>(find.byType(ZoomableBook));
          final beforeFrame = tester.getRect(
            find.byKey(const Key('book-padding')),
          );
          final mustPosition =
              !before.closedCover &&
              !(forward && before.spread * 2 + 2 > programPageCount) &&
              (forward
                  ? (beforeFrame.right - viewport.right).abs() > 1
                  : (beforeFrame.left - viewport.left).abs() > 1);
          await press();
          if (mustPosition) {
            expect(
              tester.widget<ZoomableBook>(find.byType(ZoomableBook)).spread,
              before.spread,
            );
            final positioned = tester.getRect(
              find.byKey(const Key('book-padding')),
            );
            expect(
              forward ? positioned.right : positioned.left,
              closeTo(forward ? viewport.right : viewport.left, .01),
            );
            expect(
              find.text(
                'Page ${before.spread * 2 + (forward ? 2 : 1)} out of $programPageCount',
              ),
              findsOneWidget,
            );
            await press();
          }
          final expectedLabel = label.contains('Cover')
              ? label
              : 'Page ${label.split(' — ')[forward ? 0 : 1]} out of $programPageCount';
          expect(find.text(expectedLabel), findsOneWidget);
          expect(zoom(tester), closeTo(expectedZoom, .001));
          final frame = tester.getRect(find.byKey(const Key('book-padding')));
          if (tester
              .widget<ZoomableBook>(find.byType(ZoomableBook))
              .closedCover) {
            expect((frame.center - viewport.center).distance, lessThan(.01));
          } else if (forward ||
              label.split(' — ').first == label.split(' — ').last) {
            expect(frame.left, closeTo(viewport.left, .01));
          } else {
            expect(frame.right, closeTo(viewport.right, .01));
          }
          expect(tester.getRect(find.byKey(const Key('ctc-logo'))), header);
          final currentFooter = tester.getRect(
            find.byKey(const Key('next-button-slot')),
          );
          expect(currentFooter.size, footer.size);
          expect(currentFooter.top, footer.top);
        }

        await navigate(true, '1 — 2');
        await tester.dragFrom(viewport.center, const Offset(-60, 0));
        await tester.pumpAndSettle();
        await navigate(true, '3 — 4', keyboard: true);
        for (var spread = 2; spread < programSpreadCount; spread++) {
          await navigate(
            true,
            '${spread * 2 + 1} — ${math.min(spread * 2 + 2, programPageCount)}',
          );
        }
        if (programPageCount.isEven) {
          await navigate(true, 'Back Cover');
        } else {
          expect(find.byTooltip('Next pages'), findsNothing);
          expect(find.text('Back Cover'), findsNothing);
        }
        for (
          var spread = programSpreadCount - (programPageCount.isOdd ? 2 : 1);
          spread >= 0;
          spread--
        ) {
          await navigate(
            false,
            '${spread * 2 + 1} — ${math.min(spread * 2 + 2, programPageCount)}',
            keyboard: spread == 1,
          );
        }
        await navigate(false, 'Front Cover');
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets('A second finger cancels an active page turn before pinching', (
    tester,
  ) async {
    await mobile(tester);
    final book = tester.getRect(find.byKey(const Key('book')));
    final first = await tester.startGesture(
      Offset(book.left + book.width * .75 - 3, book.center.dy),
      pointer: 1,
    );
    await first.moveBy(const Offset(-25, 0));
    await tester.pump();
    final painter =
        tester
                .widget<CustomPaint>(
                  find.descendant(
                    of: find.byKey(const Key('book')),
                    matching: find.byType(CustomPaint),
                  ),
                )
                .painter!
            as BookPainter;
    expect(painter.direction, 1);
    final second = await tester.startGesture(
      book.center - const Offset(50, 0),
      pointer: 2,
    );
    await second.moveBy(const Offset(-60, 0));
    await tester.pump();
    expect(zoom(tester), greaterThan(1));
    await first.up();
    await second.up();
    await tester.pumpAndSettle();
    expect(find.text('Front Cover'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
