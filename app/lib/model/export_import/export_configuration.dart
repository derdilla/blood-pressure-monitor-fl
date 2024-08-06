import 'dart:convert';

import 'package:blood_pressure_app/model/export_import/column.dart';
import 'package:blood_pressure_app/model/storage/convert_util.dart';
import 'package:blood_pressure_app/model/storage/export_columns_store.dart';
import 'package:collection/collection.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// Class for managing columns currently used for ex- and import.
class ActiveExportColumnConfiguration extends ChangeNotifier {
  /// Create a manager of the currently relevant [ExportColumn]s.
  ///
  /// The default configuration is guaranteed to be restoreable.
  ActiveExportColumnConfiguration({
    ExportImportPreset? activePreset,
    List<String>? userSelectedColumnIds,
  }) :
      _activePreset = activePreset ?? ExportImportPreset.bloodPressureApp,
      _userSelectedColumns = userSelectedColumnIds ?? [];

  /// Create a instance from a [String] created by [toJson].
  factory ActiveExportColumnConfiguration.fromJson(String jsonString) {
    try {
      final json = jsonDecode(jsonString);
      return ActiveExportColumnConfiguration(
          activePreset: ExportImportPreset.decode(json['preset']) ?? ExportImportPreset.bloodPressureApp,
          userSelectedColumnIds: ConvertUtil.parseList<String>(json['columns']),
      );
    } on FormatException {
      return ActiveExportColumnConfiguration();
    }

  }

  /// Serialize the object to a restoreable string.
  String toJson() => jsonEncode({
    'columns': _userSelectedColumns,
    'preset': _activePreset.encode(),
  });

  /// The [UserColumn.internalIdentifier] of columns currently selected by user.
  ///
  /// Note that this is persistent different from [getActiveColumns].
  final List<String> _userSelectedColumns;

  ExportImportPreset _activePreset;

  /// The current selection on what set of values will be exported.
  ExportImportPreset get activePreset => _activePreset;

  set activePreset(ExportImportPreset value) {
    _activePreset = value;
    notifyListeners();
  }

  /// Put the user column at [oldIndex] to [newIndex].
  void reorderUserColumns(int oldIndex, int newIndex) {
    assert(_activePreset == ExportImportPreset.none, 'user columns are not modifiable while another configuration is active');
    assert(oldIndex >= 0 && oldIndex < _userSelectedColumns.length);
    assert(newIndex >= 0 && newIndex < _userSelectedColumns.length);
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final item = _userSelectedColumns.removeAt(oldIndex);
    _userSelectedColumns.insert(newIndex, item);
    notifyListeners();
  }

  /// Add a export column to the end of user columns.
  void addUserColumn(ExportColumn column) {
    assert(_activePreset == ExportImportPreset.none, 'user columns are not modifiable while another configuration is active');
    _userSelectedColumns.add(column.internalIdentifier);
    notifyListeners();
  }

  /// Removes the first export column from user columns where
  /// [ExportColumn.internalIdentifier] matches [identifier].
  void removeUserColumn(String identifier) {
    assert(_activePreset == ExportImportPreset.none, 'user columns are not modifiable while another configuration is active');
    _userSelectedColumns.removeWhere((c) => c == identifier);
    notifyListeners();
  }

  /// Columns to respect for export.
  UnmodifiableListView<ExportColumn> getActiveColumns(ExportColumnsManager availableColumns) => UnmodifiableListView(
    switch (_activePreset) {
      ExportImportPreset.none => _userSelectedColumns.map((e) => availableColumns.getColumn(e)).whereNotNull(),
      ExportImportPreset.bloodPressureApp => [
        NativeColumn.timestampUnixMs,
        NativeColumn.systolic,
        NativeColumn.diastolic,
        NativeColumn.pulse,
        NativeColumn.notes,
        NativeColumn.color,
        NativeColumn.intakes,
      ],
      ExportImportPreset.myHeart => [
        BuildInColumn.mhDate,
        BuildInColumn.mhSys,
        BuildInColumn.mhDia,
        BuildInColumn.mhPul,
        BuildInColumn.mhDesc,
        BuildInColumn.mhTags,
        BuildInColumn.mhWeight,
        BuildInColumn.mhOxygen,
      ],
      ExportImportPreset.bloodPressureAppPdf => [
        BuildInColumn.formattedTime,
        NativeColumn.systolic,
        NativeColumn.diastolic,
        NativeColumn.pulse,
      ]
    },);
}


/// Common export configurations that have specific associated columns.
enum ExportImportPreset {
  /// Custom export configuration.
  none,

  /// Default preset, that ensures working exports and restoration.
  ///
  /// All [NativeColumn]s.
  bloodPressureApp,

  /// Default preset for pdf exports.
  ///
  /// Includes formatted time, sys, dia and pulse.
  bloodPressureAppPdf,

  /// Preset for exporting data to the myHeart app.
  myHeart;

  /// Selection of a displayable string from [localizations].
  String localize(AppLocalizations localizations) => switch (this) {
    ExportImportPreset.none => localizations.custom,
    ExportImportPreset.bloodPressureApp => localizations.default_,
    ExportImportPreset.bloodPressureAppPdf => localizations.pdf,
    ExportImportPreset.myHeart => '"My Heart" export'
  };

  /// Turn the value into a [decode]able integer for serialization purposes.
  int encode() => switch (this) {
    ExportImportPreset.none => 0,
    ExportImportPreset.bloodPressureApp => 1,
    ExportImportPreset.myHeart => 2,
    ExportImportPreset.bloodPressureAppPdf => 3,
  };

  /// Create a enum value form a number returned by [encode].
  static ExportImportPreset? decode(Object? e) => switch(e) {
      0 => ExportImportPreset.none,
      1 => ExportImportPreset.bloodPressureApp,
      2 => ExportImportPreset.myHeart,
      3 => ExportImportPreset.bloodPressureAppPdf,
      _ => (){
        assert(e is! int, 'non ints can happen through bad user values, other ints can happen as well, but should developers should be notified.');
        return null;
      }(),
    };
}
