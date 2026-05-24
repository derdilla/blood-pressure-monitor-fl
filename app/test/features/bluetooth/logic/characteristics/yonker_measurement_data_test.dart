import 'dart:typed_data';

import 'package:blood_pressure_app/features/bluetooth/logic/characteristics/yonker_measurement_data.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('decodes sample data', () {
    final result = YonkerMeasurementData.decode(Uint8List.fromList([0x81, 0x83, 0x67, 0x51, 0, 0, 0x19, 0x0B, 0x18, 0x13, 0x12, 0, 0, 0, 0]));

    expect(result, isNotNull);
    expect(result!.systolic, 131);
    expect(result.diastolic, 103);
    expect(result.pulse, 81);
    expect(result.timestamp, DateTime(2024, 11, 25, 19, 18));
  });

  test('rejects bad flag', () {
    final result = YonkerMeasurementData.decode(Uint8List.fromList([0x82, 0x83, 0x67, 0x51, 0, 0, 0x19, 0x0B, 0x18, 0x13, 0x12, 0, 0, 0, 0]));
    expect(result, isNull);
  });
  test('rejects bad length', () {
    final result = YonkerMeasurementData.decode(Uint8List.fromList([0x81, 0x83, 0x67, 0x51, 0, 0, 0x19, 0x0B, 0x18, 0x13]));
    expect(result, isNull);
  });
}
