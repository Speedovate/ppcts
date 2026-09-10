import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'program_content.dart';
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
)..layout(maxWidth: width);

class _ProgramRow {
  _ProgramRow(this.title, this.speaker, this.time, this.height);
  final TextPainter title, time;
  final _RepresentativeLayout speaker;
  final double height;
  void dispose() {
    title.dispose();
    speaker.dispose();
    time.dispose();
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
    var text = bulleted ? line.substring(1).trimLeft() : line;
    var indent = 0.0;
    if (bulleted) {
      final bullet = _label('• ', 10, _navy, double.infinity);
      indent = bullet.width;
      result._parts.add((text: bullet, offset: Offset(0, result.height)));
    }
    // Put the position below every name, preserving commas within the position.
    final separator = text.indexOf(',');
    if (separator >= 0) {
      text =
          '${text.substring(0, separator).trimRight()}\n'
          '${text.substring(separator + 1).trimLeft()}';
    }
    final painter = _representativeText(text, 158 - indent);
    result._parts.add((text: painter, offset: Offset(indent, result.height)));
    result.height += painter.height;
  }
  return result;
}

TextPainter _representativeText(String text, double width) {
  final names = RegExp(
    r'(?:Mr\.|Ms\.|Hon\.|Atty\.|Engr\.|Arch\.|Coach|Sir|Mayor)\s+([^\n,–(]+)|\b(Roberto P\. Alabado III)\b',
  );
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
        fontSize: 10,
        color: _navy,
        fontWeight: FontWeight.normal,
        height: 1.28,
      ),
    ),
    textDirection: TextDirection.ltr,
  )..layout(maxWidth: width);
}

_ProgramRow _measureRow(ProgramEntry entry) {
  final time = _label(programStartTime(entry.time), 10, _navy, double.infinity);
  final titleLeft = 24 + time.width + 12;
  final title = _label(
    _displayTitle(entry.title),
    10,
    _navy,
    328 - 12 - titleLeft,
  );
  final speaker = _representativeLabel(entry.speaker);
  final height =
      math.max(title.height, math.max(speaker.height, time.height)) + 12;
  return _ProgramRow(title, speaker, time, height);
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
const sponsorPageCount = 2;
int get programPageCount => sponsorPageCount + programBookPages.length;
int get programSpreadCount => (programPageCount + 1) ~/ 2;
int get programFaceCount => programSpreadCount * 2;
int get programClosingSpread => programPageCount ~/ 2;

/// Fixed readable type size; pagination handles overflow instead of shrinking text.
class ProgramLayout {
  ProgramLayout(this.index, {this.brandingImage, this.pageLogos = const []}) {
    if (index >= sponsorPageCount && index < programPageCount) {
      _rows.addAll(programBookPages[index - sponsorPageCount].map(_measureRow));
    }
  }
  final int index;
  final ui.Image? brandingImage;
  final List<ui.Image> pageLogos;
  final _rows = <_ProgramRow>[];
  double get contentHeight => _rows.fold(0.0, (sum, row) => sum + row.height);

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
    if (index < sponsorPageCount) {
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
    for (var i = 0; i < _rows.length; i++) {
      final row = _rows[i];
      row.time.paint(canvas, Offset(24, y));
      row.title.paint(canvas, Offset(24 + row.time.width + 12, y));
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
          fontSize: 15,
          fontWeight: FontWeight.bold,
          height: 1.28,
          color: index < sponsorPageCount ? _navy : Colors.white,
        ),
        children: [
          TextSpan(text: 'Page ${index + 1}'),
          TextSpan(
            text:
                '   |   Day ${index < sponsorPageCount ? 1 : programBookPages[index - sponsorPageCount].first.day}',
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
    for (final row in _rows) {
      row.dispose();
    }
  }
}
