import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:blood_pressure_app/model/storage/convert_util.dart';

/// Stores settings controlling health connect interactions.
class HealthConnectSettingsStore extends ChangeNotifier {
  /// Creates a settings object with the default values.
  HealthConnectSettingsStore({
    bool? useHealthConnect,
    bool? syncNewMeasurements,
  }) {
    if (useHealthConnect != null) _useHealthConnect = useHealthConnect;
    if (syncNewMeasurements != null) _syncNewMeasurements = syncNewMeasurements;
  }

  /// Create a instance from a map created by [toMap].
  factory HealthConnectSettingsStore.fromMap(Map<String, dynamic> map) => HealthConnectSettingsStore(
    useHealthConnect: ConvertUtil.parseBool(map['useHealthConnect']),
    syncNewMeasurements: ConvertUtil.parseBool(map['syncNewMeasurements']),
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
    'syncNewMeasurements': syncNewMeasurements,
  };

  /// Serialize the object to a restoreable string.
  String toJson() => jsonEncode(toMap());

  /// Copy all values from another instance.
  void copyFrom(HealthConnectSettingsStore other) {
    _useHealthConnect = other._useHealthConnect;
    _syncNewMeasurements = other._syncNewMeasurements;
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

  bool _syncNewMeasurements = true;
  /// Whether to automatically sync new measurements.
  bool get syncNewMeasurements => _syncNewMeasurements;
  set syncNewMeasurements(bool value) {
    _syncNewMeasurements = value;
    notifyListeners();
  }
}