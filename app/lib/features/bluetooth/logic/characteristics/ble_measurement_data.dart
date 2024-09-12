import 'package:blood_pressure_app/features/bluetooth/logic/characteristics/ble_date_time.dart';
import 'package:blood_pressure_app/features/bluetooth/logic/characteristics/ble_measurement_status.dart';
import 'package:blood_pressure_app/features/bluetooth/logic/characteristics/decoding_util.dart';
import 'package:blood_pressure_app/logging.dart';
import 'package:health_data_store/health_data_store.dart';

/// https://developer.nordicsemi.com/nRF51_SDK/nRF51_SDK_v4.x.x/doc/html/structble__bps__meas__s.html
/// https://github.com/NordicSemiconductor/Kotlin-BLE-Library/blob/6b565e59de21dfa53ef80ff8351ac4a4550e8d58/profile/src/main/java/no/nordicsemi/android/kotlin/ble/profile/bps/BloodPressureMeasurementParser.kt
class BleMeasurementData {
  BleMeasurementData({
    required this.systolic,
    required this.diastolic,
    required this.meanArterialPressure,
    required this.isMMHG,
    required this.pulse,
    required this.userID,
    required this.status,
    required this.timestamp,
  });

  /// Return BleMeasurementData as a BloodPressureRecord
  BloodPressureRecord asBloodPressureRecord() =>
    BloodPressureRecord(
      time: timestamp ?? DateTime.now(),
      sys: isMMHG
        ? Pressure.mmHg(systolic.toInt())
        : Pressure.kPa(systolic),
      dia: isMMHG
        ? Pressure.mmHg(diastolic.toInt())
        : Pressure.kPa(diastolic),
      pul: pulse?.toInt(),
    );

  static BleMeasurementData? decode(List<int> data, int offset) {
    // https://github.com/NordicSemiconductor/Kotlin-BLE-Library/blob/6b565e59de21dfa53ef80ff8351ac4a4550e8d58/profile/src/main/java/no/nordicsemi/android/kotlin/ble/profile/bps/BloodPressureMeasurementParser.kt

    // Reading specific bits: `(byte & (1 << bitIdx))`

    if (data.length < 7) {
      log.warning('BleMeasurementData decodeMeasurement: Not enough data, $data has less than 7 bytes.');
      return null;
    }

    int offset = 0;

    final int flagsByte = data[offset];
    offset += 1;

    final bool isMMHG = !isBitIntByteSet(flagsByte, 0); // 0 => mmHg 1 =>kPA
    final bool timestampPresent = isBitIntByteSet(flagsByte, 1);
    final bool pulseRatePresent = isBitIntByteSet(flagsByte, 2);
    final bool userIdPresent = isBitIntByteSet(flagsByte, 3);
    final bool measurementStatusPresent = isBitIntByteSet(flagsByte, 4);

    if (data.length < (7
      + (timestampPresent ? 7 : 0)
      + (pulseRatePresent ? 2 : 0)
      + (userIdPresent ? 1 : 0)
      + (measurementStatusPresent ? 2 : 0)
    )) {
      log.warning("BleMeasurementData decodeMeasurement: Flags don't match, $data has less bytes than expected.");
      return null;
    }

    final double? systolic = readSFloat(data, offset);
    offset += 2;
    final double? diastolic = readSFloat(data, offset);
    offset += 2;
    final double? meanArterialPressure = readSFloat(data, offset);
    offset += 2;

    if (systolic == null || diastolic == null || meanArterialPressure == null) {
      log.warning('BleMeasurementData decodeMeasurement: Unable to decode required values sys, dia, and meanArterialPressure, $data.');
      return null;
    }

    DateTime? timestamp;
    if (timestampPresent) {
      timestamp = BleDateTimeParser.parseBle(data, offset);
      offset += 7;
    }

    double? pulse;
    if (pulseRatePresent) {
      pulse = readSFloat(data, offset);
      offset += 2;
    }

    int? userId;
    if (userIdPresent) {
      userId = data[offset];
      offset += 1;
    }

    BleMeasurementStatus? status;
    if (measurementStatusPresent) {
      status = BleMeasurementStatus.decode(data[offset]);
    }

    return BleMeasurementData(
      systolic: systolic,
      diastolic: diastolic,
      meanArterialPressure: meanArterialPressure,
      isMMHG: isMMHG,
      pulse: pulse,
      userID: userId,
      status: status,
      timestamp: timestamp,
    );
  }

  final double systolic;
  final double diastolic;
  final double meanArterialPressure;
  final bool isMMHG; // mmhg or kpa
  final double? pulse;
  final int? userID;
  final BleMeasurementStatus? status;
  final DateTime? timestamp;

  @override
  String toString() => 'BleMeasurementData{systolic: $systolic, diastolic: $diastolic, meanArterialPressure: $meanArterialPressure, isMMHG: $isMMHG, pulse: $pulse, userID: $userID, status: $status, timestamp: $timestamp}';
}
