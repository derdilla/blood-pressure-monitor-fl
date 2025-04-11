
import 'package:blood_pressure_app/features/bluetooth/ui/measurement_failure.dart';
import 'package:flutter/material.dart';
import 'package:blood_pressure_app/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../util.dart';


void main() {
  testWidgets('should show everything and be interactive', (WidgetTester tester) async {
    int tapCount = 0;
    await tester.pumpWidget(materialApp(MeasurementFailure(
      onTap: () => tapCount++,
      reason: '',
    )));

    expect(find.byIcon(Icons.error_outline), findsOneWidget);
    expect(find.byIcon(Icons.close), findsOneWidget);
    final localizations = await AppLocalizations.delegate.load(const Locale('en'));
    expect(find.text(localizations.errMeasurementRead), findsOneWidget);
    expect(find.text(localizations.tapToClose), findsOneWidget);

    expect(tapCount, 0);
    await tester.tap(find.text(localizations.tapToClose));
    await tester.pump();
    expect(tapCount, 1);
    await tester.tap(find.byIcon(Icons.close));
    await tester.pump();
    expect(tapCount, 2);
  });
}
