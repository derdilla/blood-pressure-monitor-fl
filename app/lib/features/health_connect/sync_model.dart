import 'package:blood_pressure_app/features/health_connect/bp_sync_model.dart';
import 'package:flutter/foundation.dart';
import 'package:health/health.dart';

abstract class SyncModel extends ChangeNotifier {
  bool get syncing;

  double get progress;

  Future<void> sync();
}

extension RequestPermissions on Health {
  /// Requests each [types] with [permission] if not already available.
  ///
  /// Requests all permissions used by the app if not specified.
  Future<bool> requestPermissionsIfMissing([
    List<HealthDataType>? types,
    HealthDataAccess permission = HealthDataAccess.READ_WRITE,
  ]) async {
    types ??= [
      ...BPSyncModel.permissions,
      HealthDataType.WEIGHT,
    ];

    final canWrite = await hasPermissions(
      types,
      permissions: List.filled(types.length, permission),
    ) ?? false;
    if (!canWrite) {
      return requestAuthorization(
        types,
        permissions: List.filled(types.length, permission),
      );
    }
    return canWrite;
  }
}
