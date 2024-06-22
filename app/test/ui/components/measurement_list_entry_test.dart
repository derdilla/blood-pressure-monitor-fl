import 'package:blood_pressure_app/components/measurement_list/measurement_list_entry.dart';
import 'package:blood_pressure_app/model/storage/settings_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../model/export_import/record_formatter_test.dart';
import 'util.dart';

void main() {
  testWidgets('should initialize without errors', (tester) async {
    await tester.pumpWidget(materialApp(MeasurementListRow(
      onRequestEdit: () => fail('should not request edit'),
      settings: Settings(),
      data: mockEntryPos(DateTime(2023), 123, 80, 60, 'test'),),),);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(materialApp(MeasurementListRow(
      onRequestEdit: () => fail('should not request edit'),
      settings: Settings(),
      data: mockEntryPos(DateTime.fromMillisecondsSinceEpoch(31279811), null, null, null, 'null test'),),),);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(materialApp(MeasurementListRow(
        onRequestEdit: () => fail('should not request edit'),
      settings: Settings(),
      data: mockEntryPos(DateTime(2023), 124, 85, 63, 'color',Colors.cyan))));
    expect(tester.takeException(), isNull);
  });
  testWidgets('should expand correctly', (tester) async {
    await tester.pumpWidget(materialApp(MeasurementListRow(
      onRequestEdit: () => fail('should not request edit'),
        settings: Settings(),
        data: mockEntryPos(DateTime(2023), 123, 78, 56),),),);
    expect(find.byIcon(Icons.expand_more), findsOneWidget);
    await tester.tap(find.byIcon(Icons.expand_more));
    await tester.pumpAndSettle();
    expect(find.text('Timestamp'), findsOneWidget);
    expect(find.byIcon(Icons.edit), findsOneWidget);
    expect(find.byIcon(Icons.delete), findsOneWidget);
  });
  testWidgets('should display correct information', (tester) async {
    await tester.pumpWidget(materialApp(MeasurementListRow(
        onRequestEdit: () => fail('should not request edit'),
        settings: Settings(),
        data: mockEntryPos(DateTime(2023), 123, 78, 56, 'Test text'),),),);
    expect(find.text('123'), findsOneWidget);
    expect(find.text('78'), findsOneWidget);
    expect(find.text('56'), findsOneWidget);
    expect(find.textContaining('2023'), findsNothing);
    expect(find.text('Test text'), findsNothing);
    expect(find.byIcon(Icons.edit), findsNothing);
    expect(find.byIcon(Icons.delete), findsNothing);

    expect(find.byIcon(Icons.expand_more), findsOneWidget);
    await tester.tap(find.byIcon(Icons.expand_more));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.edit), findsOneWidget);
    expect(find.byIcon(Icons.delete), findsOneWidget);
    expect(find.text('Timestamp'), findsOneWidget);
    expect(find.text('Note'), findsOneWidget);
    expect(find.text('Test text'), findsOneWidget);
    expect(find.textContaining('2023'), findsOneWidget);
  });
  testWidgets('should not display null values', (tester) async {
    await tester.pumpWidget(materialApp(MeasurementListRow(
      onRequestEdit: () => fail('should not request edit'),
      settings: Settings(), data: mockEntry(time: DateTime(2023)),),),);
    expect(find.text('null'), findsNothing);
    expect(find.byIcon(Icons.expand_more), findsOneWidget);
    await tester.tap(find.byIcon(Icons.expand_more));
    await tester.pumpAndSettle();
    expect(find.text('null'), findsNothing);
  });
  testWidgets('should propagate edit request', (tester) async {
    int requestCount = 0;
    await tester.pumpWidget(materialApp(MeasurementListRow(
      settings: Settings(),
      data: mockEntry(
        time: DateTime(2023),
        sys:1,
        dia: 2,
        pul: 3,
        note: 'testTxt',
      ),
      onRequestEdit: () => requestCount++,
    )));
    expect(find.byIcon(Icons.expand_more), findsOneWidget);
    await tester.tap(find.byIcon(Icons.expand_more));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.edit), findsOneWidget);
    await tester.tap(find.byIcon(Icons.edit));
    await tester.pumpAndSettle();

    expect(requestCount, 1);

    /* TODO: use somewhere else
    /// Finder of text widgets that are descendants of the AddEntryDialoge.
    Finder descTxt(String txt) => find.descendant(
      of: find.byType(AddEntryDialoge),
      matching: find.text(txt),
    );*/


  }, timeout: const Timeout(Duration(seconds: 10)),);
}
