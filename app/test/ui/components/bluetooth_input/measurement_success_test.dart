
import 'package:blood_pressure_app/bluetooth/characteristics/ble_measurement_data.dart';
import 'package:blood_pressure_app/bluetooth/characteristics/ble_measurement_status.dart';
import 'package:blood_pressure_app/components/bluetooth_input/measurement_success.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import '../util.dart';


void main() {
  testWidgets('should show everything and be interactive', (WidgetTester tester) async {
    int tapCount = 0;
    await tester.pumpWidget(materialApp(MeasurementSuccess(
      onTap: () => tapCount++,
      data: BleMeasurementData(
        systolic: 123,
        diastolic: 456,
        pulse: 67,
        meanArterialPressure: 123,
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
        timestamp: DateTime.now(),
      ),
    )));
    // TODO

    expect(find.byIcon(Icons.done), findsOneWidget);
    expect(find.byIcon(Icons.close), findsOneWidget);
    final localizations = await AppLocalizations.delegate.load(const Locale('en'));
    expect(find.text(localizations.measurementSuccess), findsOneWidget);

    expect(tapCount, 0);
    await tester.tap(find.text(localizations.measurementSuccess));
    await tester.pump();
    expect(tapCount, 1);
    await tester.tap(find.byIcon(Icons.close));
    await tester.pump();
    expect(tapCount, 2);
  });
  // TODO: works when not everything shown
}
