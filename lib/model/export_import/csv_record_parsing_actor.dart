
import 'package:blood_pressure_app/model/export_import/column.dart';

/// A intermediate class that allows to manage record parsing.
class CsvRecordParsingActor {
  /// Create an intermediate object to manage a record parsing process.
  CsvRecordParsingActor(this.csvString) {

  }

  /// The initial csv String provided to the parser
  final String csvString;

  /// All columns defined in the csv headline.
  List<String> columnNames;

  /// The current interpretation of columns in the csv data.
  ///
  /// There is no guarantee that every column in [columnNames] has a parser.
  Map<String, ExportColumn> columnParsers;

  final List<void Function(CsvRecordParsingActor)> _listeners = [];

  /// Register a listener that gets called once a value gets changed.
  void addListener(void Function(CsvRecordParsingActor state) listener)
    => _listeners.add(listener);
}
