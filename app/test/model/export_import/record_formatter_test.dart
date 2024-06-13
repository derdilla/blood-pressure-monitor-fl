import 'package:blood_pressure_app/model/blood_pressure/needle_pin.dart';
import 'package:blood_pressure_app/model/export_import/import_field_type.dart';
import 'package:blood_pressure_app/model/export_import/record_formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health_data_store/health_data_store.dart';
import 'package:intl/intl.dart';

void main() {
  group('ScriptedFormatter', () {
    test('should not throw errors', () async {
      final f = ScriptedFormatter(r'$SYS');
      
      expect(f.formatPattern, r'$SYS');
      f.encode(mockRecordPos(DateTime.now(), 123, 456, 789, 'test text'));
      f.encode(mockRecord());
      f.decode('123');
    });
    test('should create correct strings', () {
      final testRecord = mockRecordPos(DateTime.fromMillisecondsSinceEpoch(31415926), 123, 45, 67, 'Test', Colors.red);

      expect(ScriptedFormatter(r'constant text',).encode(testRecord), 'constant text');
      expect(ScriptedFormatter(r'$SYS',).encode(testRecord), testRecord.sys.toString());
      expect(ScriptedFormatter(r'$DIA',).encode(testRecord), testRecord.dia.toString());
      expect(ScriptedFormatter(r'$PUL',).encode(testRecord), testRecord.pul.toString());
      /*expect(ScriptedFormatter(r'$COLOR',).encode(testRecord), jsonEncode(testRecord.needlePin!.toMap())); FIXME
      expect(ScriptedFormatter(r'$NOTE',).encode(testRecord), testRecord.notes);*/
      expect(ScriptedFormatter(r'$TIMESTAMP',).encode(testRecord), testRecord.time.millisecondsSinceEpoch.toString());
      expect(ScriptedFormatter(r'$SYS$DIA$PUL',).encode(testRecord), (testRecord.sys!.mmHg.toString()
        + testRecord.dia!.mmHg.toString() + testRecord.pul.toString()),);
      expect(ScriptedFormatter(r'$SYS$SYS',).encode(testRecord), (testRecord.sys!.mmHg.toString()
        + testRecord.sys!.mmHg.toString()),);
      expect(ScriptedFormatter(r'{{$SYS-$DIA}}',).encode(testRecord),
        (testRecord.sys!.mmHg - testRecord.dia!.mmHg).toDouble().toString(),);
      expect(ScriptedFormatter(r'{{$SYS*$DIA-$PUL}}',).encode(testRecord),
          (testRecord.sys!.mmHg * testRecord.dia!.mmHg - testRecord.pul!).toDouble().toString(),);
      expect(ScriptedFormatter(r'$SYS-$DIA',).encode(testRecord), ('${testRecord.sys}-${testRecord.dia}'));

      final formatter = DateFormat.yMMMMEEEEd();
      expect(ScriptedFormatter('\$FORMAT{\$TIMESTAMP,${formatter.pattern}}',).encode(testRecord),
          formatter.format(testRecord.time),);
    });
    test('should report correct reversibility', () {
      expect(ScriptedFormatter(r'$SYS',).restoreAbleType, RowDataFieldType.sys);
      expect(ScriptedFormatter(r'$DIA',).restoreAbleType, RowDataFieldType.dia);
      expect(ScriptedFormatter(r'$PUL',).restoreAbleType, RowDataFieldType.pul);
      expect(ScriptedFormatter(r'$TIMESTAMP',).restoreAbleType, RowDataFieldType.timestamp);
      expect(ScriptedFormatter(r'$NOTE',).restoreAbleType, RowDataFieldType.notes);
      expect(ScriptedFormatter(r'$COLOR',).restoreAbleType, RowDataFieldType.needlePin);
      expect(ScriptedFormatter(r'test$SYS123',).restoreAbleType, RowDataFieldType.sys);
      expect(ScriptedFormatter(r'test$DIA123',).restoreAbleType, RowDataFieldType.dia);
      expect(ScriptedFormatter(r'test$PUL123',).restoreAbleType, RowDataFieldType.pul);

      expect(ScriptedFormatter(r'test$NOTE',).restoreAbleType, null);
      expect(ScriptedFormatter(r'test$NOTE123',).restoreAbleType, null);
      expect(ScriptedFormatter(r'{{$PUL-$SYS}}',).restoreAbleType, null);
      expect(ScriptedFormatter(r'$PUL$SYS',).restoreAbleType, null);
      expect(ScriptedFormatter(r'$SYS$SYS',).restoreAbleType, null);
    });
    test('should correctly decode reversible patterns', () {
      expect(ScriptedFormatter(r'$SYS',).decode('123'), (RowDataFieldType.sys, 123));
      expect(ScriptedFormatter(r'$DIA',).decode('456'), (RowDataFieldType.dia, 456));
      expect(ScriptedFormatter(r'$PUL',).decode('789'), (RowDataFieldType.pul, 789));
      expect(ScriptedFormatter(r'$TIMESTAMP',).decode('12345678'), (RowDataFieldType.timestamp, DateTime.fromMillisecondsSinceEpoch(12345678)));
      expect(ScriptedFormatter(r'$NOTE',).decode('test note'), (RowDataFieldType.notes, 'test note'));
      final encodedPurple = ScriptedFormatter(r'$COLOR',)
        .encode(mockRecordPos(DateTime.now(), null, null, null, '', Colors.purple));
      expect(ScriptedFormatter(r'$COLOR',).decode(encodedPurple)?.$1, RowDataFieldType.needlePin);
      expect(ScriptedFormatter(r'$COLOR',).decode(encodedPurple)?.$2, isA<MeasurementNeedlePin>()
          .having((p0) => p0.color.value, 'color', Colors.purple.value),);
      expect(ScriptedFormatter(r'test$SYS',).decode('test567'), (RowDataFieldType.sys, 567));
      expect(ScriptedFormatter(r'test$SYS123',).decode('test567123'), (RowDataFieldType.sys, 567));
      expect(ScriptedFormatter(r'test$DIA123',).decode('test567123'), (RowDataFieldType.dia, 567));
      expect(ScriptedFormatter(r'test$PUL123',).decode('test567123'), (RowDataFieldType.pul, 567));
    });

    test('should not decode irreversible patterns', () {
      expect(ScriptedFormatter(r'test$NOTE',).decode('testNote'), null);
      expect(ScriptedFormatter(r'test$NOTE123',).decode('testNote123'), null);
      expect(ScriptedFormatter(r'{{$PUL-$SYS}}',).decode('1234'), null);
      expect(ScriptedFormatter(r'$PUL$SYS',).decode('123456'), null);
      expect(ScriptedFormatter(r'$SYS$SYS',).decode('123123'), null);
    });

    test('should when ignore groups in format strings', () {
      expect(ScriptedFormatter(r'($SYS)',).encode(mockRecord(sys: 123)), '(123)');
      expect(ScriptedFormatter(r'($SYS',).encode(mockRecord(sys: 123)), '(123');
      expect(ScriptedFormatter(r'($NOTE',).encode(mockRecord(note: 'test')), '(test');

      expect(ScriptedFormatter(r'($SYS)',).restoreAbleType, RowDataFieldType.sys);
      expect(ScriptedFormatter(r'($SYS',).restoreAbleType, RowDataFieldType.sys);
      expect(ScriptedFormatter(r'($NOTE',).restoreAbleType, null);

      expect(ScriptedFormatter(r'($SYS)',).decode('(123)'), (RowDataFieldType.sys, 123));
      expect(ScriptedFormatter(r'($SYS',).decode('(123'), (RowDataFieldType.sys, 123));
      expect(ScriptedFormatter(r'($NOTE',).decode('(test'), null);
    });
    test('should needlepin ignore invalid json', () {
      expect(ScriptedFormatter(r'$COLOR',).decode(''), null);
      expect(ScriptedFormatter(r'$COLOR',).decode('null'), null);
      expect(ScriptedFormatter(r'$COLOR',).decode('{test'), null);
      expect(ScriptedFormatter(r'$COLOR',).decode('{"test": 1}'), null);
      expect(ScriptedFormatter(r'$COLOR',).decode('{}'), null);
    });
  });

  group('ScriptedTimeFormatter', () {
    test('should create non-empty string', () {
      expect(ScriptedTimeFormatter('dd').encode(mockRecord()), isNotNull);
      expect(ScriptedTimeFormatter('dd').encode(mockRecord()), isNotEmpty);
    });
    test('should decode rough time', () {
      final formatter = ScriptedTimeFormatter('yyyy.MMMM.dd GGG hh:mm.ss aaa');
      final r = mockRecord();
      expect(formatter.encode(r), isNotNull);
      expect(formatter.decode(formatter.encode(r))?.$2, isA<DateTime>()
        .having((p0) => p0.millisecondsSinceEpoch, 'time(up to one second difference)', closeTo(r.time.millisecondsSinceEpoch, 1000)),);
    });
  });
}

BloodPressureRecord mockRecordPos([
  DateTime? time,
  int? sys,
  int? dia,
  int? pul,
  String? notes,
  Color? pin,
]) => BloodPressureRecord(
  time: time ?? DateTime.now(),
  sys: sys == null ? null : Pressure.mmHg(sys),
  dia: dia == null ? null : Pressure.mmHg(dia),
  pul: pul,
  //note ?? '', FIXME
  //needlePin: pin == null ? null : MeasurementNeedlePin(pin),
);

BloodPressureRecord mockRecord({
  DateTime? time,
  int? sys,
  int? dia,
  int? pul,
  String? note,
  Color? pin,
}) => BloodPressureRecord(
  time: time ?? DateTime.now(),
  sys: sys == null ? null : Pressure.mmHg(sys),
  dia: dia == null ? null : Pressure.mmHg(dia),
  pul: pul,
  // note ?? '', FIXME
  // needlePin: pin == null ? null : MeasurementNeedlePin(pin),
);
