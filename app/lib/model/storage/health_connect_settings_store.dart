import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:blood_pressure_app/model/storage/convert_util.dart';

/// Stores settings controlling health connect interactions.
class HealthConnectSettingsStore extends ChangeNotifier {
  /// Creates a settings object with the default values.
  HealthConnectSettingsStore({
    bool? useHealthConnect,
    bool? syncWeightMeasurements,
    bool? syncPressureMeasurements,
    bool? syncOnAppStart,
  }) {
    if (useHealthConnect != null) _useHealthConnect = useHealthConnect;
    if (syncWeightMeasurements != null) _syncWeightMeasurements = syncWeightMeasurements;
    if (syncPressureMeasurements != null) _syncPressureMeasurements = syncPressureMeasurements;
    if (syncOnAppStart != null) _syncOnAppStart = syncOnAppStart;
  }

  /// Create a instance from a map created by [toMap].
  factory HealthConnectSettingsStore.fromMap(Map<String, dynamic> map) => HealthConnectSettingsStore(
    useHealthConnect: ConvertUtil.parseBool(map['useHealthConnect']),
    syncWeightMeasurements: ConvertUtil.parseBool(map['syncWeightMeasurements']),
    syncPressureMeasurements: ConvertUtil.parseBool(map['syncPressureMeasurements']),
    syncOnAppStart: ConvertUtil.parseBool(map['syncOnAppStart']),
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
    'syncWeightMeasurements': syncWeightMeasurements,
    'syncPressureMeasurements': syncPressureMeasurements,
    'syncOnAppStart': syncOnAppStart,
  };

  /// Serialize the object to a restoreable string.
  String toJson() => jsonEncode(toMap());

  /// Copy all values from another instance.
  void copyFrom(HealthConnectSettingsStore other) {
    _useHealthConnect = other._useHealthConnect;
    _syncWeightMeasurements = other._syncWeightMeasurements;
    _syncPressureMeasurements = other._syncPressureMeasurements;
    _syncOnAppStart = other._syncOnAppStart;
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

  // TODO: implement auto syncs on save
  bool _syncWeightMeasurements = true;
  /// Whether to automatically sync new weight measurements.
  bool get syncWeightMeasurements => _syncWeightMeasurements;
  set syncWeightMeasurements(bool value) {
    _syncWeightMeasurements = value;
    notifyListeners();
  }

  bool _syncPressureMeasurements = true;
  /// Whether to automatically sync new blood pressre measurements.
  bool get syncPressureMeasurements => _syncPressureMeasurements;
  set syncPressureMeasurements(bool value) {
    _syncPressureMeasurements = value;
    notifyListeners();
  }

  bool _syncOnAppStart = true;
  /// Whether to automatically sync data on app start.
  bool get syncOnAppStart => _syncOnAppStart;
  set syncOnAppStart(bool value) {
    _syncOnAppStart = value;
    notifyListeners();
  }
}