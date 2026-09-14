import 'dart:io';
import 'package:flutter/services.dart';
import 'dart:ui' as ui;
import 'package:flipbook/bio_content.dart';
import 'package:flipbook/speaker_photos.dart';
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
    expect(bioNotes.length, 11);
    for (final note in bioNotes) {
      final pages = bioBookPages.where((page) => page.name == note.name);
      expect(pages, isNotEmpty);
      expect(pages.first.isContinuation, isFalse);
      expect(pages.skip(1).every((page) => page.isContinuation), isTrue);
      expect(
        pages.expand((page) => page.paragraphs).join(' '),
        note.paragraphs.join(' '),
      );
      expect(pages.every((page) => page.role == note.role), isTrue);
    }
    final allEntries = programPages.expand((page) => page.entries).toList();
    expect(allEntries.where((entry) => entry.day == 1).length, 33);
    expect(allEntries.where((entry) => entry.day == 2).length, 31);
    expect(allEntries.last.title, 'End of Summit');
    expect(allEntries.last.time, '05:30 PM');
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
      greaterThan(programBookPages.length),
    );
    expect(
      speakerPhotos.keys,
      unorderedEquals(bioNotes.map((note) => note.name)),
    );
    final portraits = <String, ui.Image>{};
    for (final entry in speakerPhotos.entries) {
      final data = await rootBundle.load(
        'assets/images/speakers/${entry.value.asset}',
      );
      final codec = await ui.instantiateImageCodec(
        data.buffer.asUint8List(),
        targetWidth: 384,
      );
      portraits[entry.key] = (await codec.getNextFrame()).image;
      codec.dispose();
    }
    addTearDown(() {
      for (final image in portraits.values) {
        image.dispose();
      }
    });
    final painter = BookPainter(
      speakerImages: portraits,
      spread: 0,
      direction: 0,
      corner: const Offset(510, 660),
      drag: const Offset(510, 660),
    );
    for (var index = 0; index < programPageCount; index++) {
      final layout = ProgramLayout(index);
      if (index >= bioStartIndex) {
        expect(
          layout.hasBioHeading,
          !bioBookPages[index - bioStartIndex].isContinuation,
        );
      }
      // Long biographies need real font metrics; Ahem gives every glyph a
      // square advance. The preview run above loads Arial for this check.
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
