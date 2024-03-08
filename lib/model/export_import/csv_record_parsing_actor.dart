
import 'package:blood_pressure_app/model/export_import/column.dart';
import 'package:blood_pressure_app/model/export_import/csv_converter.dart';
import 'package:blood_pressure_app/model/export_import/record_parsing_result.dart';

/// A intermediate class usable by UI components to drive csv parsing.
class CsvRecordParsingActor {
  /// Create an intermediate object to manage a record parsing process.
  CsvRecordParsingActor(this._converter, String csvString) {
    final lines = _converter.getCsvLines(csvString);
    _headline = lines.removeAt(0);
    dataLines = lines;
    _columnNames = _headline ?? [];
    _columnParsers = _converter.getColumns(_columnNames);
  }

  final CsvConverter _converter;

  /// All lines without the first line.
  late final List<List<String>> dataLines;

  List<String>? _headline;

  /// The first line in the csv file.
  List<String>? get headline => _headline;

  late List<String> _columnNames;

  /// All columns defined in the csv headline.
  List<String> get columnNames => _columnNames;

  late Map<String, ExportColumn> _columnParsers;

  /// The current interpretation of columns in the csv data.
  ///
  /// There is no guarantee that every column in [columnNames] has a parser.
  Map<String, ExportColumn> get columnParsers => _columnParsers;

  /// Override a columns with a custom one.
  void changeColumnParser(String columnName, ExportColumn? parser) {
    assert(_columnNames.contains(columnName));
    if (parser == null) {
      _columnParsers.remove(columnName);
      return;
    }
    _columnParsers[columnName] = parser;
  }

  /// Try to parse the data with the current configuration.
  RecordParsingResult attemptParse() =>
    _converter.parseRecords(dataLines, columnNames, columnParsers, false);
}

// TODO: consider joining headline and columnNames OR support no headline.
