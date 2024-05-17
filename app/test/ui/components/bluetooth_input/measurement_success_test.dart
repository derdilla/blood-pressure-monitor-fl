
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
    )));

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
}
