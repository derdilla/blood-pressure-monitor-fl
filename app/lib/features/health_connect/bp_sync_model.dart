import 'package:blood_pressure_app/features/health_connect/sync_model.dart';
import 'package:blood_pressure_app/logging.dart';
import 'package:health/health.dart';
import 'package:health_data_store/health_data_store.dart';

class BPSyncModel extends SyncModel with TypeLogger {
  BPSyncModel({required this.bpRepo, required this.health});

  final BloodPressureRepository bpRepo;
  final Health health;

  bool _syncing = false;
  @override
  bool get syncing => _syncing;

  int _progress = 0;
  @override
  double get progress => _progress / 7;

  @override
  Future<void> syncWeight() async {
    _syncing = true;
    _progress = 0;
    notifyListeners();

    final hasPermissions = await health.hasPermissions([
      HealthDataType.BLOOD_PRESSURE_SYSTOLIC,
      HealthDataType.BLOOD_PRESSURE_DIASTOLIC],
      permissions: List.filled(2, HealthDataAccess.READ_WRITE),
    );
    if (!(hasPermissions ?? false)) {
      // We are annoying here since one-way sync would be a different feature.
      await health.requestAuthorization([
        HealthDataType.BLOOD_PRESSURE_SYSTOLIC,
        HealthDataType.BLOOD_PRESSURE_DIASTOLIC,
      ], permissions: List.filled(2, HealthDataAccess.READ_WRITE));
    }
    final now = DateTime.now();
    DateTime start = now.subtract(Duration(days: 30));
    if (await health.isHealthDataHistoryAuthorized()
      || await health.requestHealthDataHistoryAuthorization()) {
      start = DateTime(0);
    }
    _progress += 1;
    notifyListeners();

    final healthConnectData = await health.getHealthDataFromTypes(
      types: [
        HealthDataType.BLOOD_PRESSURE_SYSTOLIC,
        HealthDataType.BLOOD_PRESSURE_DIASTOLIC,
      ],
      startTime: start,
      endTime: now,
    ).then((dataList) {
      final records = <String, BloodPressureRecord>{};
      for (final x in dataList) {
        final partialRecord =  records[x.uuid];
        assert(partialRecord == null || partialRecord.time == x.dateFrom);
        if (x.type == HealthDataType.BLOOD_PRESSURE_SYSTOLIC) {
          final newSys = (x.value as NumericHealthValue).numericValue.toInt();
          records[x.uuid] = BloodPressureRecord(
            time: x.dateFrom,
            sys: Pressure.mmHg(newSys),
            dia: partialRecord?.dia,
          );
        } else if (x.type == HealthDataType.BLOOD_PRESSURE_DIASTOLIC) {
          final newDia = (x.value as NumericHealthValue).numericValue.toInt();
          records[x.uuid] = BloodPressureRecord(
            time: x.dateFrom,
            sys: partialRecord?.sys,
            dia: Pressure.mmHg(newDia),
          );
        } else {
          assert(false);
        }
      }
      return {
        for (final x in records.values)
          x.time.millisecondsSinceEpoch: x,
      };
    });
    _progress += 1;
    notifyListeners();

    final appData = await bpRepo.get(DateRange(
      start: start,
      end: now,
    )).then((dataList) => {
      for (final x in dataList)
        x.time.millisecondsSinceEpoch: x,
    });
    _progress += 1;
    notifyListeners();

    // Detect records only on device, or with new value
    final healthConnectOnlyData = [
      for (final x in healthConnectData.values)
        if (appData[x.time.millisecondsSinceEpoch]?.sys != x.sys
            || appData[x.time.millisecondsSinceEpoch]?.dia != x.dia)
          BloodPressureRecord(
            time: x.time,
            sys: x.sys,
            dia: x.dia,
            pul: appData[x.time.millisecondsSinceEpoch]?.pul
          ),
    ];
    _progress += 1;
    notifyListeners();

    // Detect records only in app
    final appOnlyData = [
      for (final x in appData.values)
        if (!healthConnectData.containsKey(x.time.millisecondsSinceEpoch))
          x,
    ];
    _progress += 1;
    notifyListeners();

    await Future.forEach(healthConnectOnlyData, bpRepo.add);
    _progress += 1;
    notifyListeners();

    await Future.forEach(appOnlyData, (record) async {
      if (record.sys == null || record.dia == null) {
        logger.info('Skip syncing incomplete BP record');
        return false;
      }
      return health.writeBloodPressure(
        systolic: record.sys!.mmHg,
        diastolic: record.dia!.mmHg,
        startTime: record.time,
      );
    });
    _progress += 1;
    _syncing = false;
    notifyListeners();
  }
}
