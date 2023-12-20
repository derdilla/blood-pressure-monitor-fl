import 'package:blood_pressure_app/model/blood_pressure.dart';
import 'package:blood_pressure_app/model/export_import/column.dart';
import 'package:blood_pressure_app/model/export_import/import_field_type.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NativeColumn', () {
    test('allColumns should contain fields', () {
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
    test('columns should have internalIdentifier prefixed with "native."', () {
      for (final c in NativeColumn.allColumns) {
        expect(c.internalIdentifier, startsWith("native."));
      }
    });
    test('columns should encode into non-empty string', () {
      // Use BuildInColumn for utility columns
      for (final c in NativeColumn.allColumns) {
        expect(c.encode(getRecord()), isNotEmpty);
      }
    });
    test('columns should only contain restoreable types', () {
      // Use BuildInColumn for utility columns
      for (final c in NativeColumn.allColumns) {
        expect(c.restoreAbleType, isNotNull);
      }
    });
    test('columns should decode correctly', () {
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
    test('allColumns should contain fields', () {
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
    test('columns should have internalIdentifier prefixed with "buildin."', () {
      for (final c in BuildInColumn.allColumns) {
        expect(c.internalIdentifier, startsWith("buildin."));
      }
    });
    test('columns should decode correctly', () {
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

  // TODO: UserColumn, TimeColumn
}

BloodPressureRecord getRecord() => BloodPressureRecord(DateTime.now(), 123, 456, 678, 'notes', needlePin: const MeasurementNeedlePin(Colors.pink));