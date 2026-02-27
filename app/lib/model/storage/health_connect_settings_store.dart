import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:blood_pressure_app/model/storage/convert_util.dart';

/// Stores settings controlling health connect interactions.
class HealthConnectSettingsStore extends ChangeNotifier {
  /// Creates a settings object with the default values.
  HealthConnectSettingsStore({
    bool? useHealthConnect,
    bool? syncNewWeightMeasurements,
    bool? syncNewPressureMeasurements,
  }) {
    if (useHealthConnect != null) _useHealthConnect = useHealthConnect;
    if (syncNewWeightMeasurements != null) _syncNewWeightMeasurements = syncNewWeightMeasurements;
    if (syncNewPressureMeasurements != null) _syncNewPressureMeasurements = syncNewPressureMeasurements;
  }

  /// Create a instance from a map created by [toMap].
  factory HealthConnectSettingsStore.fromMap(Map<String, dynamic> map) => HealthConnectSettingsStore(
    useHealthConnect: ConvertUtil.parseBool(map['useHealthConnect']),
    syncNewWeightMeasurements: ConvertUtil.parseBool(map['syncNewWeightMeasurements']),
    syncNewPressureMeasurements: ConvertUtil.parseBool(map['syncNewPressureMeasurements']),
  );

  /// Create a instance from a [String] created by [toJson].
  factory HealthConnectSettingsStore.fromJson(String json) {
    try {
      return HealthConnectSettingsStore.fromMap(jsonDecode(json));
    } catch (exception) {
      return HealthConnectSettingsStore();
    }
  }

  Map<String, dynamic> toMap() => <String, dynamic>{
    'useHealthConnect': useHealthConnect,
    'syncNewWeightMeasurements': syncNewWeightMeasurements,
    'syncNewPressureMeasurements': syncNewPressureMeasurements,
  };

  /// Serialize the object to a restoreable string.
  String toJson() => jsonEncode(toMap());

  /// Copy all values from another instance.
  void copyFrom(HealthConnectSettingsStore other) {
    _useHealthConnect = other._useHealthConnect;
    _syncNewWeightMeasurements = other._syncNewWeightMeasurements;
    _syncNewPressureMeasurements = other._syncNewPressureMeasurements;
  }

  /// Reset all fields to their default values.
  void reset() => copyFrom(HealthConnectSettingsStore());

  bool _useHealthConnect = false;
  /// Whether to enable health connect.
  bool get useHealthConnect => _useHealthConnect;
  set useHealthConnect(bool value) {
    _useHealthConnect = value;
    notifyListeners();
  }

  bool _syncNewWeightMeasurements = true;
  /// Whether to automatically sync new weight measurements.
  bool get syncNewWeightMeasurements => _syncNewWeightMeasurements;
  set syncNewWeightMeasurements(bool value) {
    _syncNewWeightMeasurements = value;
    notifyListeners();
  }

  bool _syncNewPressureMeasurements = true;
  /// Whether to automatically sync new blood pressre measurements.
  bool get syncNewPressureMeasurements => _syncNewPressureMeasurements;
  set syncNewPressureMeasurements(bool value) {
    _syncNewPressureMeasurements = value;
    notifyListeners();
  }
}