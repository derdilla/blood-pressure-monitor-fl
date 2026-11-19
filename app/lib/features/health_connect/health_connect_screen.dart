import 'dart:io';

import 'package:blood_pressure_app/features/health_connect/bp_sync_model.dart';
import 'package:blood_pressure_app/features/health_connect/sync_model.dart';
import 'package:blood_pressure_app/features/health_connect/sync_tile.dart';
import 'package:blood_pressure_app/features/health_connect/weight_sync_model.dart';
import 'package:blood_pressure_app/features/settings/tiles/titled_column.dart';
import 'package:blood_pressure_app/l10n/app_localizations.dart';
import 'package:blood_pressure_app/model/storage/health_connect_settings.dart';
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
  @override
  void initState() {
    super.initState();
    _checkPermissions().ignore();
  }

  final _health = Health();

  bool _platformSupport = false;
  bool _hasWeightPermission = false;
  bool _hasBPPermission = false;

  Future<void> _checkPermissions() async {
    final settings = context.read<HealthConnectSettings>();
    if (!(Platform.isAndroid || Platform.isIOS)
      || !settings.useHealthConnect) {
      setState(() {
        _platformSupport = (Platform.isAndroid || Platform.isIOS);
        _hasWeightPermission = false;
        _hasBPPermission = false;
      });
      return;
    }
    final platformSupport = await _health.isHealthConnectAvailable();
    final hasPerms = await _health.requestPermissionsIfMissing(settings);
    final hasWeightPermission = hasPerms || (await _health.hasPermissions([HealthDataType.WEIGHT],
      permissions: [HealthDataAccess.READ_WRITE])
        ?? false);
    final hasBloodPressurePermission = hasPerms || (await _health.hasPermissions(BPSyncModel.permissions,
     permissions: List.filled(3, HealthDataAccess.READ_WRITE)) ?? false);
    setState(() {
      _platformSupport = platformSupport;
      _hasWeightPermission = hasWeightPermission;
      _hasBPPermission = hasBloodPressurePermission;
    });
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<HealthConnectSettings>();
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
                if (newValue) {
                  final granted = await _health.requestPermissionsIfMissing(settings);
                  if (!granted && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(localizations.noPermissions),
                    ));
                  }
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

          if (_needsWeightPerms(settings) && !_needsBPPerms(settings))
            _missingPermissionsBanner(localizations.noWeightPermission),
          if (!_needsWeightPerms(settings) && _needsBPPerms(settings))
            _missingPermissionsBanner(localizations.noBloodPressurePermission),
          if (_needsWeightPerms(settings) && _needsBPPerms(settings))
            _missingPermissionsBanner(localizations.noPermissions),
          SwitchListTile(
            title: Text(localizations.syncOnAppStart),
            value: settings.syncOnAppStart,
            onChanged: _hasBPPermission
                ? (v) => settings.syncOnAppStart = v
                : null,
          ),
          TitledColumn(
            title: Text(localizations.weight),
            children: [
              SwitchListTile(
                title: Text(localizations.automaticallySyncData),
                value: settings.syncWeightMeasurements,
                onChanged: _hasWeightPermission
                    ? (v) => settings.syncWeightMeasurements = v
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
                title: Text(localizations.automaticallySyncData),
                value: settings.syncPressureMeasurements,
                onChanged: _hasBPPermission
                    ? (v) => settings.syncPressureMeasurements = v
                    : null,
              ),
              SyncTile(
                disabled: !_hasBPPermission,
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

  bool _needsPerms(HealthConnectSettings settings) => settings.useHealthConnect && _platformSupport;

  bool _needsBPPerms(HealthConnectSettings settings) => _needsPerms(settings)
    && settings.syncPressureMeasurements
    && !_hasBPPermission;

  bool _needsWeightPerms(HealthConnectSettings settings) => _needsPerms(settings)
    && settings.syncWeightMeasurements
    && !_hasWeightPermission;
}
