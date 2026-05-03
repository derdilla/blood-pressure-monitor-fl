import 'dart:convert';

import 'package:blood_pressure_app/model/export_import/export_configuration.dart';
import 'package:blood_pressure_app/model/storage/convert_util.dart';
import 'package:flutter/material.dart';
import 'package:settings_annotation/settings_annotation.dart';
import 'types/active_export_column_configuration_setting.dart';

part 'export_csv_settings.store.dart';

@GenerateSettings()
class _CsvExportSettingsSpec {
  final fieldDelimiter = Setting<String>(initialValue: ';');
  final textDelimiter = Setting<String>(initialValue: '"');
  final exportHeadline = Setting<bool>(initialValue: true);
  final Setting<ActiveExportColumnConfiguration> exportFieldsConfiguration =
      ActiveExportColumnConfigurationSetting(
    initialValue: ActiveExportColumnConfiguration(),
  );
}
