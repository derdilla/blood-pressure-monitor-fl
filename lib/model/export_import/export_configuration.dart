import 'dart:convert';

import 'package:blood_pressure_app/model/export_import/column.dart';
import 'package:blood_pressure_app/model/storage/export_columns_store.dart';
import 'package:collection/collection.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// Class for managing columns currently used for ex- and import.
class ActiveExportColumnConfiguration extends ChangeNotifier {
  /// Create a manager of the currently relevant [ExportColumn]s.
  ActiveExportColumnConfiguration({
    ExportImportPreset? activePreset,
    List<String>? userSelectedColumnIds
  }) :
      _activePreset = activePreset ?? ExportImportPreset.bloodPressureApp,
      _userSelectedColumns = userSelectedColumnIds ?? [];

  factory ActiveExportColumnConfiguration.fromJson(String jsonString) {
    final json = jsonDecode(jsonString);
    final columns = (){
      final columns = json['columns'];
      if (columns is! List<String>) return <String>[];
      return columns;
    }();
    return ActiveExportColumnConfiguration(
      activePreset: ExportImportPreset.decode(json['preset']) ?? ExportImportPreset.bloodPressureApp,
      userSelectedColumnIds: columns
    );
  }

  String toJson() => jsonEncode({
    'columns': _userSelectedColumns,
    'preset': _activePreset.encode()
  });

  /// The last selected columns, different from [getActiveColumns].
  final List<String> _userSelectedColumns;

  ExportImportPreset _activePreset;
  ExportImportPreset get activePreset => _activePreset;
  set activePreset(ExportImportPreset value) {
    _activePreset = value;
    notifyListeners();
  }

  /// Columns to respect for export.
  UnmodifiableListView<ExportColumn> getActiveColumns(ExportColumnsManager availableColumns) => UnmodifiableListView(
    switch (_activePreset) {
      ExportImportPreset.none => _userSelectedColumns.map((e) => availableColumns.getColumn(e)).whereNotNull(),
      ExportImportPreset.bloodPressureApp => [
        NativeColumn.timestamp,
        NativeColumn.systolic,
        NativeColumn.diastolic,
        NativeColumn.pulse,
        NativeColumn.notes,
        NativeColumn.color,
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
    });
}


/// Common export configurations that have specific associated columns.
enum ExportImportPreset {
  /// Custom export configuration.
  none,

  /// Default preset, that ensures working exports and restoration.
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
        assert(false);
        return null;
      }(),
    };
  }
}