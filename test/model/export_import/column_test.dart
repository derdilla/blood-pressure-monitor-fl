
import 'package:blood_pressure_app/model/blood_pressure.dart';
import 'package:blood_pressure_app/model/export_import/legacy_column.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';

void main() {
  group('ExportColumn', () {
    test('should not throw errors', () async {
      final c = ExportColumn(
          internalName: 'testColumn',
          columnTitle: 'Test',
          formatPattern: r'$SYS'
      );

      expect(c.internalName, 'testColumn');
      expect(c.columnTitle, 'Test');
      expect(c.formatPattern, r'$SYS');
      c.formatRecord(BloodPressureRecord(DateTime.now(), 123, 45, 67, 'notes'));
      c.formatRecord(BloodPressureRecord(DateTime.now(), null, null, null, ''));
      c.parseRecord('122');
    });
    test('should not change during json conversion', () {
      final original = ExportColumn(
          internalName: 'testColumn',
          columnTitle: 'Test',
          formatPattern: r'{{$SYS-$DIA}}',
      );
      final fromJson = ExportColumn.fromJson(original.toJson());
      expect(original.internalName, fromJson.internalName);
      expect(original.columnTitle, fromJson.columnTitle);
      expect(original.formatPattern, fromJson.formatPattern);
      expect(original.isReversible, fromJson.isReversible);
      expect(original.formatPattern, fromJson.formatPattern);
      expect(original.toJson(), fromJson.toJson());
    });
    test('should create correct strings', () {
      final testRecord = BloodPressureRecord(DateTime.fromMillisecondsSinceEpoch(31415926), 123, 45, 67, 'Test',
          needlePin: const MeasurementNeedlePin(Colors.red));

      expect(_testColumn(r'$SYS',).formatRecord(testRecord), testRecord.systolic.toString());
      expect(_testColumn(r'$DIA',).formatRecord(testRecord), testRecord.diastolic.toString());
      expect(_testColumn(r'$PUL',).formatRecord(testRecord), testRecord.pulse.toString());
      expect(_testColumn(r'$COLOR',).formatRecord(testRecord), testRecord.needlePin!.color.value.toString());
      expect(_testColumn(r'$NOTE',).formatRecord(testRecord), testRecord.notes);
      expect(_testColumn(r'$TIMESTAMP',).formatRecord(testRecord), testRecord.creationTime.millisecondsSinceEpoch.toString());
      expect(_testColumn(r'{{$SYS-$DIA}}',).formatRecord(testRecord),
          (testRecord.systolic! - testRecord.diastolic!).toDouble().toString());
      expect(_testColumn(r'{{$SYS*$DIA-$PUL}}',).formatRecord(testRecord),
          (testRecord.systolic! * testRecord.diastolic! - testRecord.pulse!).toDouble().toString());
      expect(_testColumn(r'$SYS-$DIA',).formatRecord(testRecord), ('${testRecord.systolic}-${testRecord.diastolic}'));

      final formatter = DateFormat.yMMMMEEEEd();
      expect(_testColumn('\$FORMAT{\$TIMESTAMP,${formatter.pattern}}',).formatRecord(testRecord),
          formatter.format(testRecord.creationTime));
    });
    test('should report correct reversibility', () {
      expect(_testColumn(r'$SYS',).isReversible, true);
      expect(_testColumn(r'$DIA',).isReversible, true);
      expect(_testColumn(r'$PUL',).isReversible, true);
      expect(_testColumn(r'$TIMESTAMP',).isReversible, true);
      expect(_testColumn(r'$NOTE',).isReversible, true);
      expect(_testColumn(r'$COLOR',).isReversible, true);
      expect(_testColumn(r'test$NOTE',).isReversible, true);
      expect(_testColumn(r'test$NOTE123',).isReversible, true);
      expect(_testColumn(r'test$SYS123',).isReversible, true);
      expect(_testColumn(r'test$DIA123',).isReversible, true);
      expect(_testColumn(r'test$PUL123',).isReversible, true);

      //expect(_testColumn(r'$PUL$SYS',).isReversible, false);
      expect(_testColumn(r'{{$PUL-$SYS}}',).isReversible, false);
    });
    // TODO: test parsing
  });
}

ExportColumn _testColumn(String formatPattern) =>
    ExportColumn(internalName: '', columnTitle: '', formatPattern: formatPattern,);