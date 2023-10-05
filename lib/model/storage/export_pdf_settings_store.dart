import 'dart:convert';

import 'package:blood_pressure_app/model/export_options.dart';
import 'package:blood_pressure_app/model/storage/common_settings_intervaces.dart';
import 'package:blood_pressure_app/model/storage/convert_util.dart';
import 'package:flutter/material.dart';

class PdfExportSettings extends ChangeNotifier implements CustomFieldsSettings {
  PdfExportSettings({
    bool? exportTitle,
    bool? exportStatistics,
    bool? exportData,
    bool? exportCustomFields,
    double? headerHeight,
    double? cellHeight,
    double? headerFontSize,
    double? cellFontSize,
    List<String>? customFields,
  }) {
    if (exportTitle != null) _exportTitle = exportTitle;
    if (exportStatistics != null) _exportStatistics = exportStatistics;
    if (exportData != null) _exportData = exportData;
    if (headerHeight != null) _headerHeight = headerHeight;
    if (cellHeight != null) _cellHeight = cellHeight;
    if (headerFontSize != null) _headerFontSize = headerFontSize;
    if (cellFontSize != null) _cellFontSize = cellFontSize;
    if (exportCustomFields != null) _exportCustomFields = exportCustomFields;
    if (customFields != null) _customFields = customFields;
  }

  factory PdfExportSettings.fromMap(Map<String, dynamic> map) => PdfExportSettings(
    exportTitle: ConvertUtil.parseBool(map['exportTitle']),
    exportStatistics: ConvertUtil.parseBool(map['exportStatistics']),
    exportData: ConvertUtil.parseBool(map['exportData']),
    headerHeight: ConvertUtil.parseDouble(map['headerHeight']),
    cellHeight: ConvertUtil.parseDouble(map['cellHeight']),
    headerFontSize: ConvertUtil.parseDouble(map['headerFontSize']),
    cellFontSize: ConvertUtil.parseDouble(map['cellFontSize']),
    exportCustomFields: ConvertUtil.parseBool(map['exportCustomFields']),
    customFields: ConvertUtil.parseList<String>(map['customFields']),
  );

  factory PdfExportSettings.fromJson(String json) {
    try {
      return PdfExportSettings.fromMap(jsonDecode(json));
    } catch (exception) {
      return PdfExportSettings();
    }
  }

  Map<String, dynamic> toMap() => <String, dynamic>{
    'exportTitle': exportTitle,
    'exportStatistics': exportStatistics,
    'exportData': exportData,
    'headerHeight': headerHeight,
    'cellHeight': cellHeight,
    'headerFontSize': headerFontSize,
    'cellFontSize': cellFontSize,
    'exportCustomFields': exportCustomFields,
    'customFields': customFields,
  };

  String toJson() => jsonEncode(toMap());

  bool _exportTitle = true;
  bool get exportTitle => _exportTitle;
  set exportTitle(bool value) {
    _exportTitle = value;
    notifyListeners();
  }

  bool _exportStatistics = false;
  bool get exportStatistics => _exportStatistics;
  set exportStatistics(bool value) {
    _exportStatistics = value;
    notifyListeners();
  }

  bool _exportData = true;
  bool get exportData => _exportData;
  set exportData(bool value) {
    _exportData = value;
    notifyListeners();
  }

  double _headerHeight = 20;
  double get headerHeight => _headerHeight;
  set headerHeight(double value) {
    _headerHeight = value;
    notifyListeners();
  }

  double _cellHeight = 15;
  double get cellHeight => _cellHeight;
  set cellHeight(double value) {
    _cellHeight = value;
    notifyListeners();
  }

  double _headerFontSize = 10;
  double get headerFontSize => _headerFontSize;
  set headerFontSize(double value) {
    _headerFontSize = value;
    notifyListeners();
  }

  double _cellFontSize = 8;
  double get cellFontSize => _cellFontSize;
  set cellFontSize(double value) {
    _cellFontSize = value;
    notifyListeners();
  }

  bool _exportCustomFields = false;
  bool get exportCustomFields => _exportCustomFields;
  set exportCustomFields(bool value) {
    _exportCustomFields = value;
    notifyListeners();
  }

  List<String> _customFields = ExportFields.defaultPdf;
  List<String> get customFields => _customFields;
  set customFields(List<String> value) {
    _customFields = value;
    notifyListeners();
  }

  // Procedure for adding more entries described in the settings_store.dart doc comment
}