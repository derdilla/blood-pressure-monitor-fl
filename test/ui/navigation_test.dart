import 'package:blood_pressure_app/main.dart';
import 'package:blood_pressure_app/model/blood_pressure.dart';
import 'package:blood_pressure_app/model/ram_only_implementations.dart';
import 'package:blood_pressure_app/model/settings_store.dart';
import 'package:blood_pressure_app/screens/add_measurement.dart';
import 'package:blood_pressure_app/screens/settings.dart';
import 'package:blood_pressure_app/screens/statistics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:mockito/mockito.dart';

class MockNavigatorObserver extends Mock implements NavigatorObserver {}

void main() {
  group('navigation', () {
    testWidgets('should navigate to measurements page', (widgetTester) async {
      await _pumpAppRoot(widgetTester);
      expect(find.byIcon(Icons.add), findsOneWidget);
      await widgetTester.tap(find.byIcon(Icons.add));
      await widgetTester.pumpAndSettle();

      expect(find.byType(AddMeasurementPage), findsOneWidget);
    });
    testWidgets('should navigate to settings page', (widgetTester) async {
      await _pumpAppRoot(widgetTester);
      expect(find.byIcon(Icons.settings), findsOneWidget);
      await widgetTester.tap(find.byIcon(Icons.settings));
      await widgetTester.pumpAndSettle();

      expect(find.byType(SettingsPage), findsOneWidget);
    });
    testWidgets('should navigate to stats page', (widgetTester) async {
      await _pumpAppRoot(widgetTester);
      expect(find.byIcon(Icons.insights), findsOneWidget);
      await widgetTester.tap(find.byIcon(Icons.insights));
      await widgetTester.pumpAndSettle();

      expect(find.byType(StatisticsPage), findsOneWidget);
    });
  });
}

Future<void> _pumpAppRoot(WidgetTester widgetTester) async {
  final model = RamBloodPressureModel();
  final settings = RamSettings();

  await widgetTester.pumpWidget(
      MultiProvider(
          providers: [
            ChangeNotifierProvider<Settings>(create: (_) => settings),
            ChangeNotifierProvider<BloodPressureModel>(create: (_) => model),
          ],
          child: const AppRoot()
      )
  );
}