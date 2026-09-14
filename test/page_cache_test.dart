import 'dart:ui' as ui;
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flipbook/program_layout.dart' show bioStartIndex;

import 'package:flipbook/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _DelayedAssets extends CachingAssetBundle {
  _DelayedAssets(this.path);
  final String path;
  final release = Completer<void>();
  final requested = Completer<void>();
  @override
  Future<ByteData> load(String key) async {
    if (key.contains(path)) {
      if (!requested.isCompleted) requested.complete();
      await release.future;
    }
    return rootBundle.load(key);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'Unloaded faces show a centered animated ring on opaque paper',
    () async {
      final cache = PageRasterCache();
      addTearDown(cache.dispose);
      Future<List<int>> pixel(int index, double phase, int x, int y) async {
        final recorder = ui.PictureRecorder();
        cache.draw(Canvas(recorder), index, loadingProgress: phase);
        final picture = recorder.endRecording();
        final image = await picture.toImage(510, 660);
        final bytes = (await image.toByteData())!;
        final offset = (y * 510 + x) * 4;
        final result = List<int>.generate(4, (i) => bytes.getUint8(offset + i));
        image.dispose();
        picture.dispose();
        return result;
      }

      for (final index in [-1, 0, programFaceCount]) {
        final background = await pixel(index, 0, 255, 330);
        final ring = await pixel(index, 0, 273, 330);
        final rotatedRing = await pixel(index, .5, 273, 330);
        expect(background[3], 255);
        expect(ring[3], 255);
        expect(ring, isNot(background));
        expect(rotatedRing, isNot(ring));
      }
    },
  );

  for (final delay in {
    'back_cover.jpg': 1,
    'summit_branding.png': 2,
    '/speakers/': bioStartIndex + 2,
  }.entries) {
    test('Earlier pages render before delayed ${delay.key}', () async {
      final assets = _DelayedAssets(delay.key);
      final cache = PageRasterCache(assetBundle: assets);
      addTearDown(cache.dispose);
      final warming = cache.warm(1);
      try {
        await assets.requested.future;
        expect(cache.rasterizedFaces, delay.value);
        expect(cache.allFacesReady, isFalse);
      } finally {
        assets.release.complete();
        await warming;
      }
      expect(cache.allFacesReady, isTrue);
    });
  }

  test('Faces are reused across frames and resolution is capped', () async {
    final cache = PageRasterCache();
    addTearDown(cache.dispose);
    var updates = 0;
    cache.addListener(() => updates++);
    expect(cache.allFacesReady, isFalse);
    await cache.warm(1);
    expect(cache.allFacesReady, isTrue);
    expect(cache.recordedFaces, programFaceCount + 2);
    expect(cache.rasterizedFaces, programFaceCount + 2);
    expect(updates, programFaceCount + 2);
    await cache.warm(.8);
    await cache.warm(1);
    expect(updates, programFaceCount + 2);
    await cache.warm(2);
    expect(cache.recordedFaces, programFaceCount + 2);
    expect(cache.rasterizedFaces, programFaceCount + 2);
    expect(updates, (programFaceCount + 2) * 2);
    await cache.warm(4);
    expect(updates, (programFaceCount + 2) * 2);
  });

  test('Disposal cancels warming without publishing late images', () async {
    final cache = PageRasterCache();
    var updates = 0;
    cache.addListener(() => updates++);
    final warming = cache.warm(1);
    cache.dispose();
    await warming;
    expect(updates, 0);
    expect(cache.rasterizedFaces, 0);
    expect(cache.recordedFaces, 0);
  });

  testWidgets(
    'Drag and settling frames repaint without rebuilding the screen',
    (tester) async {
      await tester.pumpWidget(
        const MyApp(animateSponsors: false, animateLoading: false),
      );
      final rect = tester.getRect(find.byKey(const Key('book')));
      final gesture = await tester.startGesture(
        Offset(rect.left + rect.width * .75 - 3, rect.bottom - 10),
      );
      await gesture.moveBy(const Offset(-25, 0));
      await tester.pump();
      final screen = tester.widget(find.byType(Scaffold));
      for (var i = 0; i < 8; i++) {
        await gesture.moveBy(const Offset(-15, -3));
        await tester.pump(const Duration(milliseconds: 16));
        expect(identical(tester.widget(find.byType(Scaffold)), screen), isTrue);
      }
      await gesture.up();
      for (var i = 0; i < 8; i++) {
        await tester.pump(const Duration(milliseconds: 16));
        expect(identical(tester.widget(find.byType(Scaffold)), screen), isTrue);
      }
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    },
  );
}
