import 'package:blood_pressure_app/model/export_import/column.dart';
import 'package:blood_pressure_app/model/export_import/import_field_type.dart';
import 'package:blood_pressure_app/model/export_import/record_formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health_data_store/health_data_store.dart';

import '../../features/measurement_list/measurement_list_entry_test.dart';
import '../../util.dart';
import 'record_formatter_test.dart';

void main() {
  group('NativeColumn', () {
    test('should contain fields in allColumns', () {
      expect(NativeColumn.allColumns, containsAll([
        NativeColumn.timestampUnixMs,
        NativeColumn.systolic,
        NativeColumn.diastolic,
        NativeColumn.pulse,
        NativeColumn.notes,
        NativeColumn.color,
        NativeColumn.needlePin,
      ]),);
    });
    test('should have internalIdentifier prefixed with "native."', () {
      for (final c in NativeColumn.allColumns) {
        expect(c.internalIdentifier, startsWith('native.'));
      }
    });
    test('should encode into non-empty string', () {
      // Use BuildInColumn for utility columns
      for (final c in NativeColumn.allColumns) {
        final r = _filledRecord(true);
        expect(c.encode(r.$1, r.$2, r.$3, null), isNotEmpty, reason: '${c.internalIdentifier} is NativeColumn');
      }
    });
    test('should only contain restoreable types', () {
      // Use BuildInColumn for utility columns
      for (final c in NativeColumn.allColumns) {
        expect(c.restoreAbleType, isNotNull);
      }
    });
    test('should decode correctly', () {
      final r = _filledRecord(true);
      for (final c in NativeColumn.allColumns) {
        final txt = c.encode(r.$1, r.$2, r.$3, null);
        final decoded = c.decode(txt);
        expect(decoded, isNotNull, reason: 'a real value was encoded: ${c.internalIdentifier}: ${r.debugToString()} > $txt');
        switch (decoded!.$1) {
          case RowDataFieldType.timestamp:
            expect(decoded.$2, isA<DateTime>().having(
              (p0) => p0.millisecondsSinceEpoch, 'milliseconds', r.$1.time.millisecondsSinceEpoch,),);
            break;
        case RowDataFieldType.sys:
          expect(decoded.$2, isA<int>()
            .having((p0) => p0, 'systolic', r.$1.sys?.mmHg));
        case RowDataFieldType.dia:
          expect(decoded.$2, isA<int>()
            .having((p0) => p0, 'diastolic', r.$1.dia?.mmHg));
        case RowDataFieldType.pul:
          expect(decoded.$2, isA<int>()
            .having((p0) => p0, 'pulse', r.$1.pul));
        case RowDataFieldType.notes:
          expect(decoded.$2, isA<String>()
            .having((p0) => p0, 'note', r.$2.note));
        case RowDataFieldType.color:
          expect(decoded.$2, isA<int>()
            .having((p0) => p0, 'pin', r.$2.color));
        case RowDataFieldType.intakes:
          expect(decoded.$2, isA<List>()
            .having((p0) => p0.length, 'length', 1,)
            .having((p0) => p0[0].$1, 'designation', 'mockMed',)
            .having((p0) => p0[0].$2, 'dosis', 123.4,));
          case RowDataFieldType.weightKg:
            // TODO: Handle this case.
            throw UnimplementedError();
        }
      }
    });
  });

  group('BuildInColumn', () {
    test('should contain fields in allColumns', () {
      expect(BuildInColumn.allColumns, containsAll([
        BuildInColumn.pulsePressure,
        BuildInColumn.mhDate,
        BuildInColumn.mhSys,
        BuildInColumn.mhDia,
        BuildInColumn.mhPul,
        BuildInColumn.mhDesc,
        BuildInColumn.mhTags,
        BuildInColumn.mhWeight,
        BuildInColumn.mhOxygen,
      ]),);
    });
    test('should have internalIdentifier prefixed with "buildin."', () {
      for (final c in BuildInColumn.allColumns) {
        expect(c.internalIdentifier, startsWith('buildin.'));
      }
    });
    test('should encode without problems', () {
      for (final c in BuildInColumn.allColumns) {
        final r = _filledRecord();
        expect(c.encode(r.$1, r.$2, r.$3, null), isNotNull);
      }
    });
    test('should decode correctly', () {
      final r = _filledRecord(true);
      for (final c in BuildInColumn.allColumns) {
        final txt = c.encode(r.$1, r.$2, r.$3, null);
        final decoded = c.decode(txt);
        switch (decoded?.$1) {
          case RowDataFieldType.timestamp:
            if (c is TimeColumn) {
              // This ensures no columns with useless conversions get introduced.
              expect(decoded?.$2, isA<DateTime>().having(
                  (p0) => p0.difference(r.$1.time).inDays,
                  'inaccuracy',
                  lessThan(1),),);
            } else {
              expect(decoded?.$2, isA<DateTime>().having(
                  (p0) => p0.millisecondsSinceEpoch, 'milliseconds', r.$1.time.millisecondsSinceEpoch,),);
            }
          case RowDataFieldType.sys:
            expect(decoded?.$2, isA<int>()
              .having((p0) => p0, 'systolic', r.$1.sys?.mmHg));
          case RowDataFieldType.dia:
            expect(decoded?.$2, isA<int>()
              .having((p0) => p0, 'diastolic', r.$1.dia?.mmHg));
          case RowDataFieldType.pul:
            expect(decoded?.$2, isA<int>()
              .having((p0) => p0, 'pulse', r.$1.pul));
          case RowDataFieldType.notes:
            expect(decoded?.$2, isA<String>()
              .having((p0) => p0, 'note', r.$2.note));
          case RowDataFieldType.color:
            expect(decoded?.$2, isA<int>()
              .having((p0) => p0, 'pin', r.$2.color));
          case RowDataFieldType.intakes:
            expect(decoded?.$2, isA<List<(String, double)>>()
              .having((p0) => p0.length, 'length', 1,)
              .having((p0) => p0[0].$1, 'designation', 'mockMed',)
              .having((p0) => p0[0].$2, 'dosis', 123.4,));
          case null:
            // no-op
          case RowDataFieldType.weightKg:
            // TODO: Handle this case.
            throw UnimplementedError();
        }
      }
    });
  });

  group('UserColumn', () {
    test('should have internalIdentifier prefixed with "userColumn."', () {
      final column = UserColumn('test', 'csvTitle', 'pattern');
      expect(column.internalIdentifier, startsWith('userColumn.'));
    });
    test('should encode like ScriptedFormatter', () {
      final r = _filledRecord();
      expect(
        UserColumn('','', 'TEST').encode(r.$1, r.$2, r.$3, null),
        ScriptedFormatter('TEST').encode(r.$1, r.$2, r.$3, null),
      );
      expect(
        UserColumn('','', r'$SYS').encode(r.$1, r.$2, r.$3, null),
        ScriptedFormatter(r'$SYS').encode(r.$1, r.$2, r.$3, null),
      );
      expect(
        UserColumn('','', r'$SYS-$DIA').encode(r.$1, r.$2, r.$3, null),
        ScriptedFormatter(r'$SYS-$DIA').encode(r.$1, r.$2, r.$3, null),
      );
      expect(
        UserColumn('','', r'$TIMESTAMP').encode(r.$1, r.$2, r.$3, null),
        ScriptedFormatter(r'$TIMESTAMP').encode(r.$1, r.$2, r.$3, null),
      );
      expect(
        UserColumn('','', '').encode(r.$1, r.$2, r.$3, null),
        ScriptedFormatter('').encode(r.$1, r.$2, r.$3, null),
      );
    });
    test('should decode like ScriptedFormatter', () {
      final r = _filledRecord();
      final testPatterns = ['TEST', r'$SYS', r'{{$SYS-$DIA}}', r'$TIMESTAMP', ''];

      for (final pattern in testPatterns) {
        final column = UserColumn('','', pattern);
        final formatter = ScriptedFormatter(pattern);
        expect(
          column.decode(column.encode(r.$1, r.$2, r.$3, null)),
          formatter.decode(formatter.encode(r.$1, r.$2, r.$3, null)),
        );
      }
    });
  });

  group('TimeColumn', () {
    test('should have internalIdentifier prefixed with "timeFormatter."', () {
      final column = TimeColumn('csvTitle', 'formatPattern');
      expect(column.internalIdentifier, startsWith('timeFormatter.'));
    });
  });
}

FullEntry _filledRecord([bool addIntakes = false]) => mockEntry(
  sys: 123,
  dia: 456,
  pul: 789,
  note: 'test',
  pin: Colors.pink,
  intake: addIntakes
    ? mockIntake(mockMedicine(designation: 'mockMed'), dosis: 123.4,)
    : null,
);
