
import 'package:blood_pressure_app/model/blood_pressure.dart';
import 'package:blood_pressure_app/model/export_import/column.dart';
import 'package:blood_pressure_app/model/export_import/import_field_type.dart' show RowDataFieldType;
import 'package:blood_pressure_app/model/export_import/record_parsing_result.dart';
import 'package:blood_pressure_app/model/storage/export_columns_store.dart';
import 'package:blood_pressure_app/model/storage/export_csv_settings_store.dart';
import 'package:collection/collection.dart';
import 'package:csv/csv.dart';
import 'package:flutter/material.dart';

/// Utility class to convert between csv strings and [BloodPressureRecord]s.
class CsvConverter {
  /// Create converter between csv strings and [BloodPressureRecord] values that respects settings.
  CsvConverter(this.settings, this.availableColumns);

  /// Settings that apply for ex- and import.
  final CsvExportSettings settings;

  /// Columns manager used for ex- and import.
  final ExportColumnsManager availableColumns;

  /// Create the contents of a csv file from passed records.
  String create(List<BloodPressureRecord> records) {
    final columns = settings.exportFieldsConfiguration.getActiveColumns(availableColumns);
    final table = records.map(
      (record) => columns.map(
        (column) => column.encode(record)
      ).toList()
    ).toList();

    if (settings.exportHeadline) table.insert(0, columns.map((c) => c.csvTitle).toList());

    final csvCreator = ListToCsvConverter(
        fieldDelimiter: settings.fieldDelimiter,
        textDelimiter: settings.textDelimiter
    );

    return csvCreator.convert(table);
  }

  /// Attempts to parse a csv string.
  /// 
  /// Validates that the first line of the file contains columns present 
  /// in [availableColumns]. When a column is present multiple times only 
  /// the first one counts.
  /// A needle pin takes precedent over a color.
  RecordParsingResult parse(String csvString) {
    // Turn csv into lines.
    final lines = (){
        final converter = CsvToListConverter(
          fieldDelimiter: settings.fieldDelimiter,
          textDelimiter: settings.textDelimiter,
          shouldParseNumbers: false,
        );
        final csvLines = converter.convert(csvString, eol: '\r\n');
        if (csvLines.length < 2) return converter.convert(csvString, eol: '\n');
        return csvLines;
    }();
    if (lines.length < 2) return RecordParsingResult.err(RecordParsingErrorEmptyFile());

    // Get and validate columns from csv title.
    final List<ExportColumn> columns = [];
    for (final titleText in lines.removeAt(0)) {
      assert(titleText is String);
      final column = availableColumns.firstWhere(
              (c) => c.csvTitle == titleText
                  && c.restoreAbleType != null);
      if (column == null) return RecordParsingResult.err(RecordParsingErrorUnknownColumn(titleText));
      columns.add(column);
    }
    if (columns.where((e) => e.restoreAbleType == RowDataFieldType.timestamp).isEmpty) {
      return RecordParsingResult.err(RecordParsingErrorTimeNotRestoreable());
    }

    // Convert data to records.
    final List<BloodPressureRecord> records = [];
    int currentLineNumber = 1;
    for (final currentLine in lines) {
      if (currentLine.length < columns.length) {
        return RecordParsingResult.err(RecordParsingErrorExpectedMoreFields(currentLineNumber));
      }
      
      final List<(RowDataFieldType, dynamic)> recordPieces = [];
      for (int fieldIndex = 0; fieldIndex < columns.length; fieldIndex++) {
        assert(currentLine[fieldIndex] is String);
        final piece = columns[fieldIndex].decode(currentLine[fieldIndex]);
        if (piece?.$1 != columns[fieldIndex].restoreAbleType) { // validation
          return RecordParsingResult.err(RecordParsingErrorUnparsableField(currentLineNumber, currentLine[fieldIndex]));
        }
        if (piece != null) recordPieces.add(piece);
      }

      final DateTime timestamp = recordPieces.firstWhere(
              (piece) => piece.$1 == RowDataFieldType.timestamp).$2;
      final int? sys = recordPieces.firstWhereOrNull(
              (piece) => piece.$1 == RowDataFieldType.sys)?.$2;
      final int? dia = recordPieces.firstWhereOrNull(
              (piece) => piece.$1 == RowDataFieldType.dia)?.$2;
      final int? pul = recordPieces.firstWhereOrNull(
              (piece) => piece.$1 == RowDataFieldType.pul)?.$2;
      final String note = recordPieces.firstWhereOrNull(
              (piece) => piece.$1 == RowDataFieldType.notes)?.$2 ?? '';
      MeasurementNeedlePin? needlePin = recordPieces.firstWhereOrNull(
              (piece) => piece.$1 == RowDataFieldType.needlePin)?.$2;
      if (needlePin == null) {
        final Color? color = recordPieces.firstWhereOrNull(
                (piece) => piece.$1 == RowDataFieldType.color)?.$2;
        if (color != null) needlePin = MeasurementNeedlePin(color);
      }

      records.add(BloodPressureRecord(timestamp, sys, dia, pul, note, needlePin: needlePin));
      currentLineNumber++;
    }
    
    assert(records.length == lines.length, 'every line should have been parse'); // first line got removed
    return RecordParsingResult.ok(records);
  }
}
