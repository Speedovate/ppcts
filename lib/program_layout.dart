import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'program_content.dart';
import 'bio_content.dart';
import 'speaker_photos.dart';
import 'sponsor_content.dart';

const _navy = Color(0xFF132051);
const _gold = Color(0xFFE4AA19);

String programStartTime(String time) {
  final value = time.split(' · ').first.trim();
  if (value.isEmpty) return '—';
  final start = value.split(RegExp(r'\s*[-–—]\s*')).first.trim();
  final period = RegExp(r'\b(AM|PM)\b', caseSensitive: false);
  final clock = RegExp(r'^(\d{1,2}):(\d{2})').firstMatch(start);
  if (clock == null) return '—';
  final hour = int.parse(clock.group(1)!);
  final suffix =
      period.firstMatch(value)?.group(0)?.toUpperCase() ??
      (hour >= 12 ? 'PM' : 'AM');
  final displayHour = (hour % 12 == 0 ? 12 : hour % 12).toString().padLeft(
    2,
    '0',
  );
  return '$displayHour:${clock.group(2)} $suffix';
}

String _displayTitle(String title) {
  const acronyms = {'Q&A', 'AVP', 'AM', 'PM', 'MICE', 'CBST', 'DOT', 'LED'};
  const minorWords = {
    'a',
    'an',
    'the',
    'and',
    'or',
    'of',
    'in',
    'on',
    'at',
    'to',
    'for',
    'by',
  };
  final words = RegExp(
    r"[A-Za-z]+(?:['’&][A-Za-z]+)*",
  ).allMatches(title).toList();
  var index = 0;
  return title.replaceAllMapped(RegExp(r"[A-Za-z]+(?:['’&][A-Za-z]+)*"), (
    match,
  ) {
    final word = match.group(0)!;
    final upper = word.toUpperCase();
    final lower = word.toLowerCase();
    final firstOrLast = index == 0 || index == words.length - 1;
    final afterColon = RegExp(
      r'[:–—]\s*$',
    ).hasMatch(title.substring(0, match.start));
    index++;
    if (acronyms.contains(upper)) return upper;
    if (!firstOrLast && !afterColon && minorWords.contains(lower)) return lower;
    return lower[0].toUpperCase() + lower.substring(1);
  });
}

TextPainter _label(
  String text,
  double size,
  Color color,
  double width, {
  FontWeight weight = FontWeight.normal,
  double height = 1.28,
  TextAlign textAlign = TextAlign.left,
}) => TextPainter(
  text: TextSpan(
    text: text,
    style: TextStyle(
      fontFamily: 'sans-serif',
      fontSize: size,
      color: color,
      fontWeight: weight,
      height: height,
    ),
  ),
  textDirection: TextDirection.ltr,
  textAlign: textAlign,
)..layout(maxWidth: width);

class _ProgramRow {
  _ProgramRow(this.title, this.speaker, this.time, this.height, this.parts);
  final TextPainter title, time;
  final List<TextPainter> parts;
  final _RepresentativeLayout speaker;
  final double height;
  void dispose() {
    title.dispose();
    speaker.dispose();
    time.dispose();
    for (final part in parts) {
      part.dispose();
    }
  }
}

class _RepresentativeLayout {
  final _parts = <({TextPainter text, Offset offset})>[];
  double height = 0;

  void paint(Canvas canvas, Offset offset) {
    for (final part in _parts) {
      part.text.paint(canvas, offset + part.offset);
    }
  }

  void dispose() {
    for (final part in _parts) {
      part.text.dispose();
    }
  }
}

