import 'dart:io';
import 'package:flutter/services.dart';
import 'dart:ui' as ui;
import 'package:flipbook/main.dart';
import 'package:flipbook/program_content.dart';
import 'package:flipbook/program_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('Both days fit on the branded pages without mixing days', () async {
    if (Platform.environment['EXPORT_PROGRAM_PREVIEWS'] == '1') {
      final loader = FontLoader('sans-serif');
      for (final name in ['Arial.ttf', 'Arial Bold.ttf', 'Arial Italic.ttf']) {
        loader.addFont(
          File(
            '/System/Library/Fonts/Supplemental/$name',
          ).readAsBytes().then((bytes) => ByteData.sublistView(bytes)),
        );
      }
      await loader.load();
    }
    expect(
      programBookPages.expand((page) => page),
      orderedEquals(programPages.expand((page) => page.entries)),
    );
    final allEntries = programPages.expand((page) => page.entries).toList();
    expect(allEntries.where((entry) => entry.day == 1).length, 33);
    expect(allEntries.where((entry) => entry.day == 2).length, 31);
    expect(allEntries.last.title, 'End of Summit');
    expect(allEntries.last.time, '05:40 PM');
    for (final page in programBookPages) {
      expect(page.map((entry) => entry.day).toSet().length, 1);
    }
    for (var i = 0; i < programBookPages.length - 1; i++) {
      expect(
        paginateProgram([
          ...programBookPages[i],
          programBookPages[i + 1].first,
        ]).length,
        2,
        reason: 'Page ${i + 1} should be filled before starting another',
      );
    }
    final entries = programPages.expand((page) => page.entries).toList();
    expect(paginateProgram(entries.take(1)).length, 1);
    expect(
      paginateProgram([...entries, ...entries]).length,
      greaterThan(programPageCount),
    );
    final painter = BookPainter(
      spread: 0,
      direction: 0,
      corner: const Offset(510, 660),
      drag: const Offset(510, 660),
    );
    for (var index = 0; index < programPageCount; index++) {
      final layout = ProgramLayout(index);
      expect(layout.contentHeight, lessThanOrEqualTo(467));
      layout.dispose();
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder)..scale(2.0);
      painter.page(canvas, index);
      final picture = recorder.endRecording();
      final image = await picture.toImage(1020, 1320);
      if (Platform.environment['EXPORT_PROGRAM_PREVIEWS'] == '1') {
        final data = await image.toByteData(format: ui.ImageByteFormat.png);
        File(
          '/tmp/summit-program-${index + 1}.png',
        ).writeAsBytesSync(data!.buffer.asUint8List());
      }
      image.dispose();
      picture.dispose();
    }
  });
}
