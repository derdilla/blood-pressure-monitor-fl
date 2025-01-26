
import 'dart:io';

import 'package:blood_pressure_app/model/export_import/column.dart';
import 'package:blood_pressure_app/model/export_import/csv_converter.dart';
import 'package:blood_pressure_app/model/export_import/export_configuration.dart';
import 'package:blood_pressure_app/model/export_import/record_parsing_result.dart';
import 'package:blood_pressure_app/model/storage/export_columns_store.dart';
import 'package:blood_pressure_app/model/storage/export_csv_settings_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health_data_store/health_data_store.dart';

import 'record_formatter_test.dart';

void main() {
  test('should create csv string bigger than 0', () {
    final converter = CsvConverter(CsvExportSettings(), ExportColumnsManager(), []);
    final csv = converter.create(createRecords());
    expect(csv.length, isNonZero);
  });

  test('should create first line', () {
    final converter = CsvConverter(CsvExportSettings(), ExportColumnsManager(), []);
    final csv = converter.create([]);
    final columns = CsvExportSettings().exportFieldsConfiguration.getActiveColumns(ExportColumnsManager());
    expect(csv, stringContainsInOrder(columns.map((e) => e.csvTitle).toList()));
  });

  test('should not create first line when setting is off', () {
    final converter = CsvConverter(
      CsvExportSettings(exportHeadline: false),
      ExportColumnsManager(),
      [],
    );
    final csv = converter.create([]);
    final columns = CsvExportSettings().exportFieldsConfiguration.getActiveColumns(ExportColumnsManager());
    expect(csv, isNot(stringContainsInOrder(columns.map((e) => e.csvTitle).toList())));
  });

  test('should be able to recreate records from csv in default configuration', () {
    final converter = CsvConverter(CsvExportSettings(), ExportColumnsManager(), []);
    final initialRecords = createRecords();
    final csv = converter.create(initialRecords);
    final parsedRecords = converter.parse(csv).getOr(failParse);

    expect(parsedRecords, pairwiseCompare(initialRecords,
      ((DateTime, BloodPressureRecord, Note, List<MedicineIntake>, Weight?) p0, (DateTime, BloodPressureRecord, Note, List<MedicineIntake>, Weight?) p1) =>
        p0.$2.time == p1.$2.time &&
        p0.$2.sys == p1.$2.sys &&
        p0.$2.dia == p1.$2.dia &&
        p0.$2.pul == p1.$2.pul &&
        p0.$3.note == p1.$3.note &&
        p0.$3.color == p1.$3.color,
      'equal to',),);
  });
  test('should allow partial imports', () {
    final text = File('test/model/export_import/exported_formats/incomplete_export.csv').readAsStringSync();

    final converter = CsvConverter(
      CsvExportSettings(),
      ExportColumnsManager(),
      [],
    );
    final parsed = converter.parse(text);
    final records = parsed.getOr(failParse);
    expect(records, isNotNull);
    expect(records.length, 3);
    expect(records, anyElement(isA<FullEntry>()
      .having((p0) => p0.$1.time.millisecondsSinceEpoch, 'timestamp', 1703239921194)
      .having((p0) => p0.$1.sys?.mmHg, 'systolic', null)
      .having((p0) => p0.$1.dia?.mmHg, 'diastolic', null)
      .having((p0) => p0.$1.pul, 'pulse', null)
      .having((p0) => p0.$2.note, 'notes', 'note')
      .having((p0) => p0.$2.color, 'pin', null),
    ),);
    expect(records, anyElement(isA<FullEntry>()
      .having((p0) => p0.$1.time.millisecondsSinceEpoch, 'timestamp', 1703239908244)
      .having((p0) => p0.$1.sys?.mmHg, 'systolic', null)
      .having((p0) => p0.$1.dia?.mmHg, 'diastolic', 45)
      .having((p0) => p0.$1.pul, 'pulse', null)
      .having((p0) => p0.$2.note, 'notes', 'test')
      .having((p0) => p0.$2.color, 'pin', null),
    ),);
    expect(records, anyElement(isA<FullEntry>()
      .having((p0) => p0.$1.time.millisecondsSinceEpoch, 'timestamp', 1703239905395)
      .having((p0) => p0.$1.sys?.mmHg, 'systolic', 123)
      .having((p0) => p0.$1.dia?.mmHg, 'diastolic', null)
      .having((p0) => p0.$1.pul, 'pulse', null)
      .having((p0) => p0.$2.note, 'notes', '')
      .having((p0) => p0.$2.color, 'pin', null),
    ),);
  });


  test('should import v1.0.0 measurements', () {
    final text = File('test/model/export_import/exported_formats/v1.0.csv').readAsStringSync();

    final converter = CsvConverter(
      CsvExportSettings(),
      ExportColumnsManager(),
      [],
    );
    final parsed = converter.parse(text);
    final records = parsed.getOr(failParse);
    expect(records, isNotNull);
    expect(records.length, 2);
    expect(records, everyElement(isA<FullEntry>()));
    expect(records, anyElement(isA<FullEntry>()
      .having((p0) => p0.$1.time.millisecondsSinceEpoch, 'timestamp', 1703175660000)
      .having((p0) => p0.$1.sys?.mmHg, 'systolic', 312)
      .having((p0) => p0.$1.dia?.mmHg, 'diastolic', 315)
      .having((p0) => p0.$1.pul, 'pulse', 46)
      .having((p0) => p0.$2.note?.trim(), 'notes', 'testfkajkfb'),
    ),);
    expect(records, anyElement(isA<FullEntry>()
      .having((p0) => p0.$1.time.millisecondsSinceEpoch, 'timestamp', 1703175600000)
      .having((p0) => p0.$1.sys?.mmHg, 'systolic', 123)
      .having((p0) => p0.$1.dia?.mmHg, 'diastolic', 41)
      .having((p0) => p0.$1.pul, 'pulse', 43)
      .having((p0) => p0.$2.note?.trim(), 'notes', '1214s3'),
    ),);
  });
  test('should import v1.1.0 measurements', () {
    final text = File('test/model/export_import/exported_formats/v1.1.0').readAsStringSync();

    final converter = CsvConverter(
      CsvExportSettings(),
      ExportColumnsManager(),
      [],
    );
    final parsed = converter.parse(text);
    final records = parsed.getOr(failParse);
    expect(records, isNotNull);
    expect(records.length, 4);
    expect(records, everyElement(isA<FullEntry>()));
    expect(records, anyElement(isA<FullEntry>()
        .having((p0) => p0.$1.time.millisecondsSinceEpoch, 'timestamp', 1703175660000)
        .having((p0) => p0.$1.sys?.mmHg, 'systolic', 312)
        .having((p0) => p0.$1.dia?.mmHg, 'diastolic', 315)
        .having((p0) => p0.$1.pul, 'pulse', 46)
        .having((p0) => p0.$2.note?.trim(), 'notes', 'testfkajkfb'),
    ),);
    expect(records, anyElement(isA<FullEntry>()
        .having((p0) => p0.$1.time.millisecondsSinceEpoch, 'timestamp', 1703175600000)
        .having((p0) => p0.$1.sys?.mmHg, 'systolic', 123)
        .having((p0) => p0.$1.dia?.mmHg, 'diastolic', 41)
        .having((p0) => p0.$1.pul, 'pulse', 43)
        .having((p0) => p0.$2.note?.trim(), 'notes', '1214s3'),
    ),);
  });
  test('should import v1.4.0 measurements', () {
    final text = File('test/model/export_import/exported_formats/v1.4.0.CSV').readAsStringSync();

    final converter = CsvConverter(
      CsvExportSettings(),
      ExportColumnsManager(),
      [],
    );
    final parsed = converter.parse(text);
    final records = parsed.getOr(failParse);
    expect(records, isNotNull);
    expect(records.length, 186);
    expect(records, everyElement(isA<FullEntry>()));
    expect(records, anyElement(isA<FullEntry>()
      .having((p0) => p0.$1.time.millisecondsSinceEpoch, 'timestamp', 1703175660000)
      .having((p0) => p0.$1.sys?.mmHg, 'systolic', 312)
      .having((p0) => p0.$1.dia?.mmHg, 'diastolic', 315)
      .having((p0) => p0.$1.pul, 'pulse', 46)
      .having((p0) => p0.$2.note, 'notes', 'testfkajkfb'),
    ),);
    expect(records, anyElement(isA<FullEntry>()
      .having((p0) => p0.$1.time.millisecondsSinceEpoch, 'timestamp', 1703175600000)
      .having((p0) => p0.$1.sys?.mmHg, 'systolic', 123)
      .having((p0) => p0.$1.dia?.mmHg, 'diastolic', 41)
      .having((p0) => p0.$1.pul, 'pulse', 43)
      .having((p0) => p0.$2.note, 'notes', '1214s3'),
    ),);
    expect(records, anyElement(isA<FullEntry>()
      .having((p0) => p0.$1.time.millisecondsSinceEpoch, 'timestamp', 10893142303200)
      .having((p0) => p0.$1.sys?.mmHg, 'systolic', 106)
      .having((p0) => p0.$1.dia?.mmHg, 'diastolic', 77)
      .having((p0) => p0.$1.pul, 'pulse', 53)
      .having((p0) => p0.$2.note, 'notes', ''),
    ),);
  });
  test('should import v1.5.1 measurements', () {
    final text = File('test/model/export_import/exported_formats/v1.5.1.csv').readAsStringSync();

    final converter = CsvConverter(
      CsvExportSettings(),
      ExportColumnsManager(),
      [],
    );
    final parsed = converter.parse(text);
    final records = parsed.getOr(failParse);
    expect(records, isNotNull);
    expect(records.length, 185);
    expect(records, everyElement(isA<FullEntry>()));
    expect(records, anyElement(isA<FullEntry>()
      .having((p0) => p0.$1.time.millisecondsSinceEpoch, 'timestamp', 1703175660000)
      .having((p0) => p0.$1.sys?.mmHg, 'systolic', 312)
      .having((p0) => p0.$1.dia?.mmHg, 'diastolic', 315)
      .having((p0) => p0.$1.pul, 'pulse', 46)
      .having((p0) => p0.$2.note, 'notes', 'testfkajkfb')
      .having((p0) => p0.$2.color, 'pin', null),
    ),);
    expect(records, anyElement(isA<FullEntry>()
      .having((p0) => p0.$1.time.millisecondsSinceEpoch, 'timestamp', 1703175600000)
      .having((p0) => p0.$1.sys?.mmHg, 'systolic', 123)
      .having((p0) => p0.$1.dia?.mmHg, 'diastolic', 41)
      .having((p0) => p0.$1.pul, 'pulse', 43)
      .having((p0) => p0.$2.note, 'notes', '1214s3')
      .having((p0) => p0.$2.color, 'pin', null),
    ),);
    expect(records, anyElement(isA<FullEntry>()
      .having((p0) => p0.$1.time.millisecondsSinceEpoch, 'timestamp', 1077625200000)
      .having((p0) => p0.$1.sys?.mmHg, 'systolic', 100)
      .having((p0) => p0.$1.dia?.mmHg, 'diastolic', 82)
      .having((p0) => p0.$1.pul, 'pulse', 63)
      .having((p0) => p0.$2.note, 'notes', '')
      .having((p0) => p0.$2.color, 'pin', null),
    ),);
  });
  test('should import v1.5.7 measurements', () {
    final text = File('test/model/export_import/exported_formats/v1.5.7.csv').readAsStringSync();

    final converter = CsvConverter(
      CsvExportSettings(),
      ExportColumnsManager(),
      [],
    );
    final parsed = converter.parse(text);
    final records = parsed.getOr(failParse);
    expect(records, isNotNull);
    expect(records.length, 185);
    expect(records, everyElement(isA<FullEntry>()));
    expect(records, anyElement(isA<FullEntry>()
      .having((p0) => p0.$1.time.millisecondsSinceEpoch, 'timestamp', 1703175660000)
      .having((p0) => p0.$1.sys?.mmHg, 'systolic', 312)
      .having((p0) => p0.$1.dia?.mmHg, 'diastolic', 315)
      .having((p0) => p0.$1.pul, 'pulse', 46)
      .having((p0) => p0.$2.note, 'notes', 'testfkajkfb')
      .having((p0) => p0.$2.color, 'pin', null),
    ),);
    expect(records, anyElement(isA<FullEntry>()
        .having((p0) => p0.$1.time.millisecondsSinceEpoch, 'timestamp', 1703175600000)
        .having((p0) => p0.$1.sys?.mmHg, 'systolic', 123)
        .having((p0) => p0.$1.dia?.mmHg, 'diastolic', 41)
        .having((p0) => p0.$1.pul, 'pulse', 43)
        .having((p0) => p0.$2.note, 'notes', '1214s3')
        .having((p0) => p0.$2.color, 'pin', null),
    ),);
    expect(records, anyElement(isA<FullEntry>()
        .having((p0) => p0.$1.time.millisecondsSinceEpoch, 'timestamp', 1077625200000)
        .having((p0) => p0.$1.sys?.mmHg, 'systolic', 100)
        .having((p0) => p0.$1.dia?.mmHg, 'diastolic', 82)
        .having((p0) => p0.$1.pul, 'pulse', 63)
        .having((p0) => p0.$2.note, 'notes', '')
        .having((p0) => p0.$2.color, 'pin', null),
    ),);
    // TODO: test color
  });
  test('should import v1.5.8 measurements', () {
    final text = File('test/model/export_import/exported_formats/v1.5.8.csv').readAsStringSync();

    final converter = CsvConverter(
      CsvExportSettings(),
      ExportColumnsManager(),
      [],
    );
    final parsed = converter.parse(text);
    final records = parsed.getOr(failParse);
    expect(records, isNotNull);
    expect(records.length, 9478);
    expect(records, everyElement(isA<FullEntry>()));
    expect(records, anyElement(isA<FullEntry>()
      .having((p0) => p0.$1.time.millisecondsSinceEpoch, 'timestamp', 1703175193324)
      .having((p0) => p0.$1.sys?.mmHg, 'systolic', 123)
      .having((p0) => p0.$1.dia?.mmHg, 'diastolic', 43)
      .having((p0) => p0.$1.pul, 'pulse', 53)
      .having((p0) => p0.$2.note, 'notes', 'sdfsdfds')
      .having((p0) => p0.$2.color, 'color', 0xff69f0ae),
    ),);
    expect(records, anyElement(isA<FullEntry>()
      .having((p0) => p0.$1.time.millisecondsSinceEpoch, 'timestamp', 1702883511000)
      .having((p0) => p0.$1.sys?.mmHg, 'systolic', 114)
      .having((p0) => p0.$1.dia?.mmHg, 'diastolic', 71)
      .having((p0) => p0.$1.pul, 'pulse', 66)
      .having((p0) => p0.$2.note, 'notes', 'fsaf &_*¢|^✓[=%®©')
      .having((p0) => p0.$2.color, 'color', Colors.lightGreen.value),
    ),);
    expect(records, anyElement(isA<FullEntry>()
      .having((p0) => p0.$1.time.millisecondsSinceEpoch, 'timestamp', 1701034952000)
      .having((p0) => p0.$1.sys?.mmHg, 'systolic', 125)
      .having((p0) => p0.$1.dia?.mmHg, 'diastolic', 77)
      .having((p0) => p0.$1.pul, 'pulse', 60)
      .having((p0) => p0.$2.note, 'notes', '')
      .having((p0) => p0.$2.color, 'color', null),
    ),);
    expect(records, anyElement(isA<FullEntry>()
        .having((p0) => p0.$1.time.millisecondsSinceEpoch, 'timestamp', 1077625200000)
        .having((p0) => p0.$1.sys?.mmHg, 'systolic', 100)
        .having((p0) => p0.$1.dia?.mmHg, 'diastolic', 82)
        .having((p0) => p0.$1.pul, 'pulse', 63)
        .having((p0) => p0.$2.note, 'notes', '')
        .having((p0) => p0.$2.color, 'pin', null),
    ),);
  });
  test('should decode formated times', () {
    final text = File('test/model/export_import/exported_formats/formatted_times.csv').readAsStringSync();

    final cols = ExportColumnsManager();
    cols.addOrUpdate(TimeColumn('someTime', 'yyyy-MM-dd HH:mm'));
    final converter = CsvConverter(
      CsvExportSettings(
        exportFieldsConfiguration: ActiveExportColumnConfiguration(
          activePreset: ExportImportPreset.none,
          userSelectedColumnIds: [],
        )
      ),
      cols,
      [],
    );
    final parsed = converter.parse(text);

    final records = parsed.getOr(failParse);
    expect(records, isNotNull);
    expect(records.length, 3);
    expect(records, contains(isA<FullEntry>()
      .having((c) => c.sys?.mmHg, 'sys', 1)
      .having((c) => c.time.year, 'year', 2024)
      .having((c) => c.time.month, 'month', 3)
      .having((c) => c.time.day, 'day', 12)
      .having((c) => c.time.hour, 'hour', 15)
      .having((c) => c.time.minute, 'minute', 45),
    ));
    expect(records, contains(isA<FullEntry>()
      .having((c) => c.sys?.mmHg, 'sys', 2)
      .having((c) => c.time.year, 'year', 2004)
      .having((c) => c.time.month, 'month', 12)
      .having((c) => c.time.day, 'day', 8)
      .having((c) => c.time.hour, 'hour', 0)
      .having((c) => c.time.minute, 'minute', 42),
    ));
    expect(records, contains(isA<FullEntry>()
      .having((c) => c.sys?.mmHg, 'sys', 3)
      .having((c) => c.time.year, 'year', 2012)
      .having((c) => c.time.month, 'month', 10)
      .having((c) => c.time.day, 'day', 8)
      .having((c) => c.time.hour, 'hour', 0)
      .having((c) => c.time.minute, 'minute', 4),
    ));
  });
}

List<(DateTime, BloodPressureRecord, Note, List<MedicineIntake>, Null)> createRecords([int count = 20]) => [
  for (int i = 0; i<count; i++)
    mockEntryPos(DateTime.fromMillisecondsSinceEpoch(123456 + i),
        i, 100+i, 200+1, 'note $i', Color(123+i),),
].map((e) => (e.time, e.recordObj, e.noteObj, e.intakes, null))
    .toList();

List<FullEntry>? failParse(EntryParsingError error) {
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
