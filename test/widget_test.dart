import 'program_test_helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flipbook/main.dart';

void main() {
  testWidgets('Navigation respects both book boundaries and keyboard input', (
    tester,
  ) async {
    await tester.pumpWidget(const MyApp(animateSponsors: false));
    expect(find.text('Front Cover'), findsOneWidget);
    expect(find.byTooltip('Previous pages'), findsNothing);
    expect(
      tester.getSize(find.byKey(const Key('previous-button-slot'))),
      const Size(48, 48),
    );
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pumpAndSettle();
    expect(find.text('Pages 1 - 2 out of $programPageCount'), findsOneWidget);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pumpAndSettle();
    expect(find.text('Pages 3 - 4 out of $programPageCount'), findsOneWidget);
    for (var i = 0; i < programSpreadCount - 2; i++) {
      await tester.tap(find.byTooltip('Next pages'));
      await tester.pumpAndSettle();
    }
    expect(find.text(spreadLabel(programSpreadCount - 1)), findsOneWidget);
    await tester.tap(find.byTooltip('Next pages'));
    await tester.pumpAndSettle();
    expect(find.text('Back Cover'), findsOneWidget);
    expect(find.byTooltip('Next pages'), findsNothing);
    expect(
      tester.getSize(find.byKey(const Key('next-button-slot'))),
      const Size(48, 48),
    );
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
    await tester.pumpAndSettle();
    expect(find.text(spreadLabel(programSpreadCount - 1)), findsOneWidget);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
    await tester.pumpAndSettle();
    expect(find.text(spreadLabel(programSpreadCount - 2)), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'Outer edge drags turn in both directions; short drags settle back',
    (tester) async {
      await tester.pumpWidget(const MyApp(animateSponsors: false));
      final rect = tester.getRect(find.byKey(const Key('book')));
      Future<void> drag(Offset start, Offset delta) async {
        final gesture = await tester.startGesture(start);
        await gesture.moveBy(Offset(delta.dx.sign * 22, 0));
        await tester.pump(const Duration(milliseconds: 40));
        await gesture.moveBy(delta);
        await tester.pump(const Duration(milliseconds: 250));
        await gesture.up();
        await tester.pumpAndSettle();
      }

      final coverEdge = Offset(
        rect.left + rect.width * .75 - 3,
        rect.bottom - 10,
      );
      await drag(coverEdge, Offset(-rect.width * .1, 0));
      expect(find.text('Front Cover'), findsOneWidget);
      await drag(coverEdge, Offset(-rect.width * .65, 0));
      expect(find.text('Pages 1 - 2 out of $programPageCount'), findsOneWidget);

      await drag(
        Offset(rect.right - 3, rect.bottom - 10),
        Offset(-rect.width * .12, -15),
      );
      expect(find.text('Pages 1 - 2 out of $programPageCount'), findsOneWidget);
      await drag(
        Offset(rect.right - 3, rect.bottom - 10),
        Offset(-rect.width * .7, -35),
      );
      expect(find.text('Pages 3 - 4 out of $programPageCount'), findsOneWidget);
      await drag(
        Offset(rect.left + 3, rect.top + 10),
        Offset(rect.width * .7, 30),
      );
      expect(find.text('Pages 1 - 2 out of $programPageCount'), findsOneWidget);
      // Gestures in the page body should not grab the paper.
      await drag(rect.center, Offset(-rect.width * .4, 0));
      expect(find.text('Pages 1 - 2 out of $programPageCount'), findsOneWidget);
      await tester.tap(find.byTooltip('Previous pages'));
      await tester.pumpAndSettle();
      expect(find.text('Front Cover'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('Fits a narrow phone screen', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const MyApp(animateSponsors: false));
    await tester.tap(find.byTooltip('Next pages'));
    await tester.pumpAndSettle();
    expect(find.text('Page 1 out of $programPageCount'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
