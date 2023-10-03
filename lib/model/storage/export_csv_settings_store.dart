import 'dart:convert';

import 'package:blood_pressure_app/model/storage/convert_util.dart';
import 'package:flutter/material.dart';

class CsvExportSettings extends ChangeNotifier {
  CsvExportSettings({
    String? fieldDelimiter,
    String? textDelimiter,
    bool? exportHeadline
  }) {
    if (fieldDelimiter != null) _fieldDelimiter = fieldDelimiter;
    if (textDelimiter != null) _textDelimiter = textDelimiter;
    if (exportHeadline != null) _exportHeadline = exportHeadline;
  }

  factory CsvExportSettings.fromMap(Map<String, dynamic> map) => CsvExportSettings(
      fieldDelimiter: ConvertUtil.parseString(map['fieldDelimiter']),
      textDelimiter: ConvertUtil.parseString(map['textDelimiter']),
      exportHeadline: ConvertUtil.parseBool(map['exportHeadline'])
  );

  factory CsvExportSettings.fromJson(String json) => CsvExportSettings.fromMap(jsonDecode(json));

  Map<String, dynamic> toMap() => <String, dynamic>{
    'fieldDelimiter': fieldDelimiter,
    'textDelimiter': textDelimiter,
    'exportHeadline': exportHeadline
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

  // Procedure for adding more entries described in the settings_store.dart doc comment
}