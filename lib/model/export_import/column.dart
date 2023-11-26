import 'dart:convert';

import 'package:blood_pressure_app/model/blood_pressure.dart';
import 'package:blood_pressure_app/model/export_import/legacy_column.dart';
import 'package:blood_pressure_app/model/export_import/reocord_formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// Converters for [BloodPressureRecord] attributes.
class NativeColumn extends ExportColumn {
  NativeColumn._create(this._csvTitle, this._restoreableType, this._encode, this._decode);
  
  final String _csvTitle;
  final RowDataFieldType _restoreableType;
  final String Function(BloodPressureRecord record) _encode;
  final Object? Function(String pattern) _decode;
  
  static final NativeColumn timestamp = NativeColumn._create(
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
  String get internalIdentifier => 'buildin.$csvTitle';

  @override
  RowDataFieldType? get restoreAbleType => _restoreableType;

  @override
  String userTitle(AppLocalizations localizations) => _restoreableType.localize(localizations);


}

// TODO: add class for formattedTimestamp
// TODO: keep pulsePressure option


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


/// Class for storing export behavior of columns.
///
/// In most cases using the sealed
class UserColumn extends ExportColumn {
  /// Create a object that handles export behavior for data in a column.
  ///
  /// [formatter] will be created according to [formatString].
  UserColumn(this.internalIdentifier, this.csvTitle, String formatString) {
    formatter = ScriptedFormatter(formatString);
  }

  @override
  final String internalIdentifier;

  @override
  final String csvTitle;

  @override
  String userTitle(AppLocalizations localizations) => csvTitle;

  /// Converter associated with this column.
  late final Formatter formatter;

  @override
  (RowDataFieldType, dynamic)? decode(String pattern) => formatter.decode(pattern);

  @override
  String encode(BloodPressureRecord record) => formatter.encode(record);

  @override
  String? get formatPattern => formatter.formatPattern;

  @override
  RowDataFieldType? get restoreAbleType => formatter.restoreAbleType;
}
