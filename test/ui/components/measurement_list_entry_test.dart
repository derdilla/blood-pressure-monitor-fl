import 'package:blood_pressure_app/components/measurement_list/measurement_list_entry.dart';
import 'package:blood_pressure_app/model/blood_pressure.dart';
import 'package:blood_pressure_app/model/ram_only_implementations.dart';
import 'package:blood_pressure_app/model/storage/intervall_store.dart';
import 'package:blood_pressure_app/model/storage/settings_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

void main() {
  group('MeasurementListRow', () {
    testWidgets('should initialize without errors', (widgetTester) async {
      await widgetTester.pumpWidget(_materialApp(MeasurementListRow(
          record: BloodPressureRecord(DateTime(2023), 123, 80, 60, 'test'))));
      expect(widgetTester.takeException(), isNull);
      await widgetTester.pumpWidget(_materialApp(MeasurementListRow(
          record: BloodPressureRecord(DateTime.fromMillisecondsSinceEpoch(31279811), null, null, null, 'null test'))));
      expect(widgetTester.takeException(), isNull);
      await widgetTester.pumpWidget(_materialApp(MeasurementListRow(
          record: BloodPressureRecord(DateTime(2023), 124, 85, 63, 'color', needlePin: const MeasurementNeedlePin(Colors.cyan)))));
      expect(widgetTester.takeException(), isNull);
    });
    testWidgets('should expand correctly', (widgetTester) async {
      await widgetTester.pumpWidget(_materialApp(MeasurementListRow(
          record: BloodPressureRecord(DateTime(2023), 123, 78, 56, 'Test texts'))));
      expect(find.byIcon(Icons.expand_more), findsOneWidget);
      await widgetTester.tap(find.byIcon(Icons.expand_more));
      await widgetTester.pumpAndSettle();
      expect(find.text('Timestamp'), findsOneWidget);
      expect(find.byIcon(Icons.edit), findsOneWidget);
      expect(find.byIcon(Icons.delete), findsOneWidget);
    });
    testWidgets('should display correct information', (widgetTester) async {
      await widgetTester.pumpWidget(_materialApp(MeasurementListRow(
          record: BloodPressureRecord(DateTime(2023), 123, 78, 56, 'Test text'))));
      expect(find.text('123'), findsOneWidget);
      expect(find.text('78'), findsOneWidget);
      expect(find.text('56'), findsOneWidget);
      expect(find.textContaining('2023'), findsNothing);
      expect(find.text('Test text'), findsNothing);

      expect(find.byIcon(Icons.expand_more), findsOneWidget);
      await widgetTester.tap(find.byIcon(Icons.expand_more));
      await widgetTester.pumpAndSettle();

      expect(find.text('Test text'), findsOneWidget);
      expect(find.textContaining('2023'), findsOneWidget);
    });
    testWidgets('should not display null values', (widgetTester) async {
      await widgetTester.pumpWidget(_materialApp(MeasurementListRow(
          record: BloodPressureRecord(DateTime(2023), null, null, null, ''))));
      expect(find.text('null'), findsNothing);
      expect(find.byIcon(Icons.expand_more), findsOneWidget);
      await widgetTester.tap(find.byIcon(Icons.expand_more));
      await widgetTester.pumpAndSettle();
      expect(find.text('null'), findsNothing);
    });
  });
}

Widget _materialApp(Widget child) {
  return MaterialApp(
    home: Localizations(
      delegates: AppLocalizations.localizationsDelegates,
      locale: const Locale('en'),
      child: MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => Settings()),
            ChangeNotifierProvider(create: (_) => IntervallStoreManager(IntervallStorage(), IntervallStorage(), IntervallStorage())),
            ChangeNotifierProvider<BloodPressureModel>(create: (_) => RamBloodPressureModel()),
          ],
          child: Localizations(
            delegates: AppLocalizations.localizationsDelegates,
            locale: const Locale('en'),
            child: Scaffold(body: child),
          ),
      )
    ),
  );
}