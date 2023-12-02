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
    required ExportImportPreset activePreset,
    List<ExportColumn>? userSelectedColumns
  }) : _activePreset = activePreset, _userSelectedColumns = userSelectedColumns ?? [];

  factory ActiveExportColumnConfiguration.fromJson(String jsonString, ExportColumnsManager availableColumns) {
    final json = jsonDecode(jsonString);
    final columns = (){
      final columns = json['columns'];
      if (columns is! List<String>) return <ExportColumn>[];
      return [
        for (final c in columns)
          availableColumns.getColumn(c),
      ].whereNotNull().toList();
    }();
    return ActiveExportColumnConfiguration(
      activePreset: ExportImportPreset.decode(json['preset']) ?? ExportImportPreset.bloodPressureApp,
      userSelectedColumns: columns
    );
  }

  String toJson() => jsonEncode({
    'columns': _userSelectedColumns.map((e) => e.internalIdentifier),
    'preset': _activePreset.encode()
  });

  /// The last selected columns, different from [getActiveColumns].
  final List<ExportColumn> _userSelectedColumns;

  ExportImportPreset _activePreset;
  ExportImportPreset get activePreset => _activePreset;
  set activePreset(ExportImportPreset value) {
    _activePreset = value;
    notifyListeners();
  }
  // TODO: put in CsvExportSettings, PdfExportSettings

  /// Columns to respect for export.
  UnmodifiableListView<ExportColumn> getActiveColumns() => UnmodifiableListView( 
    switch (_activePreset) {
      ExportImportPreset.none => _userSelectedColumns,
      ExportImportPreset.bloodPressureApp => [
        NativeColumn.timestamp,
        NativeColumn.systolic,
        NativeColumn.diastolic,
        NativeColumn.pulse,
        NativeColumn.notes,
        NativeColumn.color,
      ],
      // TODO: Handle this case. once myheart options are reimplemented.
      ExportImportPreset.myHeart => [],
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