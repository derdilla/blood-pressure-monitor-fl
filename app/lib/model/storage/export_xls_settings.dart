import 'dart:convert';

import 'package:blood_pressure_app/features/export_import/model/export_configuration.dart';
import 'package:blood_pressure_app/features/export_import/model/export_preset.dart';
import 'package:flutter/material.dart';
import 'package:settings_annotation/settings_annotation.dart';

part 'export_xls_settings.store.dart';

@GenerateSettings()
class _ExcelExportSettingsSpec {

  final activePreset = Setting<String>(initialValue: ExportPreset.appDefault.id);
}
