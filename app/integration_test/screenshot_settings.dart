
import 'package:blood_pressure_app/app.dart';
import 'package:blood_pressure_app/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:blood_pressure_app/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'util.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('Screenshot settings', (WidgetTester tester) async {
    final localizations = await AppLocalizations.delegate.load(const Locale('en'));

    await tester.pumpWidget(App());
    await tester.pumpAndSettle();
    await tester.pumpUntil(() => find.byType(AppHome).hasFound);
    // home

    await tester.tap(find.byIcon(Icons.settings));
    await tester.pumpAndSettle();
    // settings

    await tester.dragFrom(
      tester.getCenter(find.text(localizations.animationSpeed)),
      tester.getCenter(find.text(localizations.animationSpeed)) - tester.getCenter(find.text(localizations.timeFormat))
    );
    await tester.pumpAndSettle();

    await binding.convertFlutterSurfaceToImage();
    await tester.pump();
    await binding.takeScreenshot('03-example_settings');

    await tester.scrollUntilVisible(find.text(localizations.exportImport, skipOffstage: false), 50.0);
    await tester.pumpAndSettle();
    await tester.tap(find.text(localizations.exportImport));
    await tester.pumpAndSettle();

    await binding.takeScreenshot('05-export_example');
  });
}
