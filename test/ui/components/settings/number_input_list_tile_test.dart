import 'package:blood_pressure_app/components/dialoges/input_dialoge.dart';
import 'package:blood_pressure_app/components/settings/number_input_list_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../util.dart';

void main() {
  testWidgets('should show fields', (tester) async {
    await tester.pumpWidget(materialApp(NumberInputListTile(
      label: 'test title',
      value: 15,
      onParsableSubmit: (double newValue) {
        assert(false, 'should not be called');
      },
    ),),);
    expect(tester.takeException(), isNull);
    expect(find.text('test title'), findsOneWidget);
    expect(find.text('15'), findsOneWidget);
  });
  testWidgets('should allow canceling edit', (tester) async {
    await tester.pumpWidget(materialApp(NumberInputListTile(
      label: 'test title',
      value: 15,
      onParsableSubmit: (double newValue) {
        assert(false, 'should not be called');
      },
    ),),);

    expect(find.byType(InputDialoge), findsNothing);
    await tester.tap(find.byType(NumberInputListTile));
    await tester.pumpAndSettle();

    expect(find.byType(InputDialoge), findsOneWidget);
    await tester.tapAt(const Offset(0, 0));
    await tester.pumpAndSettle();

    expect(find.byType(InputDialoge), findsNothing);
  });
  testWidgets('should prefill value on edit', (tester) async {
    await tester.pumpWidget(materialApp(NumberInputListTile(
      label: 'test title',
      value: 15,
      onParsableSubmit: (double newValue) {
        assert(false, 'should not be called');
      },
    ),),);

    expect(find.text('15'), findsOneWidget);
    await tester.tap(find.byType(NumberInputListTile));
    await tester.pumpAndSettle();

    expect(find.text('15'), findsNWidgets(2));
  });
  testWidgets('should allow editing values', (tester) async {
    int callCount = 0;
    await tester.pumpWidget(materialApp(NumberInputListTile(
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
    await tester.tap(find.byType(NumberInputListTile));
    await tester.pumpAndSettle();
    expect(find.byType(TextField), findsOneWidget);
    await tester.enterText(find.byType(TextField), '17');
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(NumberInputListTile));
    await tester.pumpAndSettle();
    expect(find.byType(TextField), findsOneWidget);
    await tester.enterText(find.byType(TextField), '15.0');
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(NumberInputListTile));
    await tester.pumpAndSettle();
    expect(find.byType(TextField), findsOneWidget);
    await tester.enterText(find.byType(TextField), '0.123');
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(NumberInputListTile));
    await tester.pumpAndSettle();
    expect(find.byType(TextField), findsOneWidget);
    await tester.enterText(find.byType(TextField), '5.4');
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    expect(find.byType(InputDialoge), findsNothing);
    expect(callCount, 4);
  });
}
