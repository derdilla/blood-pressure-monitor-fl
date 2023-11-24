import 'dart:convert';

import 'package:blood_pressure_app/model/blood_pressure.dart';
import 'package:blood_pressure_app/model/export_import/legacy_column.dart';
import 'package:blood_pressure_app/model/export_import/reocord_formatter.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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

  static String serialize(ExportColumn column) {
    int type = switch (column) {
      UserColumn() => 1,
    };
    return jsonEncode({
      't': type,
      'id': column.internalIdentifier,
      'csvTitle': column.csvTitle,
      // TODO: class specific json data?
    });
  }
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