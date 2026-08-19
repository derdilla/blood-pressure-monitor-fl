import 'dart:typed_data';

import 'package:blood_pressure_app/features/bluetooth/logic/characteristics/ble_measurement_data.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('decodes sample data', () {
    // 22 => 0001 0110
    final result = BleMeasurementData.decode(Uint8List.fromList([22, 124, 0, 86, 0, 97, 0, 232, 7, 6, 15, 17, 17, 27, 51, 0, 0, 0]));

    expect(result, isNotNull);
    expect(result!.systolic, 124.0);
    expect(result.diastolic, 86.0);
    expect(result.meanArterialPressure, 97.0);
    expect(result.isMMHG, true);

    expect(result.pulse, 51.0);
    expect(result.timestamp, DateTime(2024, 06, 15, 17, 17, 27));
    expect(result.userID, null);
    expect(result.status?.bodyMovementDetected, false);
    expect(result.status?.cuffTooLose, false);
    expect(result.status?.irregularPulseDetected, false);
    expect(result.status?.pulseRateInRange, true);
    expect(result.status?.pulseRateExceedsUpperLimit, false);
    expect(result.status?.pulseRateIsLessThenLowerLimit, false);
    expect(result.status?.improperMeasurementPosition, false);
  });

  test('decodes the measurement status flags', () {
    // Status byte 39 => 0010 0111: body movement, cuff too loose, irregular
    // pulse and an improper measurement position.
    final result = BleMeasurementData.decode(Uint8List.fromList(
        [22, 124, 0, 86, 0, 97, 0, 232, 7, 6, 15, 17, 17, 27, 51, 0, 39, 0]));

    expect(result, isNotNull);
    expect(result!.status?.bodyMovementDetected, true);
    expect(result.status?.cuffTooLose, true);
    expect(result.status?.irregularPulseDetected, true);
    expect(result.status?.improperMeasurementPosition, true);
    expect(result.status?.pulseRateInRange, true);
  });

  test('decodes the pulse rate range from the status flags', () {
    // Bits 3 and 4 hold the range: 1 => above, 2 => below the limit.
    final above = BleMeasurementData.decode(Uint8List.fromList(
        [22, 124, 0, 86, 0, 97, 0, 232, 7, 6, 15, 17, 17, 27, 51, 0, 8, 0]));
    final below = BleMeasurementData.decode(Uint8List.fromList(
        [22, 124, 0, 86, 0, 97, 0, 232, 7, 6, 15, 17, 17, 27, 51, 0, 16, 0]));

    expect(above?.status?.pulseRateExceedsUpperLimit, true);
    expect(above?.status?.pulseRateIsLessThenLowerLimit, false);
    expect(above?.status?.pulseRateInRange, false);

    expect(below?.status?.pulseRateIsLessThenLowerLimit, true);
    expect(below?.status?.pulseRateExceedsUpperLimit, false);
    expect(below?.status?.pulseRateInRange, false);
  });

  test('decodes beurer sample data', () {
    // Recorded from a Beurer BM85.
    final result = BleMeasurementData.decode(Uint8List.fromList(
        [86, 106, 0, 71, 0, 0, 0, 234, 7, 8, 11, 18, 31, 0, 0, 63, 0, 0, 0]),
        bigEndian: true, alwaysSendsUserId: true);

    expect(result, isNotNull);
    expect(result!.systolic, 106.0);
    expect(result.diastolic, 71.0);
    expect(result.isMMHG, true);
    expect(result.pulse, 63.0);
    expect(result.userID, 0);
    expect(result.timestamp, DateTime(2026, 08, 11, 18, 31));
  });

  test('decodes beurer sample data of the second user', () {
    final result = BleMeasurementData.decode(Uint8List.fromList(
        [86, 113, 0, 73, 0, 0, 0, 234, 7, 8, 11, 20, 56, 0, 0, 65, 1, 0, 0]),
        bigEndian: true, alwaysSendsUserId: true);

    expect(result, isNotNull);
    expect(result!.systolic, 113.0);
    expect(result.diastolic, 73.0);
    expect(result.pulse, 65.0);
    expect(result.userID, 1);
    expect(result.timestamp, DateTime(2026, 08, 11, 20, 56));
  });

  test('decodes beurer sample data of the second user with a high pulse', () {
    final result = BleMeasurementData.decode(Uint8List.fromList(
        [86, 119, 0, 70, 0, 0, 0, 234, 7, 8, 11, 20, 57, 0, 0, 87, 1, 0, 64]),
        bigEndian: true, alwaysSendsUserId: true);

    expect(result, isNotNull);
    expect(result!.systolic, 119.0);
    expect(result.diastolic, 70.0);
    expect(result.pulse, 87.0);
    expect(result.userID, 1);
    expect(result.timestamp, DateTime(2026, 08, 11, 20, 57));
  });
}
