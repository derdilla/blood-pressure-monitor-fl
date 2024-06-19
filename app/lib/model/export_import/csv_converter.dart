import 'package:blood_pressure_app/model/export_import/column.dart';
import 'package:blood_pressure_app/model/export_import/import_field_type.dart' show RowDataFieldType;
import 'package:blood_pressure_app/model/export_import/record_parsing_result.dart';
import 'package:blood_pressure_app/model/storage/export_columns_store.dart';
import 'package:blood_pressure_app/model/storage/export_csv_settings_store.dart';
import 'package:collection/collection.dart';
import 'package:csv/csv.dart';
import 'package:health_data_store/health_data_store.dart';

/// Utility class to convert between csv strings and [BloodPressureRecord]s.
class CsvConverter {
  /// Create converter between csv strings and [BloodPressureRecord] values that respects settings.
  CsvConverter(this.settings, this.availableColumns);

  /// Settings that apply for ex- and import.
  final CsvExportSettings settings;

  /// Columns manager used for ex- and import.
  final ExportColumnsManager availableColumns;

  /// Create the contents of a csv file from passed records.
  String create(List<FullEntry> entries) {
    final columns = settings.exportFieldsConfiguration.getActiveColumns(availableColumns);
    final table = entries.map(
      (entry) => columns.map(
        (column) => column.encode(entry.$1, entry.$2, entry.$3),
      ).toList(),
    ).toList();

    if (settings.exportHeadline) table.insert(0, columns.map((c) => c.csvTitle).toList());

    final csvCreator = ListToCsvConverter(
        fieldDelimiter: settings.fieldDelimiter,
        textDelimiter: settings.textDelimiter,
    );

    return csvCreator.convert(table);
  }

  /// Attempts to parse a csv string automatically.
  /// 
  /// Validates that the first line of the file contains columns present 
  /// in [availableColumns]. When a column is present multiple times only 
  /// the first one counts.
  /// A needle pin takes precedent over a color.
  RecordParsingResult parse(String csvString) {
    // Turn csv into lines.
    final lines = getCsvLines(csvString);
    if (lines.length < 2) return RecordParsingResult.err(RecordParsingErrorEmptyFile());

    // Get and validate columns from csv title.
    final List<String> titles = lines.removeAt(0).cast();
    final List<ExportColumn?> columns = [];
    final assumedColumns = getColumns(titles);
    for (final csvName in titles) {
      columns.add(assumedColumns[csvName]);
    }
    if (columns.none((e) => e?.restoreAbleType == RowDataFieldType.timestamp)) {
      return RecordParsingResult.err(RecordParsingErrorTimeNotRestoreable());
    }

    // Convert data to records.
    return parseRecords(lines, columns);
  }

  /// Parses lines from csv files according to settings.
  /// 
  /// Works around different EOL types n
  List<List<String>> getCsvLines(String csvString) {
    final converter = CsvToListConverter(
      fieldDelimiter: settings.fieldDelimiter,
      textDelimiter: settings.textDelimiter,
      shouldParseNumbers: false,
    );
    final csvLines = converter.convert<String>(csvString, eol: '\r\n');
    if (csvLines.length < 2) return converter.convert<String>(csvString, eol: '\n');
    return csvLines;
  }

  /// Map column names in the first csv-line to matching [ExportColumn].
  Map<String, ExportColumn> getColumns(List<String> headline) {
    final Map<String, ExportColumn> columns = {};
    for (final titleText in headline) {
      final formattedTitleText = titleText.trim();
      final column = availableColumns.firstWhere(
            (c) => c.csvTitle == formattedTitleText
            && c.restoreAbleType != null,);
      if (column != null) columns[titleText] = column;
    }
    return columns;
  }

  /// Parse csv data in [dataLines] using [parsers].
  ///
  /// [dataLines] contains all lines of the csv file without the headline and
  /// [parsers] must have the same length as every line in [dataLines]
  /// for parsing to succeed.
  ///
  /// [assumeHeadline] controls whether the line number should be offset by one
  /// in case of error.
  RecordParsingResult parseRecords(
      List<List<String>> dataLines,
      List<ExportColumn?> parsers, [
        bool assumeHeadline = true,
      ]) {
    final List<FullEntry> entries = [];
    int currentLineNumber = assumeHeadline ? 1 : 0;
    for (final currentLine in dataLines) {
      if (currentLine.length < parsers.length) {
        return RecordParsingResult.err(RecordParsingErrorExpectedMoreFields(currentLineNumber));
      }

      final List<(RowDataFieldType, dynamic)> recordPieces = [];
      for (int fieldIndex = 0; fieldIndex < parsers.length; fieldIndex++) {
        final parser = parsers[fieldIndex];
        final piece = parser?.decode(currentLine[fieldIndex]);
        // Validate that the column parsed the expected type.
        // Null can be the result of empty fields.
        if (piece?.$1 != parser?.restoreAbleType
            && piece != null) {
          return RecordParsingResult.err(RecordParsingErrorUnparsableField(currentLineNumber, currentLine[fieldIndex]));
        }
        if (piece != null) recordPieces.add(piece);
      }

      final DateTime? timestamp = recordPieces.firstWhereOrNull(
            (piece) => piece.$1 == RowDataFieldType.timestamp,)?.$2;
      if (timestamp == null) {
        return RecordParsingResult.err(RecordParsingErrorTimeNotRestoreable());
      }

      final int? sys = recordPieces.firstWhereOrNull(
            (piece) => piece.$1 == RowDataFieldType.sys,)?.$2;
      final int? dia = recordPieces.firstWhereOrNull(
            (piece) => piece.$1 == RowDataFieldType.dia,)?.$2;
      final int? pul = recordPieces.firstWhereOrNull(
            (piece) => piece.$1 == RowDataFieldType.pul,)?.$2;
      final String noteText = recordPieces.firstWhereOrNull(
            (piece) => piece.$1 == RowDataFieldType.notes,)?.$2 ?? '';
      final int? color = recordPieces.firstWhereOrNull(
            (piece) => piece.$1 == RowDataFieldType.color,)?.$2;

      final record = BloodPressureRecord(
        time: timestamp,
        sys: sys?.asMMHg,
        dia: dia?.asMMHg,
        pul: pul,
      );
      final note = Note(
        time: timestamp,
        note: noteText,
        color: color,
      );
      entries.add((record, note, []));
      currentLineNumber++;
    }

    assert(entries.length == dataLines.length, 'every line should have been parse');
    return RecordParsingResult.ok(entries);
  }
}

extension _AsMMHg on int {
  /// Interprets the value as a Pressure in mmHg.
  Pressure get asMMHg => Pressure.mmHg(this);
}
