
import 'package:blood_pressure_app/model/blood_pressure.dart';
import 'package:blood_pressure_app/model/export_import/csv_converter.dart';
import 'package:blood_pressure_app/model/export_import/record_parsing_result.dart';
import 'package:blood_pressure_app/model/storage/export_columns_store.dart';
import 'package:blood_pressure_app/model/storage/export_csv_settings_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CsvConverter', () {
    test('should create csv string bigger than 0', () {
      final converter = CsvConverter(CsvExportSettings(), ExportColumnsManager());
      final csv = converter.create(createRecords());
      expect(csv.length, isNonZero);
    });

    test('should create first line', () {
      final converter = CsvConverter(CsvExportSettings(), ExportColumnsManager());
      final csv = converter.create([]);
      final columns = CsvExportSettings().exportFieldsConfiguration.getActiveColumns(ExportColumnsManager());
      expect(csv, stringContainsInOrder(columns.map((e) => e.csvTitle).toList()));
    });

    test('should not create first line when setting is off', () {
      final converter = CsvConverter(
          CsvExportSettings(exportHeadline: false),
          ExportColumnsManager()
      );
      final csv = converter.create([]);
      final columns = CsvExportSettings().exportFieldsConfiguration.getActiveColumns(ExportColumnsManager());
      expect(csv, isNot(stringContainsInOrder(columns.map((e) => e.csvTitle).toList())));
    });

    test('should be able to recreate records from csv in default configuration', () {
      final converter = CsvConverter(CsvExportSettings(), ExportColumnsManager());
      final initialRecords = createRecords();
      final csv = converter.create(initialRecords);
      final parsedRecords = converter.parse(csv).getOr(failParse);
      
      expect(parsedRecords, pairwiseCompare(initialRecords,
            (p0, BloodPressureRecord p1) =>
                  p0.creationTime == p1.creationTime &&
                  p0.systolic == p1.systolic &&
                  p0.diastolic == p1.diastolic &&
                  p0.pulse == p1.pulse &&
                  p0.notes == p1.notes &&
                  p0.needlePin?.color == p1.needlePin?.color,
            'equal to'));
    });

    // TODO: test more
  });
}

List<BloodPressureRecord> createRecords([int count = 20]) => [
  for (int i = 0; i<count; i++)
    BloodPressureRecord(DateTime.fromMillisecondsSinceEpoch(123456 + i), 
        i, 100+i, 200+1, 'note $i', needlePin: MeasurementNeedlePin(Color(123+i))),
];

List<BloodPressureRecord>? failParse(RecordParsingError error) {
  switch (error) {
    case RecordParsingErrorEmptyFile():
      fail('Parsing failed due to insufficient data.');
    case RecordParsingErrorTimeNotRestoreable():
      fail('Parsing failed because time was not parsable.');
    case RecordParsingErrorUnknownColumn():
      fail('Parsing failed because column "${error.title}" is unknown.');
    case RecordParsingErrorExpectedMoreFields():
      fail('Parsing failed because line ${error.lineNumber} contained not enough fields.');
    case RecordParsingErrorUnparsableField():
      fail('Parsing failed because field ${error.fieldContents} in line ${error.lineNumber} is not parsable.');
  }
}