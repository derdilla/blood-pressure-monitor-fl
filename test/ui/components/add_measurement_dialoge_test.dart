import 'package:blood_pressure_app/components/dialoges/add_measurement.dart';
import 'package:blood_pressure_app/model/blood_pressure.dart';
import 'package:blood_pressure_app/model/storage/settings_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AddMeasurementDialoge', () {
    testWidgets('should show everything on initial page', (widgetTester) async {
      await widgetTester.pumpWidget(_materialApp(
        AddMeasurementDialoge(
          settings: Settings(),
        )
      ));
      expect(find.text('SAVE'), findsOneWidget);
      expect(find.byIcon(Icons.close), findsOneWidget);
      expect(find.text('Systolic'), findsAny);
      expect(find.text('Diastolic'), findsAny);
      expect(find.text('Pulse'), findsAny);
    });
    testWidgets('should prefill initialRecord values', (widgetTester) async {
      await widgetTester.pumpWidget(_materialApp(
          AddMeasurementDialoge(
            settings: Settings(),
            initialRecord: BloodPressureRecord(
              DateTime.now(), 123, 56, 43, 'Test note',
              needlePin: const MeasurementNeedlePin(Colors.teal)
            ),
          )
      ));
      await widgetTester.pumpAndSettle();
      expect(find.text('SAVE'), findsOneWidget);
      expect(find.byIcon(Icons.close), findsOneWidget);
      expect(find.text('Test note'), findsOneWidget);
      expect(find.text('123'), findsOneWidget);
      expect(find.text('56'), findsOneWidget);
      expect(find.text('43'), findsOneWidget);
    });
  });
  group('showAddMeasurementDialoge', () {
    testWidgets('should return null on cancel', (widgetTester) async {
      dynamic result = 'not null';
      await widgetTester.pumpWidget(_materialApp(
          Builder(
            builder: (BuildContext context) => TextButton(onPressed: () async {
              result = await showAddMeasurementDialoge(context, Settings(),
                  BloodPressureRecord(
                      DateTime.now(), 123, 56, 43, 'Test note',
                      needlePin: const MeasurementNeedlePin(Colors.teal)
                  ));
            }, child: const Text('TEST')),
      )));
      await widgetTester.tap(find.text('TEST'));
      await widgetTester.pumpAndSettle();

      expect(find.byType(AddMeasurementDialoge), findsOneWidget);
      await widgetTester.tap(find.byIcon(Icons.close));
      await widgetTester.pumpAndSettle();
      expect(find.byType(AddMeasurementDialoge), findsNothing);

      expect(result, null);
    });
    testWidgets('should return values on cancel', (widgetTester) async {
      dynamic result = 'not null';
      final record = BloodPressureRecord(
          DateTime.now(), 123, 56, 43, 'Test note',
          needlePin: const MeasurementNeedlePin(Colors.teal)
      );
      await widgetTester.pumpWidget(_materialApp(
          Builder(
            builder: (BuildContext context) => TextButton(onPressed: () async {
              result = await showAddMeasurementDialoge(context, Settings(), record);
            }, child: const Text('TEST')),
          )));
      await widgetTester.tap(find.text('TEST'));
      await widgetTester.pumpAndSettle();

      expect(find.byType(AddMeasurementDialoge), findsOneWidget);
      await widgetTester.tap(find.text('SAVE'));
      await widgetTester.pumpAndSettle();
      expect(find.byType(AddMeasurementDialoge), findsNothing);

      expect(result, isA<BloodPressureRecord>().having(
              (p0) => (p0.creationTime, p0.systolic, p0.diastolic, p0.pulse, p0.notes, p0.needlePin!.color),
          'should return initial values as they were not modified',
          (record.creationTime, record.systolic, record.diastolic, record.pulse, record.notes, record.needlePin!.color)));
    });
  });
}

Widget _materialApp(Widget child) {
  return MaterialApp(
    localizationsDelegates: const [AppLocalizations.delegate,],
    locale: const Locale('en'),
    home: Scaffold(body:child),
  );
}