import 'package:blood_pressure_app/components/dialoges/add_measurement_dialoge.dart';
import 'package:blood_pressure_app/components/measurement_list/measurement_list_entry.dart';
import 'package:blood_pressure_app/model/storage/settings_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../model/export_import/record_formatter_test.dart';
import 'util.dart';

void main() {
  testWidgets('should initialize without errors', (tester) async {
    await tester.pumpWidget(materialApp(MeasurementListRow(
      settings: Settings(),
      record: mockEntryPos(DateTime(2023), 123, 80, 60, 'test'),),),);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(materialApp(MeasurementListRow(
      settings: Settings(),
      record: mockEntryPos(DateTime.fromMillisecondsSinceEpoch(31279811), null, null, null, 'null test'),),),);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(materialApp(MeasurementListRow(
      settings: Settings(),
      record: mockEntryPos(DateTime(2023), 124, 85, 63, 'color',Colors.cyan))));
    expect(tester.takeException(), isNull);
  });
  testWidgets('should expand correctly', (tester) async {
    await tester.pumpWidget(materialApp(MeasurementListRow(
        settings: Settings(),
        record: mockEntryPos(DateTime(2023), 123, 78, 56, 'Test texts'),),),);
    expect(find.byIcon(Icons.expand_more), findsOneWidget);
    await tester.tap(find.byIcon(Icons.expand_more));
    await tester.pumpAndSettle();
    expect(find.text('Timestamp'), findsOneWidget);
    expect(find.byIcon(Icons.edit), findsOneWidget);
    expect(find.byIcon(Icons.delete), findsOneWidget);
  });
  testWidgets('should display correct information', (tester) async {
    await tester.pumpWidget(materialApp(MeasurementListRow(
        settings: Settings(),
        record: mockEntryPos(DateTime(2023), 123, 78, 56, 'Test text'),),),);
    expect(find.text('123'), findsOneWidget);
    expect(find.text('78'), findsOneWidget);
    expect(find.text('56'), findsOneWidget);
    expect(find.textContaining('2023'), findsNothing);
    expect(find.text('Test text'), findsNothing);

    expect(find.byIcon(Icons.expand_more), findsOneWidget);
    await tester.tap(find.byIcon(Icons.expand_more));
    await tester.pumpAndSettle();

    expect(find.text('Test text'), findsOneWidget);
    expect(find.textContaining('2023'), findsOneWidget);
  });
  testWidgets('should not display null values', (tester) async {
    await tester.pumpWidget(materialApp(MeasurementListRow(
      settings: Settings(), record: mockEntry(time: DateTime(2023)),),),);
    expect(find.text('null'), findsNothing);
    expect(find.byIcon(Icons.expand_more), findsOneWidget);
    await tester.tap(find.byIcon(Icons.expand_more));
    await tester.pumpAndSettle();
    expect(find.text('null'), findsNothing);
  });
  testWidgets('should open edit dialoge', (tester) async {
    await tester.pumpWidget(await appBase(MeasurementListRow(
      settings: Settings(), record: mockEntry(time: DateTime(2023),
        sys:1, dia: 2, pul: 3, note: 'testTxt',),),),);
    expect(find.byIcon(Icons.expand_more), findsOneWidget);
    await tester.tap(find.byIcon(Icons.expand_more));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.edit), findsOneWidget);
    await tester.tap(find.byIcon(Icons.edit));
    await tester.pumpAndSettle();

    /// Finder of text widgets that are descendants of the AddEntryDialoge.
    Finder descTxt(String txt) => find.descendant(
      of: find.byType(AddEntryDialoge),
      matching: find.text(txt),
    );

    expect(find.byType(AddEntryDialoge), findsOneWidget);
    expect(descTxt('testTxt'), findsOneWidget);
    expect(descTxt('1'), findsOneWidget);
    expect(descTxt('2'), findsOneWidget);
    expect(descTxt('3'), findsOneWidget);

  }, timeout: const Timeout(Duration(seconds: 10)),);
}
