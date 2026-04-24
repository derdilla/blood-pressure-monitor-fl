import 'dart:convert';

import 'package:blood_pressure_app/model/storage/convert_util.dart';
import 'package:flutter/material.dart';
import 'types/export_format_setting.dart';
import 'package:settings_annotation/settings_annotation.dart';

part 'export_settings.store.dart';

/// General settings for exporting measurements that are applicable to all export formats.
@GenerateSettings()
class _ExportSettingsSpec extends ChangeNotifier {
  final Setting<ExportFormat> exportFormat = ExportFormatSetting(initialValue: ExportFormat.csv);
  final defaultExportDir = Setting<String>(initialValue: '');
  final exportAfterEveryEntry = Setting<bool>(initialValue: false);
}