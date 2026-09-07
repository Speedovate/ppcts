import 'package:flipbook/main.dart';

String spreadLabel(int spread) => spread * 2 + 2 > programPageCount
    ? 'Page ${spread * 2 + 1} out of $programPageCount'
    : 'Pages ${spread * 2 + 1} - ${spread * 2 + 2} out of $programPageCount';
