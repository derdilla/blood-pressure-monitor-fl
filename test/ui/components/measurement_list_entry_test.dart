import 'package:blood_pressure_app/components/measurement_list/measurement_list_entry.dart';
import 'package:blood_pressure_app/model/blood_pressure/needle_pin.dart';
import 'package:blood_pressure_app/model/blood_pressure/record.dart';
import 'package:blood_pressure_app/model/storage/settings_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../model/export_import/record_formatter_test.dart';
import 'util.dart';

void main() {
  group('MeasurementListRow', () {
    testWidgets('should initialize without errors', (widgetTester) async {
      await widgetTester.pumpWidget(materialApp(MeasurementListRow(
        settings: Settings(),
        record: BloodPressureRecord(DateTime(2023), 123, 80, 60, 'test'))));
      expect(widgetTester.takeException(), isNull);
      await widgetTester.pumpWidget(materialApp(MeasurementListRow(
        settings: Settings(),
        record: BloodPressureRecord(DateTime.fromMillisecondsSinceEpoch(31279811), null, null, null, 'null test'))));
      expect(widgetTester.takeException(), isNull);
      await widgetTester.pumpWidget(materialApp(MeasurementListRow(
        settings: Settings(),
        record: BloodPressureRecord(DateTime(2023), 124, 85, 63, 'color', needlePin: const MeasurementNeedlePin(Colors.cyan)))));
      expect(widgetTester.takeException(), isNull);
    });
    testWidgets('should expand correctly', (widgetTester) async {
      await widgetTester.pumpWidget(materialApp(MeasurementListRow(
          settings: Settings(),
          record: BloodPressureRecord(DateTime(2023), 123, 78, 56, 'Test texts'))));
      expect(find.byIcon(Icons.expand_more), findsOneWidget);
      await widgetTester.tap(find.byIcon(Icons.expand_more));
      await widgetTester.pumpAndSettle();
      expect(find.text('Timestamp'), findsOneWidget);
      expect(find.byIcon(Icons.edit), findsOneWidget);
      expect(find.byIcon(Icons.delete), findsOneWidget);
    });
    testWidgets('should display correct information', (widgetTester) async {
      await widgetTester.pumpWidget(materialApp(MeasurementListRow(
          settings: Settings(),
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
      await widgetTester.pumpWidget(materialApp(MeasurementListRow(
        settings: Settings(), record: mockRecord(time: DateTime(2023)))));
      expect(find.text('null'), findsNothing);
      expect(find.byIcon(Icons.expand_more), findsOneWidget);
      await widgetTester.tap(find.byIcon(Icons.expand_more));
      await widgetTester.pumpAndSettle();
      expect(find.text('null'), findsNothing);
    });
  });
}