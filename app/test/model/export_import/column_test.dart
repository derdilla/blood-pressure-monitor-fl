import 'package:blood_pressure_app/model/export_import/column.dart';
import 'package:blood_pressure_app/model/export_import/import_field_type.dart';
import 'package:blood_pressure_app/model/export_import/record_formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health_data_store/health_data_store.dart';

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
        final r = _filledRecord();
        expect(c.encode(r.$1, r.$2, r.$3), isNotEmpty, reason: '${c.internalIdentifier} is NativeColumn');
      }
    });
    test('should only contain restoreable types', () {
      // Use BuildInColumn for utility columns
      for (final c in NativeColumn.allColumns) {
        expect(c.restoreAbleType, isNotNull);
      }
    });
    test('should decode correctly', () {
      final r = _filledRecord();
      for (final c in NativeColumn.allColumns) {
        final txt = c.encode(r.$1, r.$2, r.$3);
        final decoded = c.decode(txt);
        expect(decoded, isNotNull, reason: 'a real value was encoded: ${c.internalIdentifier}: $r > $txt');
        switch (decoded!.$1) {
          case RowDataFieldType.timestamp:
            expect(decoded.$2, isA<DateTime>().having(
              (p0) => p0.millisecondsSinceEpoch, 'milliseconds', r.$1.time.millisecondsSinceEpoch,),);
            break;
          case RowDataFieldType.sys:
            expect(decoded.$2, isA<int>().having(
                    (p0) => p0, 'systolic', r.$1.sys?.mmHg,),);
            break;
          case RowDataFieldType.dia:
            expect(decoded.$2, isA<int>().having(
                    (p0) => p0, 'diastolic', r.$1.dia?.mmHg,),);
            break;
          case RowDataFieldType.pul:
            expect(decoded.$2, isA<int>().having(
                    (p0) => p0, 'pulse', r.$1.pul,),);
            break;
          case RowDataFieldType.notes:
            expect(decoded.$2, isA<String>().having(
                    (p0) => p0, 'pulse', r.$2.note,),);
            break;
          case RowDataFieldType.color:
            expect(decoded.$2, isA<int>().having(
                    (p0) => p0, 'color', r.$2.color,),);
            break;
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
        expect(c.encode(r.$1, r.$2, r.$3), isNotNull);
      }
    });
    test('should decode correctly', () {
      final r = _filledRecord();
      for (final c in BuildInColumn.allColumns) {
        final txt = c.encode(r.$1, r.$2, r.$3);
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
            break;
          case RowDataFieldType.sys:
            expect(decoded?.$2, isA<int>().having(
                    (p0) => p0, 'systolic', r.$1.sys?.mmHg,),);
            break;
          case RowDataFieldType.dia:
            expect(decoded?.$2, isA<int>().having(
                    (p0) => p0, 'diastolic', r.$1.dia?.mmHg,),);
            break;
          case RowDataFieldType.pul:
            expect(decoded?.$2, isA<int>().having(
                    (p0) => p0, 'pulse', r.$1.pul,),);
            break;
          case RowDataFieldType.notes:
            expect(decoded?.$2, isA<String>().having(
                    (p0) => p0, 'note', r.$2.note,),);
            break;
          case RowDataFieldType.color:
            expect(decoded?.$2, isA<int>().having(
                    (p0) => p0, 'pin', r.$2.color,),);
            break;
          case null:
            break;
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
        UserColumn('','', 'TEST').encode(r.$1, r.$2, r.$3),
        ScriptedFormatter('TEST').encode(r.$1, r.$2, r.$3),
      );
      expect(
        UserColumn('','', r'$SYS').encode(r.$1, r.$2, r.$3),
        ScriptedFormatter(r'$SYS').encode(r.$1, r.$2, r.$3),
      );
      expect(
        UserColumn('','', r'$SYS-$DIA').encode(r.$1, r.$2, r.$3),
        ScriptedFormatter(r'$SYS-$DIA').encode(r.$1, r.$2, r.$3),
      );
      expect(
        UserColumn('','', r'$TIMESTAMP').encode(r.$1, r.$2, r.$3),
        ScriptedFormatter(r'$TIMESTAMP').encode(r.$1, r.$2, r.$3),
      );
      expect(
        UserColumn('','', '').encode(r.$1, r.$2, r.$3),
        ScriptedFormatter('').encode(r.$1, r.$2, r.$3),
      );
    });
    test('should decode like ScriptedFormatter', () {
      final r = _filledRecord();
      final testPatterns = ['TEST', r'$SYS', r'{{$SYS-$DIA}}', r'$TIMESTAMP', ''];

      for (final pattern in testPatterns) {
        final column = UserColumn('','', pattern);
        final formatter = ScriptedFormatter(pattern);
        expect(
          column.decode(column.encode(r.$1, r.$2, r.$3)),
          formatter.decode(formatter.encode(r.$1, r.$2, r.$3)),
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

FullEntry _filledRecord() => mockEntry(
  sys: 123,
  dia: 456,
  pul: 789,
  note: 'test',
  pin: Colors.pink,
);
