import 'program_test_helpers.dart';
import 'dart:ui' show PointerDeviceKind;

import 'package:flipbook/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final width in [320.0, 390.0, 1024.0]) {
    for (final kind in [PointerDeviceKind.touch, PointerDeviceKind.mouse]) {
      testWidgets('$kind turns cover and pages at width $width', (
        tester,
      ) async {
        tester.view.physicalSize = Size(width, 844);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        await tester.pumpWidget(const MyApp(animateSponsors: false));
        await tester.pumpAndSettle();
        if (width < 600) {
          final center = tester.getCenter(find.byKey(const Key('book')));
          await tester.tapAt(center);
          await tester.pump(const Duration(milliseconds: 80));
          await tester.tapAt(center);
          await tester.pumpAndSettle();
        }
        final book = find.byKey(const Key('book'));
        final rect = tester.getRect(book);
        BookPainter painter() =>
            tester
                    .widget<CustomPaint>(
                      find.descendant(
                        of: book,
                        matching: find.byType(CustomPaint),
                      ),
                    )
                    .painter!
                as BookPainter;

        Future<void> turn({required bool cover, required bool forward}) async {
          final edge = cover
              ? rect.left + rect.width * (forward ? .75 : .25)
              : forward
              ? rect.right
              : rect.left;
          // Grab 35 screen pixels inside the edge, including on narrow phones.
          final start = Offset(edge + (forward ? -35 : 35), rect.center.dy);
          final gesture = await tester.startGesture(start, kind: kind);
          // The first move crosses the entire old mobile edge zone. Recognition
          // must use the original pointer-down position, not this later point.
          await gesture.moveBy(Offset(forward ? -60 : 60, 0));
          await tester.pump();
          expect(painter().direction, forward ? 1 : -1);
          final intermediate = painter().drag;
          await gesture.moveBy(Offset(rect.width * (forward ? -.65 : .65), 15));
          await tester.pump(const Duration(milliseconds: 50));
          expect(painter().drag, isNot(intermediate));
          await gesture.up();
          await tester.pumpAndSettle();
        }

        await turn(cover: true, forward: true);
        expect(
          find.text('Pages 1 - 2 out of $programPageCount'),
          findsOneWidget,
        );
        await turn(cover: false, forward: true);
        expect(
          find.text('Pages 3 - 4 out of $programPageCount'),
          findsOneWidget,
        );
        for (var i = 0; i < programSpreadCount - 2; i++) {
          await turn(cover: false, forward: true);
        }
        expect(find.text(spreadLabel(programSpreadCount - 1)), findsOneWidget);
        await turn(cover: false, forward: true);
        expect(find.text('Back Cover'), findsOneWidget);
        final cancel = await tester.startGesture(
          Offset(rect.left + rect.width * .25 + 3, rect.center.dy),
          kind: kind,
        );
        await cancel.moveBy(const Offset(25, 0));
        await tester.pump(const Duration(milliseconds: 250));
        await cancel.up();
        await tester.pumpAndSettle();
        expect(find.text('Back Cover'), findsOneWidget);
        await turn(cover: true, forward: false);
        expect(find.text(spreadLabel(programSpreadCount - 1)), findsOneWidget);
        for (var i = 0; i < programSpreadCount - 2; i++) {
          await turn(cover: false, forward: false);
        }
        expect(
          find.text('Pages 3 - 4 out of $programPageCount'),
          findsOneWidget,
        );

        await turn(cover: false, forward: false);
        expect(
          find.text('Pages 1 - 2 out of $programPageCount'),
          findsOneWidget,
        );
        await turn(cover: false, forward: false);
        expect(find.text('Front Cover'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }
  }
}
