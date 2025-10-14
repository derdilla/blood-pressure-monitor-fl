import 'dart:convert';

import 'package:blood_pressure_app/model/export_import/export_configuration.dart';
import 'package:blood_pressure_app/model/storage/common_settings_interfaces.dart';
import 'package:flutter/material.dart';

/// Settings that are only important for exporting entries to csv files.
class ExcelExportSettings extends ChangeNotifier implements CustomFieldsSettings {
  ExcelExportSettings({
    ActiveExportColumnConfiguration? exportFieldsConfiguration,
  }) {
    if (exportFieldsConfiguration != null) _exportFieldsConfiguration = exportFieldsConfiguration;

    _exportFieldsConfiguration.addListener(notifyListeners);
  }

  /// Create a instance from a map created by [toMap].
  factory ExcelExportSettings.fromMap(Map<String, dynamic> map) => ExcelExportSettings(
    exportFieldsConfiguration: ActiveExportColumnConfiguration.fromJson(map['exportFieldsConfiguration']),
  );

  /// Create a instance from a map created by [toJson].
  factory ExcelExportSettings.fromJson(String json) {
    try {
      return ExcelExportSettings.fromMap(jsonDecode(json));
    } catch (e) {
      assert(e is FormatException || e is TypeError);
      return ExcelExportSettings();
    }
  }

  /// Serialize the object to a restoreable map.
  Map<String, dynamic> toMap() => <String, dynamic>{
    'exportFieldsConfiguration': exportFieldsConfiguration.toJson(),
  };

  /// Serializes the object to json string.
  String toJson() => jsonEncode(toMap());

  /// Copy all values from another instance.
  void copyFrom(ExcelExportSettings other) {
    _exportFieldsConfiguration = other._exportFieldsConfiguration;
    notifyListeners();
  }

  /// Reset all fields to their default values.
  void reset() => copyFrom(ExcelExportSettings());

  ActiveExportColumnConfiguration _exportFieldsConfiguration = ActiveExportColumnConfiguration();
  @override
  ActiveExportColumnConfiguration get exportFieldsConfiguration => _exportFieldsConfiguration;

  // Procedure for adding more entries described in the settings_store.dart doc comment
}
