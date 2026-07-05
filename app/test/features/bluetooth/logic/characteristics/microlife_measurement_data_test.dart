import 'dart:typed_data';

import 'package:blood_pressure_app/features/bluetooth/logic/characteristics/microlife_measurement_data.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  /// Builds a "get measurements" payload with [records] starting at the fixed
  /// 38 byte offset the device uses.
  Uint8List payloadWith(List<List<int>> records) => Uint8List.fromList([
    ...List.filled(38, 0),
    for (final record in records) ...record,
  ]);

  test('decodes multiple measurements', () {
    final result = MicrolifeMeasurementData.decodeMeasurements(payloadWith([
      [120, 80, 60, 24, 6, 15, 14, 30, 0, 0],
      [130, 85, 70, 25, 1, 2, 3, 4, 0, 0],
    ]));

    expect(result, hasLength(2));

    expect(result[0].systolicMmHg, 120);
    expect(result[0].diastolicMmHg, 80);
    expect(result[0].pulseBpm, 60);
    expect(result[0].timestamp, DateTime(2024, 6, 15, 14, 30));

    expect(result[1].systolicMmHg, 130);
    expect(result[1].diastolicMmHg, 85);
    expect(result[1].pulseBpm, 70);
    expect(result[1].timestamp, DateTime(2025, 1, 2, 3, 4));
  });

  test('converts to BleMeasurementData', () {
    final result = MicrolifeMeasurementData.decodeMeasurements(payloadWith([
      [120, 80, 60, 24, 6, 15, 14, 30, 0, 0],
    ]));

    final ble = result.single.asBleData;
    expect(ble.systolic, 120.0);
    expect(ble.diastolic, 80.0);
    expect(ble.pulse, 60.0);
    expect(ble.isMMHG, true);
    expect(ble.meanArterialPressure, closeTo(1 / 3 * 120 + 2 / 3 * 80, 0.001));
    expect(ble.timestamp, DateTime(2024, 6, 15, 14, 30));
  });

  test('skips empty record slots', () {
    final result = MicrolifeMeasurementData.decodeMeasurements(payloadWith([
      [120, 80, 60, 24, 6, 15, 14, 30, 0, 0],
      [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
    ]));

    expect(result, hasLength(1));
    expect(result.single.systolicMmHg, 120);
  });

  test('skips records with invalid dates', () {
    final result = MicrolifeMeasurementData.decodeMeasurements(payloadWith([
      [110, 70, 65, 24, 0, 15, 14, 30, 0, 0], // month 0 is invalid
    ]));

    expect(result, isEmpty);
  });

  test('returns empty list when there are no records', () {
    final result = MicrolifeMeasurementData.decodeMeasurements(
        Uint8List.fromList(List.filled(38, 0)));
    expect(result, isEmpty);
  });
}
