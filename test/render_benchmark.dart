// Manual headless rendering benchmark; timings are informational, not assertions.
import 'dart:ui' as ui;
import 'package:flipbook/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('Record and rasterize a page turn', () async {
    final cache = PageRasterCache();
    await cache.warm(1);
    addTearDown(cache.dispose);
    var recordingMicros = 0;
    var rasterMicros = 0;
    for (var i = 0; i < 40; i++) {
      final recorder = ui.PictureRecorder();
      final clock = Stopwatch()..start();
      BookPainter(
        cache: cache,
        spread: 1,
        direction: 1,
        corner: const Offset(510, 660),
        drag: Offset(480 - i * 24, 550),
      ).paint(Canvas(recorder), const Size(1020, 660));
      final picture = recorder.endRecording();
      clock.stop();
      if (i >= 10) recordingMicros += clock.elapsedMicroseconds;
      clock.reset();
      clock.start();
      final image = await picture.toImage(1020, 660);
      await image.toByteData();
      clock.stop();
      if (i >= 10) rasterMicros += clock.elapsedMicroseconds;
      image.dispose();
      picture.dispose();
    }
    // ignore: avoid_print
    print(
      'Mean over 30 warmed frames: record=${recordingMicros / 30000}ms, raster+readback=${rasterMicros / 30000}ms',
    );
  });
}
