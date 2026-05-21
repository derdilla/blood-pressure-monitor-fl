import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:settings_annotation/settings_annotation.dart';

part 'health_connect_settings.store.dart';

/// Stores settings controlling health connect interactions.
@GenerateSettings()
class _HealthConnectSettingsSpec {
  final useHealthConnect = Setting<bool>(initialValue: false);
  final syncWeightMeasurements = Setting<bool>(initialValue: true);
  final syncPressureMeasurements = Setting<bool>(initialValue: true);
  final syncOnAppStart = Setting<bool>(initialValue: true);
}
