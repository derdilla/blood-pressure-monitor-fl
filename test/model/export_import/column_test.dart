import 'package:blood_pressure_app/model/blood_pressure.dart';
import 'package:blood_pressure_app/model/export_import/column.dart';
import 'package:blood_pressure_app/model/export_import/import_field_type.dart';
import 'package:blood_pressure_app/model/export_import/record_formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

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
      ]));
    });
    test('should have internalIdentifier prefixed with "native."', () {
      for (final c in NativeColumn.allColumns) {
        expect(c.internalIdentifier, startsWith("native."));
      }
    });
    test('should encode into non-empty string', () {
      // Use BuildInColumn for utility columns
      for (final c in NativeColumn.allColumns) {
        expect(c.encode(getRecord()), isNotEmpty);
      }
    });
    test('should only contain restoreable types', () {
      // Use BuildInColumn for utility columns
      for (final c in NativeColumn.allColumns) {
        expect(c.restoreAbleType, isNotNull);
      }
    });
    test('should decode correctly', () {
      final r = getRecord();
      for (final c in NativeColumn.allColumns) {
        final txt = c.encode(r);
        final decoded = c.decode(txt);
        expect(decoded, isNotNull);
        switch (decoded!.$1) {
          case RowDataFieldType.timestamp:
            expect(decoded.$2, isA<DateTime>().having(
                    (p0) => p0.millisecondsSinceEpoch, 'milliseconds', r.creationTime.millisecondsSinceEpoch));
            break;
          case RowDataFieldType.sys:
            expect(decoded.$2, isA<int>().having(
                    (p0) => p0, 'systolic', r.systolic));
            break;
          case RowDataFieldType.dia:
            expect(decoded.$2, isA<int>().having(
                    (p0) => p0, 'diastolic', r.diastolic));
            break;
          case RowDataFieldType.pul:
            expect(decoded.$2, isA<int>().having(
                    (p0) => p0, 'pulse', r.pulse));
            break;
          case RowDataFieldType.notes:
            expect(decoded.$2, isA<String>().having(
                    (p0) => p0, 'pulse', r.notes));
            break;
          case RowDataFieldType.color:
            expect(decoded.$2, isA<Color>().having(
                    (p0) => p0, 'color', r.needlePin?.color));
            break;
          case RowDataFieldType.needlePin:
            expect(decoded.$2, isA<MeasurementNeedlePin>().having(
                    (p0) => p0.toJson(), 'pin', r.needlePin?.toJson()));
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
      ]));
    });
    test('should have internalIdentifier prefixed with "buildin."', () {
      for (final c in BuildInColumn.allColumns) {
        expect(c.internalIdentifier, startsWith("buildin."));
      }
    });
    test('should encode without problems', () {
      for (final c in BuildInColumn.allColumns) {
        expect(c.encode(getRecord()), isNotNull);
      }
    });
    test('should decode correctly', () {
      final r = getRecord();
      for (final c in BuildInColumn.allColumns) {
        final txt = c.encode(r);
        final decoded = c.decode(txt);
        switch (decoded?.$1) {
          case RowDataFieldType.timestamp:
            expect(decoded?.$2, isA<DateTime>().having(
                    (p0) => p0.millisecondsSinceEpoch, 'milliseconds', r.creationTime.millisecondsSinceEpoch));
            break;
          case RowDataFieldType.sys:
            expect(decoded?.$2, isA<int>().having(
                    (p0) => p0, 'systolic', r.systolic));
            break;
          case RowDataFieldType.dia:
            expect(decoded?.$2, isA<int>().having(
                    (p0) => p0, 'diastolic', r.diastolic));
            break;
          case RowDataFieldType.pul:
            expect(decoded?.$2, isA<int>().having(
                    (p0) => p0, 'pulse', r.pulse));
            break;
          case RowDataFieldType.notes:
            expect(decoded?.$2, isA<String>().having(
                    (p0) => p0, 'pulse', r.notes));
            break;
          case RowDataFieldType.color:
            expect(decoded?.$2, isA<Color>().having(
                    (p0) => p0, 'color', r.needlePin?.color));
            break;
          case RowDataFieldType.needlePin:
            expect(decoded?.$2, isA<MeasurementNeedlePin>().having(
                    (p0) => p0.toJson(), 'pin', r.needlePin?.toJson()));
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
      final r = getRecord();
      expect(UserColumn('','', 'TEST').encode(r), ScriptedFormatter('TEST').encode(r));
      expect(UserColumn('','', r'$SYS').encode(r), ScriptedFormatter(r'$SYS').encode(r));
      expect(UserColumn('','', r'$SYS-$DIA').encode(r), ScriptedFormatter(r'$SYS-$DIA').encode(r));
      expect(UserColumn('','', r'$TIMESTAMP').encode(r), ScriptedFormatter(r'$TIMESTAMP').encode(r));
      expect(UserColumn('','', '').encode(r), ScriptedFormatter('').encode(r));
    });
    test('should decode like ScriptedFormatter', () {
      final r = getRecord();
      final testPatterns = ['TEST', r'$SYS', r'{{$SYS-$DIA}}', r'$TIMESTAMP', ''];

      for (final pattern in testPatterns) {
        final column = UserColumn('','', pattern);
        final formatter = ScriptedFormatter(pattern);
        expect(column.decode(column.encode(r)), formatter.decode(formatter.encode(r)))
      }
    });
  });

  // TODO: TimeColumn
}

BloodPressureRecord getRecord() => BloodPressureRecord(DateTime.now(), 123, 456, 678, 'notes', needlePin: const MeasurementNeedlePin(Colors.pink));