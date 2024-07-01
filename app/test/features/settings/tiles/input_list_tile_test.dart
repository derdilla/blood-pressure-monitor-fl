import 'package:blood_pressure_app/components/input_dialoge.dart';
import 'package:blood_pressure_app/features/settings/tiles/input_list_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../util.dart';

void main() {
  testWidgets('should show fields', (tester) async {
    await tester.pumpWidget(materialApp(InputListTile(
      label: 'test title',
      value: 'initial',
      onSubmit: (String newValue) {
        assert(false, 'should not be called');
      },
    ),),);
    expect(tester.takeException(), isNull);
    expect(find.text('test title'), findsOneWidget);
    expect(find.text('initial'), findsOneWidget);
  });
  testWidgets('should allow canceling edit', (tester) async {
    await tester.pumpWidget(materialApp(InputListTile(
      label: 'test title',
      value: 'initial',
      onSubmit: (String newValue) {
        assert(false, 'should not be called');
      },
    ),),);

    expect(find.byType(InputDialoge), findsNothing);
    await tester.tap(find.byType(InputListTile));
    await tester.pumpAndSettle();

    expect(find.byType(InputDialoge), findsOneWidget);
    await tester.tapAt(const Offset(0, 0));
    await tester.pumpAndSettle();

    expect(find.byType(InputDialoge), findsNothing);
  });
  testWidgets('should prefill value on edit', (tester) async {
    await tester.pumpWidget(materialApp(InputListTile(
      label: 'test title',
      value: 'initial',
      onSubmit: (String newValue) {
        assert(false, 'should not be called');
      },
    ),),);

    expect(find.text('initial'), findsOneWidget);
    await tester.tap(find.byType(InputListTile));
    await tester.pumpAndSettle();

    expect(find.text('initial'), findsNWidgets(2));
  });
  testWidgets('should allow editing values', (tester) async {
    int callCount = 0;
    await tester.pumpWidget(materialApp(InputListTile(
      label: 'test title',
      value: 'initial',
      onSubmit: (String newValue) {
        callCount += 1;
        expect(newValue, 'changed');
      },
    ),),);

    expect(find.text('initial'), findsOneWidget);
    await tester.tap(find.byType(InputListTile));
    await tester.pumpAndSettle();

    expect(find.byType(TextField), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'changed');
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    expect(find.byType(InputDialoge), findsNothing);
    expect(callCount, 1);
  });
}
