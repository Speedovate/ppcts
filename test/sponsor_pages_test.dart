import 'dart:ui' as ui;
import 'package:flipbook/main.dart';
import 'package:flipbook/sponsor_content.dart';
import 'package:flipbook/program_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('Sponsor click reveals details and contact copy menu', (
    tester,
  ) async {
    String? copied;
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'Clipboard.setData') {
          copied = (call.arguments as Map)['text'] as String;
        }
        return null;
      },
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      ),
    );
    await tester.pumpWidget(
      const MyApp(animateSponsors: false, animateLoading: false),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Next pages'));
    await tester.pumpAndSettle();
    final book = tester.getRect(find.byKey(const Key('book')));
    Offset at(double x, double y) => Offset(
      book.left + book.width * x / 1020,
      book.top + book.height * y / 660,
    );
    BookPainter painter() => tester
        .widgetList<CustomPaint>(find.byType(CustomPaint))
        .map((w) => w.painter)
        .whereType<BookPainter>()
        .single;
    await tester.tapAt(at(255, 390));
    await tester.pumpAndSettle();
    expect(painter().expandedSponsors, contains(0));
    for (var row = 0; row < 3; row++) {
      await tester.tapAt(
        at(210, sponsors[0].contactBounds.top + 14 + row * 38),
      );
      await tester.pumpAndSettle();
      expect(find.text('Copy'), findsOneWidget);
      expect(find.text(['Call', 'Email', 'Visit'][row]), findsOneWidget);
      await tester.tap(find.text('Copy'));
      await tester.pumpAndSettle();
    }
    expect(copied, 'www.speedovate.com');
    await tester.tapAt(at(255, 335));
    await tester.pumpAndSettle();
    expect(painter().expandedSponsors, isEmpty);
  });

  testWidgets('Sponsor pulse continues across cycles and stops off screen', (
    tester,
  ) async {
    await tester.pumpWidget(const MyApp(animateLoading: false));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Next pages'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 700));
    await tester.pump();
    final painter = tester
        .widgetList<CustomPaint>(find.byType(CustomPaint))
        .map((widget) => widget.painter)
        .whereType<BookPainter>()
        .single;
    final pulse = painter.sponsorPulse!;
    await tester.pump(const Duration(milliseconds: 275));
    final first = pulse.value;
    await tester.pump(const Duration(milliseconds: 1100));
    expect(pulse.value, closeTo(first, .001));
    await tester.pump(const Duration(milliseconds: 275));
    expect(pulse.value, isNot(closeTo(first, .001)));
    await tester.tap(find.byTooltip('Next pages'));
    await tester.pumpAndSettle();
    final stopped = pulse.value;
    await tester.pump(const Duration(seconds: 3));
    expect(pulse.value, stopped);
  });

  test(
    'Sponsor pages precede the full program and animate only their logos',
    () async {
      expect(programPageCount, programBookPages.length + 2);
      for (var index = 0; index < 2; index++) {
        final layout = ProgramLayout(index);
        expect(layout.contentHeight, 0);
        layout.dispose();
      }
      final firstProgram = ProgramLayout(2);
      expect(firstProgram.contentHeight, greaterThan(0));
      firstProgram.dispose();
      final cache = PageRasterCache();
      await cache.warm(1);
      addTearDown(cache.dispose);
      Future<List<int>> render(int index, double phase) async {
        final recorder = ui.PictureRecorder();
        BookPainter(
          spread: 0,
          direction: 0,
          corner: const Offset(510, 660),
          drag: const Offset(510, 660),
          cache: cache,
          sponsorPulse: AlwaysStoppedAnimation(phase),
        ).page(Canvas(recorder), index);
        final picture = recorder.endRecording();
        final image = await picture.toImage(510, 660);
        final bytes = (await image.toByteData())!.buffer.asUint8List().toList();
        image.dispose();
        picture.dispose();
        return bytes;
      }

      for (var index = 0; index < 2; index++) {
        final rest = await render(index, 0);
        final wiggle = await render(index, .5);
        expect(rest, isNot(orderedEquals(wiggle)));
        expect(
          rest.take(510 * 200 * 4),
          orderedEquals(wiggle.take(510 * 200 * 4)),
        );
        final footerPixel = (640 * 510 + 5) * 4;
        expect(rest.sublist(footerPixel, footerPixel + 4), [
          255,
          255,
          255,
          255,
        ]);
      }
    },
  );
}