_RepresentativeLayout _representativeLabel(String value) {
  final lines = value
      .split('\n')
      .map(
        (line) => line
            .replaceFirst(
              RegExp(
                r'^\s*(?:Speakers?|Hosts?|Moderators?|Panelists?):\s*',
                caseSensitive: false,
              ),
              '',
            )
            .trim(),
      )
      .where((line) => line.isNotEmpty)
      .toList();
  final result = _RepresentativeLayout();
  if (lines.isEmpty) {
    // Reserve one text line without painting a placeholder on the canvas.
    final spacer = _representativeText(' ', 158);
    result.height = spacer.height;
    spacer.dispose();
    return result;
  }
  for (final line in lines) {
    final bulleted = line.startsWith('•');
    if (bulleted && result.height > 0) result.height += 12;
    var text = bulleted ? line.substring(1).trimLeft() : line;
    // Put the position below every name, preserving commas within the position.
    final separator = text.indexOf(',');
    if (separator >= 0) {
      text =
          '${text.substring(0, separator).trimRight()}\n'
          '${text.substring(separator + 1).trimLeft()}';
    }
    final painter = _representativeText(text, 158);
    result._parts.add((text: painter, offset: Offset(0, result.height)));
    result.height += painter.height;
  }
  return result;
}

TextPainter _representativeText(String text, double width) {
  final names = RegExp(programSpeakerNames.map(RegExp.escape).join('|'));
  final spans = <TextSpan>[];
  var cursor = 0;
  for (final match in names.allMatches(text)) {
    final name = match.group(0)!.trimRight();
    final start = match.start;
    spans.add(TextSpan(text: text.substring(cursor, start)));
    spans.add(
      TextSpan(
        text: name,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
    cursor = start + name.length;
  }
  spans.add(TextSpan(text: text.substring(cursor)));
  return TextPainter(
    text: TextSpan(
      children: spans,
      style: const TextStyle(
        fontFamily: 'sans-serif',
        fontSize: 9.5,
        color: _navy,
        fontWeight: FontWeight.normal,
        height: 1.28,
      ),
    ),
    textDirection: TextDirection.ltr,
  )..layout(maxWidth: width);
}

_ProgramRow _measureRow(ProgramEntry entry) {
  final time = _label(
    programStartTime(entry.time),
    9.5,
    _navy,
    double.infinity,
  );
  final titleLeft = 24 + time.width + 12;
  final title = _label(
    _displayTitle(entry.title),
    9.5,
    _navy,
    328 - 12 - titleLeft,
  );
  final speaker = _representativeLabel(entry.speaker);
  final parts = <TextPainter>[];
  for (final line in entry.details.split('\n')) {
    if (line.trim().isEmpty) continue;
    final separator = line.indexOf(':');
    final text = separator < 0
        ? line
        : '${line.substring(0, separator)}\n${line.substring(separator + 1).trim()}';
    parts.add(_label(text, 9, _navy, 328 - 12 - titleLeft, height: 1.35));
  }
  final titleHeight =
      title.height +
      parts.fold<double>(0, (height, part) => height + 8 + part.height);
  final height =
      math.max(titleHeight, math.max(speaker.height, time.height)) + 12;
  return _ProgramRow(title, speaker, time, height, parts);
}

List<List<ProgramEntry>> paginateProgram(Iterable<ProgramEntry> entries) {
  final pages = <List<ProgramEntry>>[];
  var page = <ProgramEntry>[];
  var used = 0.0;
  for (final entry in entries) {
    final row = _measureRow(entry);
    final height = row.height;
    row.dispose();
    if (height > 467) {
      throw StateError('Program entry is taller than a page: ${entry.title}');
    }
    if (page.isNotEmpty &&
        (page.first.day != entry.day || used + height > 467)) {
      pages.add(List.unmodifiable(page));
      page = [];
      used = 0;
    }
    page.add(entry);
    used += height;
  }
  if (page.isNotEmpty) pages.add(List.unmodifiable(page));
  return List.unmodifiable(pages);
}

final programBookPages = paginateProgram(
  programPages.expand((page) => page.entries),
);
const sponsorPageCount = 4;
const bioPhotoDiameter = 64.0;
const _bioHeadingWidth = 462 - bioPhotoDiameter - 16;
List<BioNote> paginateBios(Iterable<BioNote> notes) {
  double measure(
    String text,
    double size, {
    double height = 1.28,
    FontWeight weight = FontWeight.normal,
    double width = 462,
  }) {
    final painter = _label(
      text,
      size,
      _navy,
      width,
      height: height,
      weight: weight,
    );
    final result = painter.height;
    painter.dispose();
    return result;
  }

  final pages = <BioNote>[];
  for (final note in notes) {
    final heading = math.max(
      bioPhotoDiameter,
      measure(note.name, 17, weight: FontWeight.bold, width: _bioHeadingWidth) +
          measure(note.role, 10.5, width: _bioHeadingWidth),
    );
    var paragraphs = <String>[];
    var used = heading;
    var continuation = false;
    void finish() {
      pages.add(
        BioNote(
          note.name,
          note.role,
          List.unmodifiable(paragraphs),
          isContinuation: continuation,
        ),
      );
      paragraphs = [];
      used = 0;
      continuation = true;
    }

    for (
      var paragraphIndex = 0;
      paragraphIndex < note.paragraphs.length;
      paragraphIndex++
    ) {
      final paragraph = note.paragraphs[paragraphIndex];
      final reserveSignature =
          note.name == 'HON. LUCILO R. BAYRON' &&
          paragraphIndex == note.paragraphs.length - 1;
      final pageLimit = reserveSignature ? 343 : 467;
      var remaining = paragraph;
      while (remaining.isNotEmpty) {
        final gap = continuation && paragraphs.isEmpty ? 0.0 : 12.0;
        final height = gap + measure(remaining, 10.5, height: 1.4);
        if (used + height <= pageLimit) {
          paragraphs.add(remaining);
          used += height;
          break;
        }
        if (paragraphs.isNotEmpty) {
          finish();
          continue;
        }
        // Split unusually long paragraphs at word boundaries, without reducing type size.
        final words = remaining.split(' ');
        var low = 1;
        var high = words.length;
        var fit = 0;
        while (low <= high) {
          final mid = (low + high) ~/ 2;
          if (used +
                  gap +
                  measure(words.take(mid).join(' '), 10.5, height: 1.4) <=
              pageLimit) {
            fit = mid;
            low = mid + 1;
          } else {
            high = mid - 1;
          }
        }
        if (fit == 0) {
          throw StateError('Biography heading leaves no space: ${note.name}');
        }
        paragraphs.add(words.take(fit).join(' '));
        remaining = words.skip(fit).join(' ');
        finish();
      }
    }
    if (paragraphs.isNotEmpty) finish();
  }
  return List.unmodifiable(pages);
}

final bioBookPages = paginateBios(bioNotes);
int get bioStartIndex => sponsorPageCount + programBookPages.length;
int get programPageCount => bioStartIndex + bioBookPages.length;
int get programSpreadCount => (programPageCount + 1) ~/ 2;
int get programFaceCount => programSpreadCount * 2;
int get programClosingSpread => programPageCount ~/ 2;

/// Fixed readable type size; pagination handles overflow instead of shrinking text.
class ProgramLayout {
  ProgramLayout(
    this.index, {
    this.brandingImage,
    this.pageLogos = const [],
    this.speakerImages = const {},
  }) {
    if (index >= sponsorPageCount && index < bioStartIndex) {
      _rows.addAll(programBookPages[index - sponsorPageCount].map(_measureRow));
    }
    if (index >= bioStartIndex && index < programPageCount) {
      final bio = bioBookPages[index - bioStartIndex];
      if (!bio.isContinuation) {
        _bioText.add(
          _label(
            bio.name,
            17,
            _navy,
            _bioHeadingWidth,
            weight: FontWeight.bold,
          ),
        );
        _bioText.add(_label(bio.role, 10.5, _navy, _bioHeadingWidth));
      }
      for (final paragraph in bio.paragraphs) {
        _bioText.add(
          _label(
            paragraph,
            10.5,
            _navy,
            462,
            height: 1.4,
            textAlign: TextAlign.justify,
          ),
        );
      }
    }
  }
  final int index;
  final ui.Image? brandingImage;
  final List<ui.Image> pageLogos;
  final Map<String, ui.Image> speakerImages;
  final _rows = <_ProgramRow>[];
  final _bioText = <TextPainter>[];
  bool get hasBioHeading =>
      index >= bioStartIndex &&
      index < programPageCount &&
      !bioBookPages[index - bioStartIndex].isContinuation;
  bool get hasMayorSignature =>
      index >= bioStartIndex &&
      index < programPageCount &&
      bioBookPages[index - bioStartIndex].name == 'HON. LUCILO R. BAYRON' &&
      (index + 1 == programPageCount ||
          bioBookPages[index + 1 - bioStartIndex].name !=
              'HON. LUCILO R. BAYRON');
  int get _bioHeadingCount => hasBioHeading ? 2 : 0;
  double get _bioHeadingHeight => hasBioHeading
      ? math.max(bioPhotoDiameter, _bioText[0].height + _bioText[1].height)
      : 0;
  double get contentHeight => _bioText.isNotEmpty
      ? _bioHeadingHeight +
            _bioText
                .skip(_bioHeadingCount)
                .fold<double>(0, (sum, text) => sum + text.height) +
            math.max(
                  0,
                  _bioText.length - _bioHeadingCount - (hasBioHeading ? 0 : 1),
                ) *
                12
      : _rows.fold(0.0, (sum, row) => sum + row.height);

  void paint(Canvas canvas) {
    canvas.drawRect(
      const Rect.fromLTWH(0, 0, 510, 660),
      Paint()..color = Colors.white,
    );
    if (index >= programPageCount) return;

    if (brandingImage case final image?) {
      final source = Size(image.width.toDouble(), image.height.toDouble());
      final fitted = applyBoxFit(BoxFit.contain, source, const Size(138, 82));
      canvas.drawImageRect(
        image,
        Offset.zero & source,
        Alignment.center.inscribe(
          fitted.destination,
          const Rect.fromLTWH(24, 24, 138, 94),
        ),
        Paint()..filterQuality = FilterQuality.medium,
      );
    }
    const logoHeight = 60.0;
    const logoGap = 12.0;
    final logoWidths = [
      for (final logo in pageLogos) logoHeight * logo.width / logo.height,
    ];
    var logoX =
        486.0 -
        logoWidths.fold(0.0, (sum, width) => sum + width) -
        math.max(0, pageLogos.length - 1) * logoGap;
    for (var i = 0; i < pageLogos.length; i++) {
      final logo = pageLogos[i];
      canvas.drawImageRect(
        logo,
        Rect.fromLTWH(0, 0, logo.width.toDouble(), logo.height.toDouble()),
        Rect.fromLTWH(logoX, 41, logoWidths[i], logoHeight),
        Paint()..filterQuality = FilterQuality.medium,
      );
      logoX += logoWidths[i] + logoGap;
    }
    canvas.drawLine(
      const Offset(24, 135),
      const Offset(486, 135),
      Paint()
        ..color = _gold
        ..strokeWidth = 1.5,
    );
    if (index < 3) {
      final heading = _label(
        sponsors[index].heading,
        18,
        _navy,
        462,
        weight: FontWeight.bold,
      );
      heading.paint(canvas, Offset((510 - heading.width) / 2, 164));
      heading.dispose();
    }
    var y = 147.0;
    if (hasBioHeading) {
      final headingHeight = _bioHeadingHeight;
      final headingY =
          y + (headingHeight - _bioText[0].height - _bioText[1].height) / 2;
      _bioText[0].paint(canvas, Offset(24 + bioPhotoDiameter + 16, headingY));
      _bioText[1].paint(
        canvas,
        Offset(24 + bioPhotoDiameter + 16, headingY + _bioText[0].height),
      );
      final center = Offset(24 + bioPhotoDiameter / 2, y + headingHeight / 2);
      canvas.drawCircle(
        center,
        bioPhotoDiameter / 2,
        Paint()..color = const Color(0xFFEAF4FB),
      );
      canvas.drawCircle(
        center,
        bioPhotoDiameter / 2,
        Paint()
          ..color = const Color(0xFFCDDAEC)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1,
      );
      final name = bioBookPages[index - bioStartIndex].name;
      final image = speakerImages[name];
      final photo = speakerPhotos[name];
      if (image != null && photo != null) {
        final target = Rect.fromCircle(
          center: center,
          radius: bioPhotoDiameter / 2,
        );
        final crop = photo.crop;
        final source = Rect.fromLTWH(
          crop.left * image.width,
          crop.top * image.height,
          crop.width * image.width,
          crop.height * image.height,
        );
        canvas.save();
        canvas.clipPath(Path()..addOval(target));
        canvas.drawImageRect(
          image,
          source,
          target,
          Paint()..filterQuality = FilterQuality.medium,
        );
        canvas.restore();
      } else {
        final silhouette = Paint()..color = const Color(0xFF9EAFCC);
        canvas.drawCircle(center.translate(0, -9.6), 8, silhouette);
        canvas.drawRRect(
          RRect.fromRectAndCorners(
            Rect.fromCenter(
              center: center.translate(0, 10.4),
              width: 28.8,
              height: 17.6,
            ),
            topLeft: const Radius.circular(14.4),
            topRight: const Radius.circular(14.4),
            bottomLeft: const Radius.circular(3.2),
            bottomRight: const Radius.circular(3.2),
          ),
          silhouette,
        );
      }
      y += headingHeight;
    }
    for (var i = _bioHeadingCount; i < _bioText.length; i++) {
      final text = _bioText[i];
      if (hasBioHeading || i > 0) y += 12;
      text.paint(canvas, Offset(24, y));
      y += text.height;
    }
    if (hasMayorSignature) {
      final signature = speakerImages['mayor_signature'];
      if (signature != null) {
        const width = 108.0;
        final height = width * signature.height / signature.width;
        canvas.drawImageRect(
          signature,
          Rect.fromLTWH(
            0,
            0,
            signature.width.toDouble(),
            signature.height.toDouble(),
          ),
          Rect.fromLTWH(486 - width, 614 - height, width, height),
          Paint()..filterQuality = FilterQuality.medium,
        );
      }
    }
    for (var i = 0; i < _rows.length; i++) {
      final row = _rows[i];
      row.time.paint(canvas, Offset(24, y));
      row.title.paint(canvas, Offset(24 + row.time.width + 12, y));
      var partY = y + row.title.height;
      for (final part in row.parts) {
        partY += 8;
        part.paint(canvas, Offset(24 + row.time.width + 12, partY));
        partY += part.height;
      }
      row.speaker.paint(canvas, Offset(328, y));
      y += row.height;
    }
    canvas.drawRect(
      const Rect.fromLTWH(0, 622, 510, 38),
      Paint()..color = index < sponsorPageCount ? Colors.white : _navy,
    );
    final pageNumber = TextPainter(
      text: TextSpan(
        style: TextStyle(
          fontFamily: 'sans-serif',
          fontSize: index < sponsorPageCount ? 15 : 14,
          fontWeight: FontWeight.bold,
          height: 1.28,
          color: index < sponsorPageCount ? _navy : Colors.white,
        ),
        children: [
          TextSpan(text: 'Page ${index + 1}'),
          TextSpan(
            text: index >= bioStartIndex
                ? (bioBookPages[index - bioStartIndex].name ==
                          'HON. LUCILO R. BAYRON'
                      ? '   |   Message'
                      : '   |   Bio Notes')
                : '   |   Day ${index < sponsorPageCount ? 1 : programBookPages[index - sponsorPageCount].first.day}',
            style: TextStyle(
              color: index < sponsorPageCount ? const Color(0xFF007BFF) : _gold,
            ),
          ),
        ],
      ),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: 462);
    pageNumber.paint(
      canvas,
      Offset(index.isEven ? 24 : 486 - pageNumber.width, 631),
    );
    pageNumber.dispose();
  }

  void dispose() {
    for (final text in _bioText) {
      text.dispose();
    }
    for (final row in _rows) {
      row.dispose();
    }
  }
}
