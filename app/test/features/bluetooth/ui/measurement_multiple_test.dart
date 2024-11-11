
import 'package:blood_pressure_app/features/bluetooth/logic/characteristics/ble_measurement_data.dart';
import 'package:blood_pressure_app/features/bluetooth/logic/characteristics/ble_measurement_status.dart';
import 'package:blood_pressure_app/features/bluetooth/ui/measurement_multiple.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../util.dart';


void main() {
  testWidgets('should show everything and be interactive', (WidgetTester tester) async {
    int tapCount = 0;
    final List<BleMeasurementData> selected = [];
    final measurements = [
      BleMeasurementData(
        systolic: 123,
        diastolic: 456,
        pulse: 67,
        meanArterialPressure: 123456,
        isMMHG: true,
        userID: 3,
        status: BleMeasurementStatus(
          bodyMovementDetected: true,
          cuffTooLose: true,
          irregularPulseDetected: true,
          pulseRateInRange: true,
          pulseRateExceedsUpperLimit: true,
          pulseRateIsLessThenLowerLimit: true,
          improperMeasurementPosition: true,
        ),
        timestamp: DateTime.now().subtract(const Duration(minutes: 1)),
      ),
      BleMeasurementData(
        systolic: 124,
        diastolic: 457,
        pulse: null,
        meanArterialPressure: 123457,
        isMMHG: true,
        userID: null,
        status: BleMeasurementStatus(
          bodyMovementDetected: true,
          cuffTooLose: true,
          irregularPulseDetected: true,
          pulseRateInRange: true,
          pulseRateExceedsUpperLimit: true,
          pulseRateIsLessThenLowerLimit: true,
          improperMeasurementPosition: true,
        ),
        timestamp: null,
      ),
    ];

    await tester.pumpWidget(materialApp(MeasurementMultiple(
      onClosed: () => tapCount++,
      onSelect: selected.add,
      measurements: measurements,
    )));

    final localizations = await AppLocalizations.delegate.load(const Locale('en'));
    expect(find.text(localizations.selectMeasurementTitle), findsOneWidget);
    expect(find.byIcon(Icons.close), findsOneWidget);

    expect(find.byType(ListTile), findsNWidgets(2));

    expect(find.textContaining(localizations.userID), findsOneWidget); // one measurement has UserID: null
    expect(find.textContaining(localizations.bloodPressure), findsNWidgets(2));
    for (final measurement in measurements) {
      expect(find.textContaining(measurement.systolic.toInt().toString()), findsOneWidget);
    }

    expect(find.text(localizations.measurementIndex(2)), findsOneWidget);
    expect(find.text(localizations.select), findsNWidgets(2));

    expect(selected, isEmpty);
    await tester.tap(find.text(localizations.select).first);
    expect(selected.length, 1);
    expect(selected, contains(measurements[0]));

    expect(tapCount, 0);
    await tester.tap(find.byIcon(Icons.close));
    await tester.pump();
    expect(tapCount, 1);
  });
}
