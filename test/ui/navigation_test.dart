import 'package:blood_pressure_app/main.dart';
import 'package:blood_pressure_app/model/blood_pressure.dart';
import 'package:blood_pressure_app/model/ram_only_implementations.dart';
import 'package:blood_pressure_app/model/settings_store.dart';
import 'package:blood_pressure_app/screens/add_measurement.dart';
import 'package:blood_pressure_app/screens/settings.dart';
import 'package:blood_pressure_app/screens/statistics.dart';
import 'package:blood_pressure_app/screens/subsettings/enter_timeformat.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:mockito/mockito.dart';

class MockNavigatorObserver extends Mock implements NavigatorObserver {}

void main() {
  group('start page', () {
    testWidgets('should navigate to add measurements page', (widgetTester) async {
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
  group('add measurement page', () {
    testWidgets('should cancel', (widgetTester) async {
      await _pumpAppRoot(widgetTester);
      expect(find.byIcon(Icons.add), findsOneWidget);
      await widgetTester.tap(find.byIcon(Icons.add));
      await widgetTester.pumpAndSettle();

      expect(find.byType(AddMeasurementPage), findsOneWidget);
      expect(find.byKey(const Key('btnCancel')), findsOneWidget);

      await widgetTester.tap(find.byKey(const Key('btnCancel')));
      await widgetTester.pumpAndSettle();
      expect(find.byType(AddMeasurementPage), findsNothing);
    });
    testWidgets('should submit', (widgetTester) async {
      await _pumpAppRoot(widgetTester);
      await _addMeasurementThroughPage(widgetTester, 100, 70, 60);

      expect(find.byType(AddMeasurementPage), findsNothing);
    });
  });
  group('settings page', () {
    testWidgets('open EnterTimeFormatScreen', (widgetTester) async {
      await _pumpAppRoot(widgetTester);
      expect(find.byIcon(Icons.settings), findsOneWidget);
      await widgetTester.tap(find.byIcon(Icons.settings));
      await widgetTester.pumpAndSettle();

      expect(find.byType(SettingsPage), findsOneWidget);
      expect(find.byType(EnterTimeFormatScreen), findsNothing);
      expect(find.byKey(const Key('EnterTimeFormatScreen')), findsOneWidget);
      await widgetTester.tap(find.byKey(const Key('EnterTimeFormatScreen')));
      await widgetTester.pumpAndSettle();

      expect(find.byType(EnterTimeFormatScreen), findsOneWidget);
    });
    // ...
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

// starts at AppRoot, ends at AppRoot
Future<void> _addMeasurementThroughPage(WidgetTester widgetTester, int sys, int dia, int pul) async {
  expect(find.byType(AppRoot), findsOneWidget);
  expect(find.byIcon(Icons.add), findsOneWidget);
  await widgetTester.tap(find.byIcon(Icons.add));
  await widgetTester.pumpAndSettle();
  
  expect(find.byType(AddMeasurementPage), findsOneWidget);

  expect(find.byKey(const Key('txtSys')), findsOneWidget);
  expect(find.byKey(const Key('txtDia')), findsOneWidget);
  expect(find.byKey(const Key('txtPul')), findsOneWidget);
  expect(find.byKey(const Key('btnSave')), findsOneWidget);

  await widgetTester.enterText(find.byKey(const Key('txtSys')), sys.toString());
  await widgetTester.enterText(find.byKey(const Key('txtDia')), dia.toString());
  await widgetTester.enterText(find.byKey(const Key('txtPul')), pul.toString());

  await widgetTester.tap(find.byKey(const Key('btnSave')));
  await widgetTester.pumpAndSettle();
}