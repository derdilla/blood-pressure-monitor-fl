import 'dart:convert';

import 'package:blood_pressure_app/model/export_import/export_configuration.dart';
import 'package:flutter/material.dart';
import 'package:settings_annotation/settings_annotation.dart';
import 'types/active_export_column_configuration_setting.dart';

part 'export_xls_settings.store.dart';

@GenerateSettings()
class _ExcelExportSettingsSpec {
  final Setting<ActiveExportColumnConfiguration> exportFieldsConfiguration =
      ActiveExportColumnConfigurationSetting(
    initialValue: ActiveExportColumnConfiguration(),
  );
}
