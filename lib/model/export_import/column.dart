import 'dart:convert';

import 'package:blood_pressure_app/model/blood_pressure/needle_pin.dart';
import 'package:blood_pressure_app/model/blood_pressure/record.dart';
import 'package:blood_pressure_app/model/export_import/import_field_type.dart';
import 'package:blood_pressure_app/model/export_import/record_formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// Converters for [BloodPressureRecord] attributes.
class NativeColumn extends ExportColumn {
  NativeColumn._create(this._csvTitle, this._restoreableType, this._encode, this._decode);

  /// All native columns that exist.
  ///
  /// They are all part of [ExportImportPreset.bloodPressureApp].
  static final List<NativeColumn> allColumns = [
    timestampUnixMs,
    systolic,
    diastolic,
    pulse,
    notes,
    color,
    needlePin,
  ];
  static final NativeColumn timestampUnixMs = NativeColumn._create(
      'timestampUnixMs',
      RowDataFieldType.timestamp,
          (record) => record.creationTime.millisecondsSinceEpoch.toString(),
          (pattern) {
        final value = int.tryParse(pattern);
        return (value == null) ? null : DateTime.fromMillisecondsSinceEpoch(value);
      }
    );
    static final NativeColumn systolic = NativeColumn._create(
      'systolic',
      RowDataFieldType.sys,
      (record) => record.systolic.toString(),
      (pattern) => int.tryParse(pattern)
    );
    static final NativeColumn diastolic = NativeColumn._create(
      'diastolic',
      RowDataFieldType.dia,
      (record) => record.diastolic.toString(),
      (pattern) => int.tryParse(pattern)
    );
    static final NativeColumn pulse = NativeColumn._create(
      'pulse',
      RowDataFieldType.pul,
      (record) => record.pulse.toString(),
      (pattern) => int.tryParse(pattern)
    );
    static final NativeColumn notes = NativeColumn._create(
      'notes',
      RowDataFieldType.notes,
      (record) => record.notes,
      (pattern) => pattern
    );
    static final NativeColumn color = NativeColumn._create(
      'color',
      RowDataFieldType.needlePin,
      (record) => record.needlePin?.color.value.toString() ?? '',
      (pattern) {
        final value = int.tryParse(pattern);
        if (value == null) return null;
        return MeasurementNeedlePin(Color(value));
      }
    );
    static final NativeColumn needlePin = NativeColumn._create(
      'needlePin',
      RowDataFieldType.needlePin,
      (record) => jsonEncode(record.needlePin?.toJson()),
      (pattern) {
        final json = jsonDecode(pattern);
        if (json is! Map<String, dynamic>) return null;
        try {
          return MeasurementNeedlePin.fromJson(json);
        } on FormatException {
          return null;
        }
      }
    );

  
  final String _csvTitle;
  final RowDataFieldType _restoreableType;
  final String Function(BloodPressureRecord record) _encode;
  final Object? Function(String pattern) _decode;

  @override
  String get csvTitle => _csvTitle;

  @override
  (RowDataFieldType, Object)? decode(String pattern) {
    final value = _decode(pattern);
    if (value == null) return null;
    return (_restoreableType, value);
  }

  @override
  String encode(BloodPressureRecord record) => _encode(record);

  @override
  String? get formatPattern => null;

  @override
  String get internalIdentifier => 'native.$csvTitle';

  @override
  RowDataFieldType? get restoreAbleType => _restoreableType;

  @override
  String userTitle(AppLocalizations localizations) => _restoreableType.localize(localizations);


}

/// Useful columns that are present by default and recreatable through a formatPattern.
class BuildInColumn extends ExportColumn {
  /// Creates a build in column and adds it to allColumns.
  BuildInColumn._create(this.internalIdentifier, this.csvTitle, String formatString, this._userTitle)
      : _formatter = ScriptedFormatter(formatString);
  
  static final List<BuildInColumn> allColumns = [
    pulsePressure,
    mhDate,
    mhSys,
    mhDia,
    mhPul,
    mhDesc,
    mhTags,
    mhWeight,
    mhOxygen,
  ];
  
  static final pulsePressure = BuildInColumn._create(
      'buildin.pulsePressure',
      'pulsePressure',
      r'{{$SYS-$DIA}}', 
      (localizations) => localizations.pulsePressure
  );

