import 'dart:io';

import 'package:blood_pressure_app/components/custom_banner.dart';
import 'package:blood_pressure_app/features/health_connect/bp_sync_model.dart';
import 'package:blood_pressure_app/features/health_connect/weight_sync_model.dart';
import 'package:blood_pressure_app/features/health_connect/sync_tile.dart';
import 'package:blood_pressure_app/features/settings/tiles/titled_column.dart';
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
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 100.0,
            stretchTriggerOffset: 300.0,
            flexibleSpace: const FlexibleSpaceBar(
              centerTitle: true,
              title: Text('Health Connect'),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(
                left: 10.0,
                right: 10.0,
                top: 16.0,
              ),
              child: Text('Health Connect uses system APIs to sync...'),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 10.0,
                vertical: 10.0,
              ),
              child: Text('If you choose to opt-in, we will use the Health'
                  ' Connect API to share blood pressure and weight measurements '
                  'with the system. Other authorized apps may request those'
                  ' values. No data will leave your device.'),
            ),
          ),
          SliverToBoxAdapter(
            child: SwitchListTile(
              title: Text('Use Health Connect'),
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
                if (!success && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(
                      'Detected that some or all permissions where not granted. Go to'
                          'androids app settings to fix this.'
                  )));
                }
                settings.useHealthConnect = newValue;
                await _checkPermissions();
              } : null,
            ),
          ),
          SliverList.list(
            children: [
              if (!_platformSupport)
                CustomBanner(
                  content: Text("Your platform doesn't support Health Connect."),
                ),
              if (_platformSupport && !_hasWeightPermission && _hasBloodPressurePermission)
                CustomBanner(
                  content: Text('No weight permission granted.'),
                  action: TextButton(
                    onPressed: _checkPermissions,
                    child: Text('check again'),
                  ),
                ),
              if (_platformSupport && _hasWeightPermission && !_hasBloodPressurePermission)
                CustomBanner(
                  content: Text('No blood pressure permission granted.'),
                  action: TextButton(
                    onPressed: _checkPermissions,
                    child: Text('check again'),
                  ),
                ),
              if (_platformSupport && !_hasWeightPermission && !_hasBloodPressurePermission)
                CustomBanner(
                  content: Text('No permissions granted.'),
                  action: TextButton(
                    onPressed: _checkPermissions,
                    child: Text('check again'),
                  ),
                ),

              TitledColumn(
                title: Text('Weight'),
                children: [
                  SwitchListTile(
                    title: Text('Automatically add new data'),
                    value: settings.syncNewWeightMeasurements,
                    onChanged: _hasWeightPermission
                        ? (v) => settings.syncNewWeightMeasurements = v
                        : null,
                  ),
                  SyncTile(mdl: WeightSyncModel(
                    weightRepo: context.watch<BodyweightRepository>(),
                    health: _health,
                  )),
                ],
              ),
              TitledColumn(
                title: Text('Blood pressure'),
                children: [
                  SwitchListTile(
                    title: Text('Automatically add new data'),
                    value: settings.syncNewPressureMeasurements,
                    onChanged: _hasBloodPressurePermission
                        ? (v) => settings.syncNewPressureMeasurements = v
                        : null,
                  ),
                  SyncTile(mdl: BPSyncModel(
                    weightRepo: context.watch<BodyweightRepository>(),
                    health: _health,
                  )),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _syncWeight() async {
    // performance: We load all data into memory at once; this might is fine
    // since there are not that many records. Measuring every day fpr 100 years
    // will yield 36525 records, or about 500 kB. 30 days would yield ~ 1 kB.

    // TODO: wrap in dialog with loading
    final weightRepo = RepositoryProvider.of<BodyweightRepository>(context);
    final now = DateTime.now();
    DateTime start = now.subtract(Duration(days: 30));
    if (await _health.isHealthDataHistoryAuthorized()) {
      start = DateTime(0);
    }

    final healthConnectData = await _health.getHealthDataFromTypes(
      types: [HealthDataType.WEIGHT],
      startTime: start,
      endTime: now,
    ).then((dataList) => {
      for (final x in dataList)
        x.dateFrom.millisecondsSinceEpoch: BodyweightRecord(
          time: x.dateFrom,
          // TODO: automatically validate with dataTypeToUnit Map
          weight: Weight.kg((x.value as NumericHealthValue).numericValue.toDouble()),
        ),
    });
    final appData = await weightRepo.get(DateRange(
        start: start,
        end: now,
    )).then((dataList) => {
      for (final x in dataList)
        x.time.millisecondsSinceEpoch: x,
    });

    // Detect records only on device, or with new value
    final healthConnectOnlyData = [
      for (final x in healthConnectData.values)
        if (appData[x.time.millisecondsSinceEpoch]?.weight != x.weight)
          x,
    ];
    // Detect records only in app
    final appOnlyData = [
      for (final x in appData.values)
        if (!healthConnectData.containsKey(x.time.millisecondsSinceEpoch))
          x,
    ];

    await Future.forEach(healthConnectOnlyData, weightRepo.add);
    await Future.forEach(appOnlyData, (record) => _health.writeHealthData(
      type: HealthDataType.WEIGHT,
      value: record.weight.kg,
      startTime: record.time
    ));
  }
}
