import 'package:blood_pressure_app/bluetooth/characteristics/ble_measurement_data.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('decodes sample data', () {
    // 22 => 0001 0110
    final result = BleMeasurementData.decode([22, 124, 0, 86, 0, 97, 0, 232, 7, 6, 15, 17, 17, 27, 51, 0, 0, 0], 0);

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
}
