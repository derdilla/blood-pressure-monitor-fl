import 'dart:convert';

import 'package:blood_pressure_app/model/export_import/export_configuration.dart';
import 'package:blood_pressure_app/model/storage/common_settings_interfaces.dart';
import 'package:blood_pressure_app/model/storage/convert_util.dart';
import 'package:flutter/material.dart';

/// Settings that are only important for exporting entries to csv files.
class CsvExportSettings extends ChangeNotifier implements CustomFieldsSettings {
  CsvExportSettings({
    String? fieldDelimiter,
    String? textDelimiter,
    bool? exportHeadline,
    ActiveExportColumnConfiguration? exportFieldsConfiguration,
  }) {
    if (fieldDelimiter != null) _fieldDelimiter = fieldDelimiter;
    if (textDelimiter != null) _textDelimiter = textDelimiter;
    if (exportHeadline != null) _exportHeadline = exportHeadline;
    if (exportFieldsConfiguration != null) _exportFieldsConfiguration = exportFieldsConfiguration;

    _exportFieldsConfiguration.addListener(notifyListeners);
  }

  factory CsvExportSettings.fromMap(Map<String, dynamic> map) {
    if (map.containsKey('exportFieldsConfiguration')) {
      return CsvExportSettings(
        fieldDelimiter: ConvertUtil.parseString(map['fieldDelimiter']),
        textDelimiter: ConvertUtil.parseString(map['textDelimiter']),
        exportHeadline: ConvertUtil.parseBool(map['exportHeadline']),
        exportFieldsConfiguration: ActiveExportColumnConfiguration.fromJson(map['exportFieldsConfiguration']),
      );
    } else {
      return CsvExportSettings(
        fieldDelimiter: ConvertUtil.parseString(map['fieldDelimiter']),
        textDelimiter: ConvertUtil.parseString(map['textDelimiter']),
        exportHeadline: ConvertUtil.parseBool(map['exportHeadline']),
        exportFieldsConfiguration: ActiveExportColumnConfiguration(
          activePreset: ConvertUtil.parseBool(map['exportCustomFields']) ?? false ? ExportImportPreset.none : ExportImportPreset.bloodPressureApp,
          // Can't migrate user columns ('customFields') as no prefix available
        ),
      );
    }
  }

  factory CsvExportSettings.fromJson(String json) {
    try {
      return CsvExportSettings.fromMap(jsonDecode(json));
    } catch (e) {
      assert(e is FormatException || e is TypeError);
      return CsvExportSettings();
    }
  }

  Map<String, dynamic> toMap() => <String, dynamic>{
    'fieldDelimiter': fieldDelimiter,
    'textDelimiter': textDelimiter,
    'exportHeadline': exportHeadline,
    'exportFieldsConfiguration': exportFieldsConfiguration.toJson(),
  };

  /// Serializes the object to json string.
  String toJson() => jsonEncode(toMap());

  /// Copy all values from another instance.
  void copyFrom(CsvExportSettings other) {
    _fieldDelimiter = other._fieldDelimiter;
    _textDelimiter = other._textDelimiter;
    _exportHeadline = other._exportHeadline;
    _exportFieldsConfiguration = other._exportFieldsConfiguration;
    notifyListeners();
  }

  /// Reset all fields to their default values.
  void reset() => copyFrom(CsvExportSettings());

  String _fieldDelimiter = ',';
  String get fieldDelimiter => _fieldDelimiter;
  set fieldDelimiter(String value) {
    _fieldDelimiter = value;
    notifyListeners();
  }

  String _textDelimiter = '"';
  String get textDelimiter => _textDelimiter;
  set textDelimiter(String value) {
    _textDelimiter = value;
    notifyListeners();
  }

  bool _exportHeadline = true;
  bool get exportHeadline => _exportHeadline;
  set exportHeadline(bool value) {
    _exportHeadline = value;
    notifyListeners();
  }

  ActiveExportColumnConfiguration _exportFieldsConfiguration = ActiveExportColumnConfiguration();
  @override
  ActiveExportColumnConfiguration get exportFieldsConfiguration => _exportFieldsConfiguration;

  // Procedure for adding more entries described in the settings_store.dart doc comment
}
