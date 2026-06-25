import 'dart:convert';

import 'package:blood_pressure_app/features/export_import/model/export_preset.dart';
import 'package:flutter/material.dart';
import 'package:settings_annotation/settings_annotation.dart';

part 'export_csv_settings.store.dart';

@GenerateSettings()
class _CsvExportSettingsSpec {
  final fieldDelimiter = Setting<String>(initialValue: ';');
  final textDelimiter = Setting<String>(initialValue: '"');
  final exportHeadline = Setting<bool>(initialValue: true);
  final activePreset = Setting<String>(initialValue: ExportPreset.appDefault.id);
}
