import 'dart:math';

import 'package:blood_pressure_app/logging.dart';
import 'package:blood_pressure_app/model/blood_pressure/record.dart';

/// Decoder for blood pressure values.
class CharacteristicDecoder {
  /// Parse a measurement from binary data.
  static BloodPressureRecord decodeMeasurement(List<int> data) {
    // This is valid parsing according to: https://github.com/NobodyForNothing/blood-pressure-monitor-fl/issues/80#issuecomment-2067212894
    // TODO: check if this really works and remove old characteristics decodes if it does.
    print(data);
    return BloodPressureRecord(DateTime.now(), data[1], data[3], data[14], '');
  }

  static BloodPressureRecord? decodeMeasurementV2(List<int> data) {
    // https://github.com/NordicSemiconductor/Kotlin-BLE-Library/blob/6b565e59de21dfa53ef80ff8351ac4a4550e8d58/profile/src/main/java/no/nordicsemi/android/kotlin/ble/profile/bps/BloodPressureMeasurementParser.kt

    // Reading specific bits: `(byte & (1 < bitIdx))`

    if (data.length < 7) {
      Log.trace('BleMeasurementData decodeMeasurement: Not enough data, $data has less than 7 bytes.');
      return null;
    }

    int offset = 0;

    final int flagsByte = data[offset];
    offset += 1;

    final bool isMMHG = ((flagsByte & (1 << 0)) == 0);
    final bool timestampPresent = ((flagsByte & (1 << 1)) == 0);
    final bool pulseRatePresent = ((flagsByte & (1 << 2)) == 0);
    final bool userIdPresent = ((flagsByte & (1 << 3)) == 0);
    final bool measurementStatusPresent = ((flagsByte & (1 << 4)) == 0);

    if (data.length < (7
        + (timestampPresent ? 7 : 0)
        + (pulseRatePresent ? 2 : 0)
        + (userIdPresent ? 1 : 0)
        + (measurementStatusPresent ? 2 : 0)
    )) {
      Log.trace("BleMeasurementData decodeMeasurement: Flags don't match, $data has less bytes than expected.");
      return null;
    }

    final double? systolic = _readSFloat(data, offset);
    offset += 2;
    final double? diastolic = _readSFloat(data, offset);
    offset += 2;
    final double? meanArterialPressure = _readSFloat(data, offset);
    offset += 2;

    if (systolic == null || diastolic == null || meanArterialPressure == null) {
      Log.trace('BleMeasurementData decodeMeasurement: Unable to decode required values sys, dia, and meanArterialPressure, $data.');
      return null;
    }

    if (timestampPresent) {
      // TODO: decode timestamp
      offset += 7;
    }

    double? pulse;
    if (pulseRatePresent) {
      pulse = _readSFloat(data, offset);
      offset += 2;
    }

    return BloodPressureRecord(DateTime.now(), systolic.toInt(), diastolic.toInt(), pulse?.toInt(), '');
    /*return BleMeasurementData(
      systolic: systolic,
      diastolic: diastolic,
      meanArterialPressure: meanArterialPressure,
      isMMHG: isMMHG,
      pulseRate: -1,
      userID: -1,
      status: BleaM
    );*/
  }
}

/// Attempts to read an IEEE-11073 16bit SFloat starting at data[offset].
double? _readSFloat(List<int> data, int offset) {
  if (data.length < offset + 2) return null;
  // TODO: special values (NaN, Infinity)
  final mantissa = data[offset] + ((data[offset + 1] & 0x0F) << 8); // TODO: https://github.com/NordicSemiconductor/Kotlin-BLE-Library/blob/6b565e59de21dfa53ef80ff8351ac4a4550e8d58/core/src/main/java/no/nordicsemi/android/kotlin/ble/core/data/util/DataByteArray.kt#L392
  final exponent = data[offset + 1] >> 4;
  return (mantissa * (pow(10, exponent))).toDouble();
}
