import 'dart:convert';

import 'package:blood_pressure_app/model/export_options.dart';
import 'package:blood_pressure_app/model/storage/convert_util.dart';
import 'package:flutter/material.dart';

class CsvExportSettings extends ChangeNotifier {
  CsvExportSettings({
    String? fieldDelimiter,
    String? textDelimiter,
    bool? exportHeadline,
    bool? exportCustomFields,
    List<String>? customFields,
  }) {
    if (fieldDelimiter != null) _fieldDelimiter = fieldDelimiter;
    if (textDelimiter != null) _textDelimiter = textDelimiter;
    if (exportHeadline != null) _exportHeadline = exportHeadline;
    if (exportCustomFields != null) _exportCustomFields = exportCustomFields;
    if (customFields != null) _customFields = customFields;
  }

  factory CsvExportSettings.fromMap(Map<String, dynamic> map) => CsvExportSettings(
      fieldDelimiter: ConvertUtil.parseString(map['fieldDelimiter']),
      textDelimiter: ConvertUtil.parseString(map['textDelimiter']),
      exportHeadline: ConvertUtil.parseBool(map['exportHeadline']),
      exportCustomFields: ConvertUtil.parseBool(map['exportCustomFields']),
      customFields: ConvertUtil.parseList<String>(map['customFields']),
  );

  factory CsvExportSettings.fromJson(String json) {
    try {
      return CsvExportSettings.fromMap(jsonDecode(json));
    } catch (exception) {
      return CsvExportSettings();
    }
  }

  Map<String, dynamic> toMap() => <String, dynamic>{
    'fieldDelimiter': fieldDelimiter,
    'textDelimiter': textDelimiter,
    'exportHeadline': exportHeadline,
    'exportCustomFields': exportCustomFields,
    'customFields': customFields,
  };

  String toJson() => jsonEncode(toMap());

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

  bool _exportCustomFields = false;
  bool get exportCustomFields => _exportCustomFields;
  set exportCustomFields(bool value) {
    _exportCustomFields = value;
    notifyListeners();
  }

  List<String> _customFields = ExportFields.defaultCsv;
  List<String> get customFields => _customFields;
  set customFields(List<String> value) {
    _customFields = value;
    notifyListeners();
  }

  // Procedure for adding more entries described in the settings_store.dart doc comment
}