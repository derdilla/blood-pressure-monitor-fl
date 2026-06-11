import 'dart:convert';

import 'package:blood_pressure_app/features/export_import/model/export_configuration.dart';
import 'package:blood_pressure_app/features/export_import/model/export_preset.dart';
import 'package:flutter/material.dart';
import 'package:settings_annotation/settings_annotation.dart';

part 'export_pdf_settings.store.dart';

@GenerateSettings()
class _PdfExportSettingsSpec {
  final exportTitle = Setting<bool>(initialValue: true);
  final exportStatistics = Setting<bool>(initialValue: false);
  final exportData = Setting<bool>(initialValue: true);
  final headerHeight = Setting<double>(initialValue: 20);
  final cellHeight = Setting<double>(initialValue: 15);
  final headerFontSize = Setting<double>(initialValue: 10);
  final cellFontSize = Setting<double>(initialValue: 8);
  final activePreset = Setting<String>(initialValue: ExportPreset.appPdf.id);
}
