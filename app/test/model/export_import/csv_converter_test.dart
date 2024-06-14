
import 'dart:io';

import 'package:blood_pressure_app/model/export_import/csv_converter.dart';
import 'package:blood_pressure_app/model/export_import/record_parsing_result.dart';
import 'package:blood_pressure_app/model/storage/export_columns_store.dart';
import 'package:blood_pressure_app/model/storage/export_csv_settings_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health_data_store/health_data_store.dart';

import 'record_formatter_test.dart';

void main() {
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
        ExportColumnsManager(),
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
        p0.time == p1.time &&
        p0.sys == p1.sys &&
        p0.dia == p1.dia &&
        p0.pul == p1.pul /*&&
        p0.notes == p1.notes && fixme
        p0.needlePin?.color == p1.needlePin?.color,*/,
      'equal to',),);
  });
  test('should allow partial imports', () {
    final text = File('test/model/export_import/exported_formats/incomplete_export.csv').readAsStringSync();

    final converter = CsvConverter(
        CsvExportSettings(),
        ExportColumnsManager(),
    );
    final parsed = converter.parse(text);
    final records = parsed.getOr(failParse);
    expect(records, isNotNull);
    expect(records.length, 3);
    expect(records, anyElement(isA<BloodPressureRecord>()
        .having((p0) => p0.time.millisecondsSinceEpoch, 'timestamp', 1703239921194)
        .having((p0) => p0.sys, 'systolic', null)
        .having((p0) => p0.dia, 'diastolic', null)
        .having((p0) => p0.pul, 'pulse', null)
      //fixme .having((p0) => p0.notes, 'notes', 'note')
      //fixme .having((p0) => p0.needlePin, 'pin', null),
    ),);
    expect(records, anyElement(isA<BloodPressureRecord>()
        .having((p0) => p0.time.millisecondsSinceEpoch, 'timestamp', 1703239908244)
        .having((p0) => p0.sys, 'systolic', null)
        .having((p0) => p0.dia, 'diastolic', 45)
        .having((p0) => p0.pul, 'pulse', null)
      //fixme .having((p0) => p0.notes, 'notes', 'test')
      //fixme .having((p0) => p0.needlePin, 'pin', null),
    ),);
    expect(records, anyElement(isA<BloodPressureRecord>()
        .having((p0) => p0.time.millisecondsSinceEpoch, 'timestamp', 1703239905395)
        .having((p0) => p0.sys, 'systolic', 123)
        .having((p0) => p0.dia, 'diastolic', null)
        .having((p0) => p0.pul, 'pulse', null)
        /*.having((p0) => p0.notes, 'notes', '') fixme
        .having((p0) => p0.needlePin, 'pin', null)*/,
    ),);
  });


  test('should import v1.0.0 measurements', () {
    final text = File('test/model/export_import/exported_formats/v1.0.csv').readAsStringSync();

    final converter = CsvConverter(
        CsvExportSettings(),
        ExportColumnsManager(),
    );
    final parsed = converter.parse(text);
    final records = parsed.getOr(failParse);
    expect(records, isNotNull);
    expect(records.length, 2);
    expect(records, everyElement(isA<BloodPressureRecord>()));
    expect(records, anyElement(isA<BloodPressureRecord>()
        .having((p0) => p0.time.millisecondsSinceEpoch, 'timestamp', 1703175660000)
        .having((p0) => p0.sys, 'systolic', 312)
        .having((p0) => p0.dia, 'diastolic', 315)
        .having((p0) => p0.pul, 'pulse', 46)
      //fixme .having((p0) => p0.notes.trim(), 'notes', 'testfkajkfb'),
    ),);
    expect(records, anyElement(isA<BloodPressureRecord>()
        .having((p0) => p0.time.millisecondsSinceEpoch, 'timestamp', 1703175600000)
        .having((p0) => p0.sys, 'systolic', 123)
        .having((p0) => p0.dia, 'diastolic', 41)
        .having((p0) => p0.pul, 'pulse', 43)
      //fixme .having((p0) => p0.notes.trim(), 'notes', '1214s3'),
    ),);
  });
  test('should import v1.1.0 measurements', () {
    final text = File('test/model/export_import/exported_formats/v1.1.0').readAsStringSync();

    final converter = CsvConverter(
        CsvExportSettings(),
        ExportColumnsManager(),
    );
    final parsed = converter.parse(text);
    final records = parsed.getOr(failParse);
    expect(records, isNotNull);
    expect(records.length, 4);
    expect(records, everyElement(isA<BloodPressureRecord>()));
    expect(records, anyElement(isA<BloodPressureRecord>()
        .having((p0) => p0.time.millisecondsSinceEpoch, 'timestamp', 1703175660000)
        .having((p0) => p0.sys, 'systolic', 312)
        .having((p0) => p0.dia, 'diastolic', 315)
        .having((p0) => p0.pul, 'pulse', 46)
      //fixme .having((p0) => p0.notes.trim(), 'notes', 'testfkajkfb'),
    ),);
    expect(records, anyElement(isA<BloodPressureRecord>()
        .having((p0) => p0.time.millisecondsSinceEpoch, 'timestamp', 1703175600000)
        .having((p0) => p0.sys, 'systolic', 123)
        .having((p0) => p0.dia, 'diastolic', 41)
        .having((p0) => p0.pul, 'pulse', 43)
      //fixme .having((p0) => p0.notes.trim(), 'notes', '1214s3'),
    ),);
  });
  test('should import v1.4.0 measurements', () {
    final text = File('test/model/export_import/exported_formats/v1.4.0.CSV').readAsStringSync();

    final converter = CsvConverter(
        CsvExportSettings(),
        ExportColumnsManager(),
    );
    final parsed = converter.parse(text);
    final records = parsed.getOr(failParse);
    expect(records, isNotNull);
    expect(records.length, 186);
    expect(records, everyElement(isA<BloodPressureRecord>()));
    expect(records, anyElement(isA<BloodPressureRecord>()
        .having((p0) => p0.time.millisecondsSinceEpoch, 'timestamp', 1703175660000)
        .having((p0) => p0.sys, 'systolic', 312)
        .having((p0) => p0.dia, 'diastolic', 315)
        .having((p0) => p0.pul, 'pulse', 46)
        //fixme .having((p0) => p0.notes, 'notes', 'testfkajkfb'),
    ),);
    expect(records, anyElement(isA<BloodPressureRecord>()
        .having((p0) => p0.time.millisecondsSinceEpoch, 'timestamp', 1703175600000)
        .having((p0) => p0.sys, 'systolic', 123)
        .having((p0) => p0.dia, 'diastolic', 41)
        .having((p0) => p0.pul, 'pulse', 43)
        //.having((p0) => p0.notes, 'notes', '1214s3'),fixme
    ),);
    expect(records, anyElement(isA<BloodPressureRecord>()
        .having((p0) => p0.time.millisecondsSinceEpoch, 'timestamp', 10893142303200)
        .having((p0) => p0.sys, 'systolic', 106)
        .having((p0) => p0.dia, 'diastolic', 77)
        .having((p0) => p0.pul, 'pulse', 53)
        //.having((p0) => p0.notes, 'notes', ''),fixme
    ),);
  });
  test('should import v1.5.1 measurements', () {
    final text = File('test/model/export_import/exported_formats/v1.5.1.csv').readAsStringSync();

    final converter = CsvConverter(
        CsvExportSettings(),
        ExportColumnsManager(),
    );
    final parsed = converter.parse(text);
    final records = parsed.getOr(failParse);
    expect(records, isNotNull);
    expect(records.length, 185);
    expect(records, everyElement(isA<BloodPressureRecord>()));
    expect(records, anyElement(isA<BloodPressureRecord>()
        .having((p0) => p0.time.millisecondsSinceEpoch, 'timestamp', 1703175660000)
        .having((p0) => p0.sys, 'systolic', 312)
        .having((p0) => p0.dia, 'diastolic', 315)
        .having((p0) => p0.pul, 'pulse', 46)
        /*.having((p0) => p0.notes, 'notes', 'testfkajkfb')fixme
        .having((p0) => p0.needlePin, 'pin', null),*/
    ),);
    expect(records, anyElement(isA<BloodPressureRecord>()
        .having((p0) => p0.time.millisecondsSinceEpoch, 'timestamp', 1703175600000)
        .having((p0) => p0.sys, 'systolic', 123)
        .having((p0) => p0.dia, 'diastolic', 41)
        .having((p0) => p0.pul, 'pulse', 43)
        /*.having((p0) => p0.notes, 'notes', '1214s3')fixme
        .having((p0) => p0.needlePin, 'pin', null),*/
    ),);
    expect(records, anyElement(isA<BloodPressureRecord>()
        .having((p0) => p0.time.millisecondsSinceEpoch, 'timestamp', 1077625200000)
        .having((p0) => p0.sys, 'systolic', 100)
        .having((p0) => p0.dia, 'diastolic', 82)
        .having((p0) => p0.pul, 'pulse', 63)
        /*.having((p0) => p0.notes, 'notes', '') fixme
        .having((p0) => p0.needlePin, 'pin', null)*/,
    ),);
  });
  test('should import v1.5.7 measurements', () {
    final text = File('test/model/export_import/exported_formats/v1.5.7.csv').readAsStringSync();

    final converter = CsvConverter(
        CsvExportSettings(),
        ExportColumnsManager(),
    );
    final parsed = converter.parse(text);
    final records = parsed.getOr(failParse);
    expect(records, isNotNull);
    expect(records.length, 185);
    expect(records, everyElement(isA<BloodPressureRecord>()));
    expect(records, anyElement(isA<BloodPressureRecord>()
        .having((p0) => p0.time.millisecondsSinceEpoch, 'timestamp', 1703175660000)
        .having((p0) => p0.sys, 'systolic', 312)
        .having((p0) => p0.dia, 'diastolic', 315)
        .having((p0) => p0.pul, 'pulse', 46)
        /*.having((p0) => p0.notes, 'notes', 'testfkajkfb') fixme
        .having((p0) => p0.needlePin, 'pin', null),*/
    ),);
    expect(records, anyElement(isA<BloodPressureRecord>()
        .having((p0) => p0.time.millisecondsSinceEpoch, 'timestamp', 1703175600000)
        .having((p0) => p0.sys, 'systolic', 123)
        .having((p0) => p0.dia, 'diastolic', 41)
        .having((p0) => p0.pul, 'pulse', 43)
        /*.having((p0) => p0.notes, 'notes', '1214s3')fixme
        .having((p0) => p0.needlePin, 'pin', null),*/
    ),);
    expect(records, anyElement(isA<BloodPressureRecord>()
        .having((p0) => p0.time.millisecondsSinceEpoch, 'timestamp', 1077625200000)
        .having((p0) => p0.sys, 'systolic', 100)
        .having((p0) => p0.dia, 'diastolic', 82)
        .having((p0) => p0.pul, 'pulse', 63)
        /*.having((p0) => p0.notes, 'notes', '') fixme
        .having((p0) => p0.needlePin, 'pin', null)*/,
    ),);
    // TODO: test color
  });
  test('should import v1.5.8 measurements', () {
    final text = File('test/model/export_import/exported_formats/v1.5.8.csv').readAsStringSync();

    final converter = CsvConverter(
        CsvExportSettings(),
        ExportColumnsManager(),
    );
    final parsed = converter.parse(text);
    final records = parsed.getOr(failParse);
    expect(records, isNotNull);
    expect(records.length, 9478);
    expect(records, everyElement(isA<BloodPressureRecord>()));
    expect(records, anyElement(isA<BloodPressureRecord>()
        .having((p0) => p0.time.millisecondsSinceEpoch, 'timestamp', 1703175193324)
        .having((p0) => p0.sys, 'systolic', 123)
        .having((p0) => p0.dia, 'diastolic', 43)
        .having((p0) => p0.pul, 'pulse', 53)
        /*.having((p0) => p0.notes, 'notes', 'sdfsdfds')fixme
        .having((p0) => p0.needlePin?.color, 'pin', const Color(0xff69f0ae)),*/
    ),);
    expect(records, anyElement(isA<BloodPressureRecord>()
        .having((p0) => p0.time.millisecondsSinceEpoch, 'timestamp', 1702883511000)
        .having((p0) => p0.sys, 'systolic', 114)
        .having((p0) => p0.dia, 'diastolic', 71)
        .having((p0) => p0.pul, 'pulse', 66)
        /*.having((p0) => p0.notes, 'notes', 'fsaf &_*¢|^✓[=%®©')fixme
        .having((p0) => p0.needlePin?.color.value, 'pin', Colors.lightGreen.value),*/
    ),);
    expect(records, anyElement(isA<BloodPressureRecord>()
        .having((p0) => p0.time.millisecondsSinceEpoch, 'timestamp', 1701034952000)
        .having((p0) => p0.sys, 'systolic', 125)
        .having((p0) => p0.dia, 'diastolic', 77)
        .having((p0) => p0.pul, 'pulse', 60)
        /*.having((p0) => p0.notes, 'notes', '') fixme
        .having((p0) => p0.needlePin, 'pin', null)*/,
    ),);
    expect(records, anyElement(isA<BloodPressureRecord>()
        .having((p0) => p0.time.millisecondsSinceEpoch, 'timestamp', 1077625200000)
        .having((p0) => p0.sys, 'systolic', 100)
        .having((p0) => p0.dia, 'diastolic', 82)
        .having((p0) => p0.pul, 'pulse', 63)
        /*.having((p0) => p0.notes, 'notes', '') fixme
        .having((p0) => p0.needlePin, 'pin', null)*/,
    ),);
    // TODO: test time columns
  });
}

List<BloodPressureRecord> createRecords([int count = 20]) => [
  for (int i = 0; i<count; i++)
    mockRecordPos(DateTime.fromMillisecondsSinceEpoch(123456 + i),
        i, 100+i, 200+1, 'note $i', Color(123+i),),
];

List<BloodPressureRecord>? failParse(EntryParsingError error) {
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

// TODO: test csv import actor
