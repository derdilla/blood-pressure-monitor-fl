import 'package:blood_pressure_app/features/health_connect/sync_model.dart';
import 'package:health/health.dart';
import 'package:health_data_store/health_data_store.dart';

class BPSyncModel extends SyncModel {
  BPSyncModel({required this.weightRepo, required this.health});

  final BodyweightRepository weightRepo;
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

    final now = DateTime.now();
    DateTime start = now.subtract(Duration(days: 30));
    if (await health.isHealthDataHistoryAuthorized()) {
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

    // FIXME: implement
    print(healthConnectData);
  }
}
