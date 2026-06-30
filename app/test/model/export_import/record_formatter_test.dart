import 'package:blood_pressure_app/features/export_import/model/import_field_type.dart';
import 'package:blood_pressure_app/features/export_import/model/record_formatter.dart';
import 'package:blood_pressure_app/features/input/forms/add_entry_form.dart';
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
      f.encode(r1.record!, r1.note!, [if (r1.intake != null) r1.intake!], null);
      final r2 = mockEntry();
      f.encode(r2.record!, r2.note!, [if (r2.intake != null) r2.intake!], null);
      f.decode('123');
    });
    test('should create correct strings', () {
      final r = mockEntryPos(DateTime.fromMillisecondsSinceEpoch(31415926), 123, 45, 67, 'Test', Colors.red);

      expect(ScriptedFormatter(r'constant text',).encode(r.record!, r.note!, [if (r.intake != null) r.intake!], null), 'constant text');
      expect(ScriptedFormatter(r'$SYS',).encode(r.record!, r.note!, [if (r.intake != null) r.intake!], null), r.sys?.mmHg.toString());
      expect(ScriptedFormatter(r'$DIA',).encode(r.record!, r.note!, [if (r.intake != null) r.intake!], null), r.dia?.mmHg.toString());
      expect(ScriptedFormatter(r'$PUL',).encode(r.record!, r.note!, [if (r.intake != null) r.intake!], null), r.pul.toString());
      expect(ScriptedFormatter(r'$COLOR',).encode(r.record!, r.note!, [if (r.intake != null) r.intake!], null), r.note?.color.toString());
      expect(ScriptedFormatter(r'$NOTE',).encode(r.record!, r.note!, [if (r.intake != null) r.intake!], null), r.note?.note);
      expect(ScriptedFormatter(r'$TIMESTAMP',).encode(r.record!, r.note!, [if (r.intake != null) r.intake!], null), r.time.millisecondsSinceEpoch.toString());
      expect(
        ScriptedFormatter(r'$SYS$DIA$PUL',).encode(r.record!, r.note!, [if (r.intake != null) r.intake!], null),
        (r.sys!.mmHg.toString() + r.dia!.mmHg.toString() + r.pul.toString()),);
      expect(
        ScriptedFormatter(r'$SYS$SYS',).encode(r.record!, r.note!, [if (r.intake != null) r.intake!], null),
        (r.sys!.mmHg.toString() + r.sys!.mmHg.toString()),);
      expect(
        ScriptedFormatter(r'{{$SYS-$DIA}}',).encode(r.record!, r.note!, [if (r.intake != null) r.intake!], null),
        (r.sys!.mmHg - r.dia!.mmHg).toDouble().toString(),);
      expect(
        ScriptedFormatter(r'{{$SYS*$DIA-$PUL}}',).encode(r.record!, r.note!, [if (r.intake != null) r.intake!], null),
          (r.sys!.mmHg * r.dia!.mmHg - r.pul!).toDouble().toString(),);
      expect(
          ScriptedFormatter(r'$SYS-$DIA',).encode(r.record!, r.note!, [if (r.intake != null) r.intake!], null), ('${r.sys?.mmHg}-${r.dia?.mmHg}'));

      final formatter = DateFormat.yMMMMEEEEd();
      expect(ScriptedFormatter('\$FORMAT{\$TIMESTAMP,${formatter.pattern}}',).encode(r.record!, r.note!, [if (r.intake != null) r.intake!], null),
          formatter.format(r.time),);
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
      final encodedPurple = ScriptedFormatter(r'$COLOR',).encode(r.record!, r.note!, [if (r.intake != null) r.intake!], null);
      expect(ScriptedFormatter(r'$COLOR',).decode(encodedPurple)?.$1, RowDataFieldType.color);
      expect(ScriptedFormatter(r'$COLOR',).decode(encodedPurple)?.$2, Colors.purple.toARGB32());
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
      expect(ScriptedFormatter(r'($SYS)',).encode(r1.record!, r1.note!, [if (r1.intake != null) r1.intake!], null), '(123)');
      expect(ScriptedFormatter(r'($SYS',).encode(r1.record!, r1.note!, [if (r1.intake != null) r1.intake!], null), '(123');
      final r2 = mockEntry(note: 'test');
      expect(ScriptedFormatter(r'($NOTE',).encode(r2.record!, r2.note!, [if (r2.intake != null) r2.intake!], null), '(test');

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
      expect(ScriptedTimeFormatter('dd').encode(r1.record!, r1.note!, [if (r1.intake != null) r1.intake!], null), isNotNull);
      expect(ScriptedTimeFormatter('dd').encode(r1.record!, r1.note!, [if (r1.intake != null) r1.intake!], null), isNotEmpty);
    });
    test('should decode rough time', () {
      final formatter = ScriptedTimeFormatter('yyyy.MMMM.dd GGG hh:mm.ss aaa');
      final r = mockEntry();
      expect(formatter.encode(r.record!, r.note!, [if (r.intake != null) r.intake!], null), isNotNull);
      expect(formatter.decode(formatter.encode(r.record!, r.note!, [if (r.intake != null) r.intake!], null))?.$2, isA<DateTime>()
        .having((p0) => p0.millisecondsSinceEpoch, 'time(up to one second difference)', closeTo(r.time.millisecondsSinceEpoch, 1000)),);
    });
  });
}

AddEntryFormValue mockEntryPos([
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

AddEntryFormValue mockEntry({
  DateTime? time,
  int? sys,
  int? dia,
  int? pul,
  String? note,
  Color? pin,
  MedicineIntake? intake,
}) {
  time ??= DateTime.now();
  return (
  timestamp: time,
    record: BloodPressureRecord(
      time: time,
      sys: sys == null ? null : Pressure.mmHg(sys),
      dia: dia == null ? null : Pressure.mmHg(dia),
      pul: pul,
    ),
    note: Note(
      time: time,
      note: note,
      color: pin?.toARGB32(),
    ),
    intake: intake,
    weight: null,
  );
}

extension DebugFormat on AddEntryFormValue {
  String debugToString() => 'FullEntry('
    'time: $time, '
    'sys: ${sys?.mmHg}, '
    'dia: ${dia?.mmHg}, '
    'pul: $pul, '
    'note: $note, '
    'color: $color, '
    'intake: $intake'
  ')';
}
