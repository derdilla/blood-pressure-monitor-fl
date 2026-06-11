import 'dart:convert';

import 'package:blood_pressure_app/features/export_import/model/column.dart';
import 'package:blood_pressure_app/l10n/app_localizations.dart';
import 'package:blood_pressure_app/model/storage/convert_util.dart';
import 'package:blood_pressure_app/model/storage/export_columns_store.dart';
import 'package:collection/collection.dart';
import 'package:flutter/widgets.dart';

/// Class for managing columns currently used for export.
class ActiveExportColumnConfiguration extends ChangeNotifier {
  /// Create a manager of the currently relevant [ExportColumn]s.
  ///
  /// The default configuration is guaranteed to be restoreable.
  ActiveExportColumnConfiguration({
    ExportImportPreset? activePreset,
    List<String>? userSelectedColumnIds,
  }) :
      _peset = activePreset ?? ExportImportPreset.bloodPressureApp,
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
    'preset': _peset.encode(),
  });

  /// The [UserColumn.internalIdentifier] of columns currently selected by user.
  ///
  /// Note that this is persistent different from [getActiveColumns].
  final List<String> _userSelectedColumns;

  ExportPreset _peset;

  /// The current selection on what set of values will be exported.
  ExportImportPreset get activePreset => _peset;

  set activePreset(ExportImportPreset value) {
    _currentPresetLabel = null;
    _peset = value;
    notifyListeners();
  }



  /// Columns to respect for export.
  UnmodifiableListView<ExportColumn> getActiveColumns(ExportColumnsManager availableColumns) => UnmodifiableListView(
      _userSelectedColumns.map((e) => availableColumns.getColumn(e)).nonNulls);

  void loadCustomPreset(ExportPreset preset) {
    notifyListeners();
  }

}

