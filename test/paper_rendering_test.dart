import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flipbook/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'Closed covers hide the paper stack at rest and at the end of a turn',
    () async {
      final cache = PageRasterCache();
      await cache.warm(1);
      addTearDown(cache.dispose);
      for (final state in [
        (-1, 0),
        (programSpreadCount, 0),
        (0, -1),
        (programSpreadCount - 1, 1),
      ]) {
        final recorder = ui.PictureRecorder();
        final canvas = Canvas(recorder)..drawColor(Colors.red, BlendMode.src);
        BookPainter(
          cache: cache,
          spread: state.$1,
          direction: state.$2,
          corner: const Offset(510, 660),
          drag: Offset(state.$2 == 0 ? 510 : -510, 660),
        ).paint(canvas, const Size(1020, 660));
        final picture = recorder.endRecording();
        final image = await picture.toImage(1020, 680);
        final pixels = (await image.toByteData())!;
        image.dispose();
        picture.dispose();
        for (var y = 0; y < 670; y++) {
          for (var x = 249; x < 772; x++) {
            if (x >= 255 && x < 765 && y < 660) continue;
            final pixel = (y * 1020 + x) * 4;
            // Neither paper nor a navy binding may extend beyond the cover.
            expect(
              pixels.getUint8(pixel),
              (Colors.red.r * 255).round(),
              reason: 'Binding exposed at ($x, $y), state $state',
            );
            expect(
              pixels.getUint8(pixel + 1),
              lessThan(100),
              reason: 'Paper exposed at ($x, $y), state $state',
            );
            expect(
              pixels.getUint8(pixel + 2),
              lessThan(100),
              reason: 'Paper exposed at ($x, $y), state $state',
            );
          }
        }
      }
    },
  );

  test('Flat and folded faces fully hide contrasting backgrounds', () async {
    final cache = PageRasterCache();
    await cache.warm(1);
    addTearDown(cache.dispose);
    for (final corner in [const Offset(510, 0), const Offset(510, 660)]) {
      for (final isCover in [false, true]) {
        final drag = Offset(100, corner.dy == 0 ? 120 : 540);
        final painter = BookPainter(
          cache: cache,
          spread: isCover ? -1 : 1,
          direction: 1,
          corner: corner,
          drag: drag,
        );
        Future<ByteData> render(Color background) async {
          final recorder = ui.PictureRecorder();
          final canvas = Canvas(recorder);
          canvas.drawColor(background, BlendMode.src);
          canvas.translate(510, 150);
          painter.paintSheet(
            canvas,
            drawFront: isCover ? painter.cover : (c) => painter.page(c, 2),
            drawBack: (c) => painter.page(c, isCover ? 0 : 3),
          );
          final picture = recorder.endRecording();
          final image = await picture.toImage(1100, 1020);
          final data = (await image.toByteData())!;
          image.dispose();
          picture.dispose();
          return data;
        }

        final red = await render(Colors.red);
        final blue = await render(Colors.blue);
        final n = (corner - drag) / (corner - drag).distance;
        final middle = (corner + drag) / 2;
        const rect = [
          Offset.zero,
          Offset(510, 0),
          Offset(510, 660),
          Offset(0, 660),
        ];
        Offset reflect(Offset p) =>
            p -
            n * (2 * ((p.dx - middle.dx) * n.dx + (p.dy - middle.dy) * n.dy));
        final flat = painter.polygon(painter.halfPlane(rect, middle, n, false));
        final folded = painter.polygon(
          painter.halfPlane(rect, middle, n, true).map(reflect).toList(),
        );
        for (final face in [flat, folded]) {
          var checked = 0;
          for (var y = 10; y < 650; y += 20) {
            for (var x = -480; x < 510; x += 20) {
              final point = Offset(x.toDouble(), y.toDouble());
              // Exclude antialiased silhouettes; inspect the actual paper surface.
              if (![
                point,
                point + const Offset(3, 3),
                point - const Offset(3, 3),
                point + const Offset(3, -3),
                point + const Offset(-3, 3),
              ].every(face.contains)) {
                continue;
              }
              final pixel = ((y + 150) * 1100 + x + 510) * 4;
              expect(
                red.getUint32(pixel),
                blue.getUint32(pixel),
                reason:
                    'Underlying color leaked through at $point, cover: $isCover, corner: $corner',
              );
              checked++;
            }
          }
          expect(checked, greaterThan(30));
        }
      }
    }
  });
}
