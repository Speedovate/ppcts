import 'package:flipbook/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Faces are reused across frames and resolution is capped', () async {
    final cache = PageRasterCache();
    addTearDown(cache.dispose);
    var updates = 0;
    cache.addListener(() => updates++);
    await cache.warm(1);
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
      await tester.pumpWidget(const MyApp(animateSponsors: false));
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
