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
      final r1 = mockEntryPos(DateTime.now(), 123, 456, 789, 'test text');
      f.encode(r1.$1, r1.$2, r1.$3);
      final r2 = mockEntry();
      f.encode(r2.$1, r2.$2, r2.$3);
      f.decode('123');
    });
    test('should create correct strings', () {
      final r = mockEntryPos(DateTime.fromMillisecondsSinceEpoch(31415926), 123, 45, 67, 'Test', Colors.red);

      expect(ScriptedFormatter(r'constant text',).encode(r.$1, r.$2, r.$3), 'constant text');
      expect(ScriptedFormatter(r'$SYS',).encode(r.$1, r.$2, r.$3), r.$1.sys?.mmHg.toString());
      expect(ScriptedFormatter(r'$DIA',).encode(r.$1, r.$2, r.$3), r.$1.dia?.mmHg.toString());
      expect(ScriptedFormatter(r'$PUL',).encode(r.$1, r.$2, r.$3), r.$1.pul.toString());
      expect(ScriptedFormatter(r'$COLOR',).encode(r.$1, r.$2, r.$3), r.$2.color.toString());
      expect(ScriptedFormatter(r'$NOTE',).encode(r.$1, r.$2, r.$3), r.$2.note);
      expect(ScriptedFormatter(r'$TIMESTAMP',).encode(r.$1, r.$2, r.$3), r.$1.time.millisecondsSinceEpoch.toString());
      expect(
        ScriptedFormatter(r'$SYS$DIA$PUL',).encode(r.$1, r.$2, r.$3),
        (r.$1.sys!.mmHg.toString() + r.$1.dia!.mmHg.toString() + r.$1.pul.toString()),);
      expect(
        ScriptedFormatter(r'$SYS$SYS',).encode(r.$1, r.$2, r.$3),
        (r.$1.sys!.mmHg.toString() + r.$1.sys!.mmHg.toString()),);
      expect(
        ScriptedFormatter(r'{{$SYS-$DIA}}',).encode(r.$1, r.$2, r.$3),
        (r.$1.sys!.mmHg - r.$1.dia!.mmHg).toDouble().toString(),);
      expect(
        ScriptedFormatter(r'{{$SYS*$DIA-$PUL}}',).encode(r.$1, r.$2, r.$3),
          (r.$1.sys!.mmHg * r.$1.dia!.mmHg - r.$1.pul!).toDouble().toString(),);
      expect(
          ScriptedFormatter(r'$SYS-$DIA',).encode(r.$1, r.$2, r.$3), ('${r.$1.sys?.mmHg}-${r.$1.dia?.mmHg}'));

      final formatter = DateFormat.yMMMMEEEEd();
      expect(ScriptedFormatter('\$FORMAT{\$TIMESTAMP,${formatter.pattern}}',).encode(r.$1, r.$2, r.$3),
          formatter.format(r.$1.time),);
    });
    test('should report correct reversibility', () {
      expect(ScriptedFormatter(r'$SYS',).restoreAbleType, RowDataFieldType.sys);
      expect(ScriptedFormatter(r'$DIA',).restoreAbleType, RowDataFieldType.dia);
      expect(ScriptedFormatter(r'$PUL',).restoreAbleType, RowDataFieldType.pul);
      expect(ScriptedFormatter(r'$TIMESTAMP',).restoreAbleType, RowDataFieldType.timestamp);
      expect(ScriptedFormatter(r'$NOTE',).restoreAbleType, RowDataFieldType.notes);
      expect(ScriptedFormatter(r'$COLOR',).restoreAbleType, RowDataFieldType.color);
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
      final r = mockEntryPos(DateTime.now(), null, null, null, '', Colors.purple);
      final encodedPurple = ScriptedFormatter(r'$COLOR',).encode(r.$1, r.$2, r.$3);
      expect(ScriptedFormatter(r'$COLOR',).decode(encodedPurple)?.$1, RowDataFieldType.color);
      expect(ScriptedFormatter(r'$COLOR',).decode(encodedPurple)?.$2, Colors.purple.value);
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
      final r1 = mockEntry(sys: 123);
      expect(ScriptedFormatter(r'($SYS)',).encode(r1.$1, r1.$2, r1.$3), '(123)');
      expect(ScriptedFormatter(r'($SYS',).encode(r1.$1, r1.$2, r1.$3), '(123');
      final r2 = mockEntry(note: 'test');
      expect(ScriptedFormatter(r'($NOTE',).encode(r2.$1, r2.$2, r2.$3), '(test');

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
      final r1 = mockEntry();
      expect(ScriptedTimeFormatter('dd').encode(r1.$1, r1.$2, r1.$3), isNotNull);
      expect(ScriptedTimeFormatter('dd').encode(r1.$1, r1.$2, r1.$3), isNotEmpty);
    });
    test('should decode rough time', () {
      final formatter = ScriptedTimeFormatter('yyyy.MMMM.dd GGG hh:mm.ss aaa');
      final r = mockEntry();
      expect(formatter.encode(r.$1, r.$2, r.$3), isNotNull);
      expect(formatter.decode(formatter.encode(r.$1, r.$2, r.$3))?.$2, isA<DateTime>()
        .having((p0) => p0.millisecondsSinceEpoch, 'time(up to one second difference)', closeTo(r.$1.time.millisecondsSinceEpoch, 1000)),);
    });
  });
}

FullEntry mockEntryPos([
  DateTime? time,
  int? sys,
  int? dia,
  int? pul,
  String? note,
  Color? pin,
]) => mockEntry(
  time: time,
  sys: sys,
  dia: dia,
  pul: pul,
  note: note,
  pin: pin,
);

FullEntry mockEntry({
  DateTime? time,
  int? sys,
  int? dia,
  int? pul,
  String? note,
  Color? pin,
}) {
  time ??= DateTime.now();
  return (
    BloodPressureRecord(
      time: time,
      sys: sys == null ? null : Pressure.mmHg(sys),
      dia: dia == null ? null : Pressure.mmHg(dia),
      pul: pul,
    ),
    Note(
      time: time,
      note: note,
      color: pin?.value,
    ),
    [],
  );
}
