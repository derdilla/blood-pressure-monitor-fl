import 'package:blood_pressure_app/features/health_connect/bp_sync_model.dart';
import 'package:blood_pressure_app/model/storage/health_connect_settings.dart';
import 'package:flutter/foundation.dart';
import 'package:health/health.dart';

abstract class SyncModel<T> extends ChangeNotifier {
  bool get syncing;

  double get progress;

  Future<void> sync();
  Future<bool> saveEntry(T entry);
}

extension RequestPermissions on Health {
  /// Requests configured types with [permission] if not already available.
  ///
  /// Requests all permissions used by the app if not specified.
  Future<bool> requestPermissionsIfMissing(
    HealthConnectSettings settings,
  ) async {
    const permission = HealthDataAccess.READ_WRITE;
    final types = [
      if (settings.syncPressureMeasurements) ...BPSyncModel.permissions,
      if (settings.syncWeightMeasurements) HealthDataType.WEIGHT,
    ];

    final hasPerms =
        await hasPermissions(
          types,
          permissions: List.filled(types.length, permission),
        ) ??
        false;
    if (!hasPerms) {
      return requestAuthorization(
        types,
        permissions: List.filled(types.length, permission),
      );
    }
    return hasPerms;
  }
}
