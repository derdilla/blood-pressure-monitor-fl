
import 'dart:collection';

import 'package:blood_pressure_app/model/export_import/column.dart';
import 'package:blood_pressure_app/model/export_import/csv_converter.dart';
import 'package:blood_pressure_app/model/export_import/record_parsing_result.dart';

/// A intermediate class usable by UI components to drive csv parsing.
class CsvRecordParsingActor {
  /// Create an intermediate object to manage a record parsing process.
  CsvRecordParsingActor(this._converter, String csvString) {
    final lines = _converter.getCsvLines(csvString);
    _firstLine = lines.removeAt(0).cast<String>();
    _bodyLines = lines.map((l) => l.cast<String>()).toList();
    _columnNames = _firstLine ?? [];

    final assumedColumns = _converter.getColumns(_columnNames);
    for (final csvName in _columnNames) {
      _columnParsers.add(assumedColumns[csvName]);
    }
  }

  final CsvConverter _converter;

  /// All lines without the first line.
  late final List<List<String>> _bodyLines;
  
  /// All lines containing data.
  UnmodifiableListView<List<String>> get dataLines {
    final lines = _bodyLines.toList();
    if(!hasHeadline && _firstLine != null) lines.insert(0, _firstLine!);
    return UnmodifiableListView(lines);
  }

  /// The first line in the csv file.
  List<String>? _firstLine;

  late List<String> _columnNames;

  /// All columns defined in the csv headline.
  List<String> get columnNames => _columnNames;

  late final List<ExportColumn?> _columnParsers = [];

  /// The current interpretation of columns in the csv data.
  ///
  /// These parsers are ordered the same way as [columnNames].
  ///
  /// There is no guarantee that every column in [columnNames] has a parser.
  UnmodifiableListView<ExportColumn?> get columnParsers
    => UnmodifiableListView(_columnParsers);

  /// Whether the CSV file has a title row (first line) that contains no data.
  bool hasHeadline = true;
  
  /// Override a columns with a custom one.
  void changeColumnParser(int columnIdx, ExportColumn? parser) {
    assert(_columnParsers.length > columnIdx);
    _columnParsers[columnIdx] = parser;
  }

  /// Try to parse the data with the current configuration.
  RecordParsingResult attemptParse() =>
      _converter.parseRecords(dataLines, columnParsers, false);
}