  // my heart columns
  static final mhDate = BuildInColumn._create(
      'buildin.mhDate',
      'DATUM',
      r'$FORMAT{$TIMESTAMP,yyyy-MM-dd HH:mm:ss}',
      (_) => '"My Heart" export time'
  );
  static final mhSys = BuildInColumn._create(
      'buildin.mhSys',
      'SYSTOLE',
      r'$SYS',
      (_) => '"My Heart" export sys'
  );
  static final mhDia = BuildInColumn._create(
      'buildin.mhDia',
      'DIASTOLE',
      r'$DIA',
      (_) => '"My Heart" export dia'
  );
  static final mhPul = BuildInColumn._create(
      'buildin.mhPul',
      'PULSE',
      r'$PUL',
      (_) => '"My Heart" export pul'
  );
  static final mhDesc = BuildInColumn._create(
      'buildin.mhDesc',
      'Beschreibung',
      r'null',
      (_) => '"My Heart" export description'
  );
  static final mhTags = BuildInColumn._create(
      'buildin.mhTags',
      'Tags',
      r'',
      (_) => '"My Heart" export tags'
  );
  static final mhWeight = BuildInColumn._create(
      'buildin.mhWeight',
      'Gewicht',
      r'0.0',
      (_) => '"My Heart" export weight'
  );
  static final mhOxygen = BuildInColumn._create(
      'buildin.mhOxygen',
      'Sauerstoffsättigung',
      r'0',
      (_) => '"My Heart" export oxygen'
  );

  @override
  final String internalIdentifier;

  @override
  final String csvTitle;

  final String Function(AppLocalizations localizations) _userTitle;

  @override
  String userTitle(AppLocalizations localizations) => _userTitle(localizations);

  final Formatter _formatter;

  @override
  (RowDataFieldType, dynamic)? decode(String pattern) => _formatter.decode(pattern);

  @override
  String encode(BloodPressureRecord record) => _formatter.encode(record);

  @override
  String? get formatPattern => _formatter.formatPattern;

  @override
  RowDataFieldType? get restoreAbleType => _formatter.restoreAbleType;
}

/// Class for storing data of user added columns.
class UserColumn extends ExportColumn {
  /// Create a object that handles export behavior for data in a column.
  ///
  /// [formatter] will be created according to [formatPattern].
  ///
  /// [internalIdentifier] is automatically prefixed with 'userColumn.' during object creation.
  UserColumn(String internalIdentifier, this.csvTitle, String formatPattern):
        formatter = ScriptedFormatter(formatPattern),
        internalIdentifier = 'userColumn.$internalIdentifier';

  /// UserColumn constructor that keeps the internalIdentifier.
  UserColumn.explicit(this.internalIdentifier, this.csvTitle, String formatPattern):
        formatter = ScriptedFormatter(formatPattern);

  /// Unique identifier of userColumn.
  ///
  /// Is automatically prefixed with `userColumn.` to avoid name collisions with build-ins.
  @override
  final String internalIdentifier;

  @override
  final String csvTitle;

  @override
  String userTitle(AppLocalizations localizations) => csvTitle;

  /// Converter associated with this column.
  final Formatter formatter;

  @override
  (RowDataFieldType, dynamic)? decode(String pattern) => formatter.decode(pattern);

  @override
  String encode(BloodPressureRecord record) => formatter.encode(record);

  @override
  String? get formatPattern => formatter.formatPattern;

  @override
  RowDataFieldType? get restoreAbleType => formatter.restoreAbleType;
}

class TimeColumn extends ExportColumn {
  /// Create a formatter that converts between [String]s and [DateTime]s through a format pattern
  ///
  /// [internalIdentifier] is automatically prefixed with 'userColumn.' during object creation.
  TimeColumn(this.csvTitle, this.formatPattern):
        internalIdentifier = 'timeFormatter.$csvTitle';

  /// UserColumn constructor that does not change the [internalIdentifier].
  TimeColumn.explicit(this.internalIdentifier, this.csvTitle, this.formatPattern);

  ScriptedTimeFormatter? _formatter;

  @override
  final String csvTitle;

  @override
  (RowDataFieldType, dynamic)? decode(String pattern) {
    _formatter ??= ScriptedTimeFormatter(formatPattern);
    return _formatter!.decode(pattern);
  }

  @override
  String encode(BloodPressureRecord record) {
    _formatter ??= ScriptedTimeFormatter(formatPattern);
    return _formatter!.encode(record);
  }

  @override
  final String formatPattern;

  /// Unique identifier of userColumn.
  ///
  /// Is automatically prefixed with `timeFormatter.` to avoid name collisions with build-ins.
  @override
  final String internalIdentifier;

  @override
  RowDataFieldType? get restoreAbleType => RowDataFieldType.timestamp;

  @override
  String userTitle(AppLocalizations localizations) => csvTitle;

}

/// Interface for converters that allow formatting and provide metadata.
sealed class ExportColumn implements Formatter {
  /// Unique internal identifier that is used to identify a column in the app.
  ///
  /// A identifier can be any string, but is usually structured with a prefix and
  /// a name. For example `buildin.sys`, `user.fancyvalue` or `convert.myheartsys`.
  /// These examples are not guaranteed to be the prefixes used in the rest of the
  /// app.
  ///
  /// It should not be used instead of [csvTitle].
  String get internalIdentifier;

  /// Column title in a csv file.
  ///
  /// May not contain characters intended for CSV column separation (e.g. `,`).
  String get csvTitle;

  /// Column title in user facing places that don't require strict rules.
  ///
  /// It will be displayed on the exported PDF file or in the column selection.
  String userTitle(AppLocalizations localizations);
}
