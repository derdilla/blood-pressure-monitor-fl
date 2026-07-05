import 'dart:typed_data';

import 'package:blood_pressure_app/features/bluetooth/logic/characteristics/ble_measurement_data.dart';
import 'package:blood_pressure_app/logging.dart';

/// A single measurement decoded from a Microlife bluetooth blood pressure
/// monitor (e.g. BP3GY1-2N).
class MicrolifeMeasurementData {
  
  MicrolifeMeasurementData({
    required this.timestamp,
    required this.systolicMmHg,
    required this.diastolicMmHg,
    required this.pulseBpm,
  });

  // Minute-accurate timestamp
  final DateTime timestamp;

  final int systolicMmHg;
  final int diastolicMmHg;
  final int pulseBpm;

  // Offset of the first measurement record in the response payload.
  static const _recordsOffset = 38;

  // Distance in bytes between two measurement records. Only the first 8 bytes
  // of each record are used, the remaining bytes are padding.
  static const _recordStride = 10;

  /// Decode all measurements contained in a "get measurements" response payload.
  ///
  /// [payload] is the content of a protocol frame without the
  /// header, length and checksum (see `MicrolifeProtocol`).
  ///
  /// Each record stores single byte values without scaling:
  /// `systolic, diastolic, pulse, year (+2000), month, day, hour, minute`.
  static List<MicrolifeMeasurementData> decodeMeasurements(Uint8List payload) {
    final measurements = <MicrolifeMeasurementData>[];
    for (var i = _recordsOffset; i + 8 <= payload.length; i += _recordStride) {
      final systolic = payload[i];
      final diastolic = payload[i + 1];
      final pulse = payload[i + 2];
      final year = 2000 + payload[i + 3];
      final month = payload[i + 4];
      final day = payload[i + 5];
      final hour = payload[i + 6];
      final minute = payload[i + 7];

      // Empty record slots are returned as zeros, skip them.
      if (systolic == 0 && diastolic == 0 && pulse == 0) continue;

      if (month < 1 || month > 12 || day < 1 || day > 31
          || hour > 23 || minute > 59) {
        log.info('MicrolifeMeasurementData skipping record with invalid date: '
            '${payload.sublist(i, i + 8)}');
        continue;
      }

      measurements.add(MicrolifeMeasurementData(
        timestamp: DateTime(year, month, day, hour, minute),
        systolicMmHg: systolic,
        diastolicMmHg: diastolic,
        pulseBpm: pulse,
      ));
    }
    return measurements;
  }

  BleMeasurementData get asBleData => BleMeasurementData(
    timestamp: timestamp,
    systolic: systolicMmHg.toDouble(),
    diastolic: diastolicMmHg.toDouble(),
    isMMHG: true,
    pulse: pulseBpm.toDouble(),
    meanArterialPressure: 1 / 3 * systolicMmHg + 2 / 3 * diastolicMmHg,
  );
}
