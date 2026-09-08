import 'package:flipbook/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'Extreme pulls keep the entire spine on the stationary side of the fold',
    () {
      for (final corner in [const Offset(510, 0), const Offset(510, 660)]) {
        for (var x = -4000.0; x <= 4000; x += 137) {
          for (var y = -4000.0; y <= 4000; y += 137) {
            final drag = constrainPageDrag(Offset(x, y), corner);
            for (final anchor in [Offset.zero, const Offset(0, 660)]) {
              expect(
                (drag - anchor).distance,
                lessThanOrEqualTo((corner - anchor).distance + 1e-8),
              );
            }
            final normal = corner - drag;
            final midpoint = (corner + drag) / 2;
            for (var spineY = 0.0; spineY <= 660; spineY += 33) {
              final side =
                  -midpoint.dx * normal.dx + (spineY - midpoint.dy) * normal.dy;
              expect(
                side,
                lessThanOrEqualTo(1e-7),
                reason: 'Fold detached at spine y=$spineY for pull ($x, $y)',
              );
            }
          }
        }
      }
    },
  );

  test('Rest positions and valid drags stay unchanged', () {
    for (final corner in [const Offset(510, 0), const Offset(510, 660)]) {
      for (final drag in [corner, Offset(-510, corner.dy), Offset(100, 330)]) {
        expect(constrainPageDrag(drag, corner), drag);
      }
    }
  });

  testWidgets(
    'Dragging far beyond the book keeps the cover and pages attached',
    (tester) async {
      await tester.pumpWidget(
        const MyApp(animateSponsors: false, animateLoading: false),
      );
      final book = find.byKey(const Key('book'));
      final rect = tester.getRect(book);
      for (final cover in [true, false]) {
        final start = Offset(
          rect.left + rect.width * (cover ? .75 : 1) - 3,
          rect.bottom - 10,
        );
        final gesture = await tester.startGesture(start);
        await gesture.moveBy(const Offset(-25, 0));
        await tester.pump();
        await gesture.moveBy(const Offset(-2000, 900));
        await tester.pump();
        final painter =
            tester
                    .widget<CustomPaint>(
                      find.descendant(
                        of: book,
                        matching: find.byType(CustomPaint),
                      ),
                    )
                    .painter!
                as BookPainter;
        expect(painter.direction, 1);
        for (final anchor in [Offset.zero, const Offset(0, 660)]) {
          expect(
            (painter.drag - anchor).distance,
            lessThanOrEqualTo((painter.corner - anchor).distance + 1e-8),
          );
        }
        await gesture.up();
        await tester.pumpAndSettle();
        expect(
          find.text(
            cover
                ? 'Pages 1 - 2 out of $programPageCount'
                : 'Pages 3 - 4 out of $programPageCount',
          ),
          findsOneWidget,
        );
        expect(tester.takeException(), isNull);
      }
    },
  );
}
