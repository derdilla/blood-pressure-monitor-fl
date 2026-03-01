import 'dart:io';

import 'package:blood_pressure_app/components/custom_banner.dart';
import 'package:blood_pressure_app/features/health_connect/bp_sync_model.dart';
import 'package:blood_pressure_app/features/health_connect/sync_tile.dart';
import 'package:blood_pressure_app/features/health_connect/weight_sync_model.dart';
import 'package:blood_pressure_app/features/settings/tiles/titled_column.dart';
import 'package:blood_pressure_app/l10n/app_localizations.dart';
import 'package:blood_pressure_app/model/storage/health_connect_settings_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health/health.dart';
import 'package:health_data_store/health_data_store.dart';

class HealthConnectScreen extends StatefulWidget {
  const HealthConnectScreen({super.key});

  @override
  State<HealthConnectScreen> createState() => _HealthConnectScreenState();
}

class _HealthConnectScreenState extends State<HealthConnectScreen> {
  // TODO: support limited permissions and one way sync

  @override
  void initState() {
    super.initState();
    _checkPermissions().ignore();
  }

  final _health = Health();

  bool _platformSupport = false;
  bool _hasWeightPermission = false;
  bool _hasBloodPressurePermission = false;

  Future<void> _checkPermissions() async {
    if (!(Platform.isAndroid || Platform.isIOS)) {
      setState(() {
        _platformSupport = false;
        _hasWeightPermission = false;
        _hasBloodPressurePermission = false;
      });
      return;
    }
    final platformSupport = await _health.isHealthConnectAvailable();
    final hasWeightPermission = await _health.hasPermissions([HealthDataType.WEIGHT],
      permissions: [HealthDataAccess.READ_WRITE])
        ?? false;
    final hasBloodPressurePermission = await _health.hasPermissions([
      HealthDataType.BLOOD_PRESSURE_SYSTOLIC,
      HealthDataType.BLOOD_PRESSURE_DIASTOLIC
    ], permissions: [HealthDataAccess.READ_WRITE, HealthDataAccess.READ_WRITE]) ?? false;
    setState(() {
      _platformSupport = platformSupport;
      _hasWeightPermission = hasWeightPermission;
      _hasBloodPressurePermission = hasBloodPressurePermission;
    });
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<HealthConnectSettingsStore>();
    final localizations = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.healthConnect),
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.only(
              left: 10.0,
              right: 10.0,
              top: 16.0,
              bottom: 10.0
            ),
            child: Text(localizations.healthConnectDesc),
          ),
          Padding(
            padding: EdgeInsetsGeometry.symmetric(horizontal: 8.0),
            child: SwitchListTile(
              title: Text(localizations.optEnableHealthConnect),
              tileColor: Theme.of(context).cardColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadiusGeometry.circular(16.0)
              ),
              minVerticalPadding: 22.0,
              value: settings.useHealthConnect,
              onChanged: (Platform.isAndroid || Platform.isIOS) ? (newValue) async {
                bool success = true;
                if (newValue) {
                  final types = [
                    HealthDataType.WEIGHT,
                    HealthDataType.BLOOD_PRESSURE_SYSTOLIC,
                    HealthDataType.BLOOD_PRESSURE_DIASTOLIC,
                  ];
                  success = await _health.requestAuthorization(types);
                } else {
                  await _health.revokePermissions();
                }
                settings.useHealthConnect = newValue;
                await _checkPermissions();
              } : null,
              subtitle: _platformSupport ? null : Text(localizations.healthConnectPlatformUnsupported,
                  style: TextStyle(color: Theme.of(context).colorScheme.error)),
            ),
          ),

          if (_platformSupport && !_hasWeightPermission && _hasBloodPressurePermission)
            _missingPermissionsBanner(localizations.noWeightPermission),
          if (_platformSupport && _hasWeightPermission && !_hasBloodPressurePermission)
            _missingPermissionsBanner(localizations.noBloodPressurePermission),
          if (_platformSupport && !_hasWeightPermission && !_hasBloodPressurePermission)
            _missingPermissionsBanner(localizations.noPermissions),
          TitledColumn(
            title: Text(localizations.weight),
            children: [
              SwitchListTile(
                title: Text(localizations.automaticallyAddNewData),
                value: settings.syncNewWeightMeasurements,
                onChanged: _hasWeightPermission
                    ? (v) => settings.syncNewWeightMeasurements = v
                    : null,
              ),
              SyncTile(
                disabled: !_hasWeightPermission,
                mdl: WeightSyncModel(
                  weightRepo: context.watch<BodyweightRepository>(),
                  health: _health,
                ),
              ),
            ],
          ),
          TitledColumn(
            title: Text(localizations.bloodPressure),
            children: [
              SwitchListTile(
                title: Text(localizations.automaticallyAddNewData),
                value: settings.syncNewPressureMeasurements,
                onChanged: _hasBloodPressurePermission
                    ? (v) => settings.syncNewPressureMeasurements = v
                    : null,
              ),
              SyncTile(
                disabled: !_hasBloodPressurePermission,
                mdl: BPSyncModel(
                  bpRepo: context.watch<BloodPressureRepository>(),
                  health: _health,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _missingPermissionsBanner(String reason) => Padding(
    padding: EdgeInsetsGeometry.symmetric(
      horizontal: 8.0,
      vertical: 2.0
    ),
    child: Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(reason, style: TextStyle(color: Theme.of(context).colorScheme.error)),
        TextButton(
          onPressed: _checkPermissions,
          child: Text(AppLocalizations.of(context)!.btnCheckAgain),
        ),
      ],
    ),
  );
}
