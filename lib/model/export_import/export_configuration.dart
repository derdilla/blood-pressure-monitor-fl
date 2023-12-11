import 'dart:convert';

import 'package:blood_pressure_app/model/export_import/column.dart';
import 'package:blood_pressure_app/model/storage/convert_util.dart';
import 'package:blood_pressure_app/model/storage/export_columns_store.dart';
import 'package:collection/collection.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// Class for managing columns currently used for ex- and import.
///
/// TODO: implement methods for modifying columns once UI code requires it
class ActiveExportColumnConfiguration extends ChangeNotifier {
  /// Create a manager of the currently relevant [ExportColumn]s.
  ActiveExportColumnConfiguration({
    ExportImportPreset? activePreset,
    List<String>? userSelectedColumnIds
  }) :
      _activePreset = activePreset ?? ExportImportPreset.bloodPressureApp,
      _userSelectedColumns = userSelectedColumnIds ?? [];

  factory ActiveExportColumnConfiguration.fromJson(String jsonString) {
    try {
      final json = jsonDecode(jsonString);
      return ActiveExportColumnConfiguration(
          activePreset: ExportImportPreset.decode(json['preset']) ?? ExportImportPreset.bloodPressureApp,
          userSelectedColumnIds: ConvertUtil.parseList<String>(json['columns'])
      );
    } on FormatException {
      return ActiveExportColumnConfiguration();
    }

  }

  String toJson() => jsonEncode({
    'columns': _userSelectedColumns,
    'preset': _activePreset.encode()
  });

  /// The [UserColumn.internalIdentifier] of columns currently selected by user.
  ///
  /// Note that this is persistent different from [getActiveColumns].
  final List<String> _userSelectedColumns;

  ExportImportPreset _activePreset;
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

  /// Columns to respect for export.
  UnmodifiableListView<ExportColumn> getActiveColumns(ExportColumnsManager availableColumns) => UnmodifiableListView(
    switch (_activePreset) {
      ExportImportPreset.none => _userSelectedColumns.map((e) => availableColumns.getColumn(e)).whereNotNull(),
      ExportImportPreset.bloodPressureApp => NativeColumn.allColumns, // FIXME: not color AND needlePin
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
    });
}


/// Common export configurations that have specific associated columns.
enum ExportImportPreset {
  /// Custom export configuration.
  none,

  /// Default preset, that ensures working exports and restoration.
  ///
  /// All [NativeColumn]s.
  bloodPressureApp,
  myHeart;

  String localize(AppLocalizations localizations) => switch (this) {
    ExportImportPreset.none => localizations.custom,
    ExportImportPreset.bloodPressureApp => localizations.default_,
    ExportImportPreset.myHeart => '"My Heart" export'
  };

  int encode() => switch (this) {
    ExportImportPreset.none => 0,
    ExportImportPreset.bloodPressureApp => 1,
    ExportImportPreset.myHeart => 2
  };

  static ExportImportPreset? decode(dynamic e) {
    return switch(e) {
      0 => ExportImportPreset.none,
      1 => ExportImportPreset.bloodPressureApp,
      2 => ExportImportPreset.myHeart,
      _ => (){
        assert(e is! int, 'non ints can happen through bad user values, other ints can happen as well, but should developers should be notified.');
        return null;
      }(),
    };
  }
}