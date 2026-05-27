
import 'dart:typed_data';

import 'package:blood_pressure_app/features/bluetooth/logic/characteristics/ble_measurement_data.dart';
import 'package:blood_pressure_app/logging.dart';

class YonkerMeasurementData {
  YonkerMeasurementData({
    required this.timestamp,
    required this.systolic,
    required this.diastolic,
    required this.pulse,
  });

  /// Minute-accurate timestamp. The internal clock is unreliable.
  final DateTime timestamp;

  /// Unit: mmHg
  final int systolic;

  /// Unit: mmHg
  final int diastolic;

  /// Unit: bpm
  final int pulse;

  static YonkerMeasurementData? decode(Uint8List data) {
    // Manually decoded in issue: https://github.com/derdilla/blood-pressure-monitor-fl/issues/615

    if (data.length != 15) {
      log.info('YonkerMeasurementData.decode received data with bad length: $data');
      return null;
    }

    if (data[0] != 0x81) {
      log.info("YonkerMeasurementData.decode didn't find type flag");
      return null;
    }

    return YonkerMeasurementData(
      timestamp: DateTime(2000 + data[8], data[7], data[6], data[9], data[10]),
      systolic: data[1],
      diastolic: data[2],
      pulse: data[3]
    );
  }

  BleMeasurementData get asBleData => BleMeasurementData(
    timestamp: timestamp,
    systolic: systolic.toDouble(),
    diastolic: diastolic.toDouble(),
    isMMHG: true,
    pulse: pulse.toDouble(),
    meanArterialPressure: 1/3 * systolic + 2/3 * diastolic,
  );
}
