import 'package:blood_pressure_app/components/dialoges/input_dialoge.dart';
import 'package:blood_pressure_app/components/settings/number_input_list_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../util.dart';

void main() {
  testWidgets('should show fields', (widgetTester) async {
    await widgetTester.pumpWidget(materialApp(NumberInputListTile(
      label: 'test title',
      value: 15,
      onParsableSubmit: (double newValue) {
        assert(false, 'should not be called');
      },
    ),),);
    expect(widgetTester.takeException(), isNull);
    expect(find.text('test title'), findsOneWidget);
    expect(find.text('15'), findsOneWidget);
  });
  testWidgets('should allow canceling edit', (widgetTester) async {
    await widgetTester.pumpWidget(materialApp(NumberInputListTile(
      label: 'test title',
      value: 15,
      onParsableSubmit: (double newValue) {
        assert(false, 'should not be called');
      },
    ),),);

    expect(find.byType(InputDialoge), findsNothing);
    await widgetTester.tap(find.byType(NumberInputListTile));
    await widgetTester.pumpAndSettle();

    expect(find.byType(InputDialoge), findsOneWidget);
    await widgetTester.tapAt(const Offset(0, 0));
    await widgetTester.pumpAndSettle();

    expect(find.byType(InputDialoge), findsNothing);
  });
  testWidgets('should prefill value on edit', (widgetTester) async {
    await widgetTester.pumpWidget(materialApp(NumberInputListTile(
      label: 'test title',
      value: 15,
      onParsableSubmit: (double newValue) {
        assert(false, 'should not be called');
      },
    ),),);

    expect(find.text('15'), findsOneWidget);
    await widgetTester.tap(find.byType(NumberInputListTile));
    await widgetTester.pumpAndSettle();

    expect(find.text('15'), findsNWidgets(2));
  });
  testWidgets('should allow editing values', (widgetTester) async {
    int callCount = 0;
    await widgetTester.pumpWidget(materialApp(NumberInputListTile(
      label: 'test title',
      value: 15,
      onParsableSubmit: (double newValue) {
        callCount += 1;
        switch (callCount) {
          case 1:
            expect(newValue, 17.0);
            break;
          case 2:
            expect(newValue, 15.0);
            break;
          case 3:
            expect(newValue, 0.123);
            break;
          case 4:
            expect(newValue, 5.4);
            break;
        }
      },
    ),),);

    expect(find.text('15'), findsOneWidget);
    await widgetTester.tap(find.byType(NumberInputListTile));
    await widgetTester.pumpAndSettle();
    expect(find.byType(TextField), findsOneWidget);
    await widgetTester.enterText(find.byType(TextField), '17');
    await widgetTester.tap(find.text('OK'));
    await widgetTester.pumpAndSettle();

    await widgetTester.tap(find.byType(NumberInputListTile));
    await widgetTester.pumpAndSettle();
    expect(find.byType(TextField), findsOneWidget);
    await widgetTester.enterText(find.byType(TextField), '15.0');
    await widgetTester.tap(find.text('OK'));
    await widgetTester.pumpAndSettle();

    await widgetTester.tap(find.byType(NumberInputListTile));
    await widgetTester.pumpAndSettle();
    expect(find.byType(TextField), findsOneWidget);
    await widgetTester.enterText(find.byType(TextField), '0.123');
    await widgetTester.tap(find.text('OK'));
    await widgetTester.pumpAndSettle();

    await widgetTester.tap(find.byType(NumberInputListTile));
    await widgetTester.pumpAndSettle();
    expect(find.byType(TextField), findsOneWidget);
    await widgetTester.enterText(find.byType(TextField), '5.4');
    await widgetTester.tap(find.text('OK'));
    await widgetTester.pumpAndSettle();

    expect(find.byType(InputDialoge), findsNothing);
    expect(callCount, 4);
  });
}
