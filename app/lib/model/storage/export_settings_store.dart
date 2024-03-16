import 'dart:convert';

import 'package:blood_pressure_app/model/storage/convert_util.dart';
import 'package:flutter/material.dart';

/// General settings for exporting measurements that are applicable to all export formats.
class ExportSettings extends ChangeNotifier {
  ExportSettings({
    ExportFormat? exportFormat,
    String? defaultExportDir,
    bool? exportAfterEveryEntry,
  }) {
    if (exportFormat != null) _exportFormat = exportFormat;
    if (defaultExportDir != null) _defaultExportDir = defaultExportDir;
    if (exportAfterEveryEntry != null) _exportAfterEveryEntry = exportAfterEveryEntry;
  }

  factory ExportSettings.fromMap(Map<String, dynamic> map) => ExportSettings(
    exportFormat: ExportFormat.deserialize(map['exportFormat']),
    defaultExportDir: ConvertUtil.parseString(map['defaultExportDir']),
    exportAfterEveryEntry: ConvertUtil.parseBool(map['exportAfterEveryEntry']),
  );

  factory ExportSettings.fromJson(String json) {
    try {
      return ExportSettings.fromMap(jsonDecode(json));
    } catch (exception) {
      return ExportSettings();
    }
  }

  Map<String, dynamic> toMap() => <String, dynamic>{
    'exportFormat': exportFormat.serialize(),
    'defaultExportDir': defaultExportDir,
    'exportAfterEveryEntry': exportAfterEveryEntry,
  };

  String toJson() => jsonEncode(toMap());

  ExportFormat _exportFormat = ExportFormat.csv;
  ExportFormat get exportFormat => _exportFormat;
  set exportFormat(ExportFormat value) {
    _exportFormat = value;
    notifyListeners();
  }

  String _defaultExportDir = '';
  String get defaultExportDir => _defaultExportDir;
  set defaultExportDir(String value) {
    _defaultExportDir = value;
    notifyListeners();
  }

  bool _exportAfterEveryEntry = false;
  bool get exportAfterEveryEntry => _exportAfterEveryEntry;
  set exportAfterEveryEntry(bool value) {
    _exportAfterEveryEntry = value;
    notifyListeners();
  }

}

/// File formats to which measurements can be exported.
enum ExportFormat {
  csv,
  pdf,
  db;

  int serialize() {
    switch(this) {
      case ExportFormat.csv:
        return 0;
      case ExportFormat.pdf:
        return 1;
      case ExportFormat.db:
        return 2;
    }
  }

  factory ExportFormat.deserialize(value) {
    final int? intValue = ConvertUtil.parseInt(value);
    if (value == null || intValue == null) return ExportFormat.csv;

    switch(intValue) {
      case 0:
        return ExportFormat.csv;
      case 1:
        return ExportFormat.pdf;
      case 2:
        return ExportFormat.db;
      default:
        assert(false);
        return ExportFormat.csv;
    }
  }
}