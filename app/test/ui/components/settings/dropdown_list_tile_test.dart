import 'package:blood_pressure_app/features/settings/tiles/dropdown_list_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../util.dart';

void main() {
  testWidgets('should not throw errors', (tester) async {
    await tester.pumpWidget(materialApp(DropDownListTile<int>(
      title: const Text('test title'),
      onChanged: (int? newValue) {
        assert(false, 'should not be called');
      },
      items: [
        for (int i = 0; i < 10; i++)
          DropdownMenuItem(value: i, child: Text('option $i')),
      ],
      value: 3,
    ),),);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(materialApp(DropDownListTile<int>(
      title: const Text('This is a very long test title.'),
      subtitle: const Text('This is a very long test subtitle that should go over multiple lines.'),
      leading: const Icon(Icons.add),
      onChanged: (int? newValue) {
        assert(false, 'should not be called');
      },
      items: [
        for (int i = 0; i < 1000; i++)
          DropdownMenuItem(value: i, child: Text('option $i')),
      ],
      value: 527,
    ),),);
    expect(tester.takeException(), isNull);
  });
  testWidgets('should display selected option', (tester) async {
    await tester.pumpWidget(materialApp(DropDownListTile<int>(
      title: const Text('test title'),
      onChanged: (int? newValue) {
        assert(false, 'should not be called');
      },
      items: [
        for (int i = 0; i < 10; i++)
          DropdownMenuItem(value: i, child: Text('option $i')),
      ],
      value: 3,
    ),),);
    expect(find.text('option 3'), findsOneWidget);
    expect(find.text('option 4'), findsNothing);
  });
  testWidgets('should call onChanged on option selected', (tester) async {
    int callCount = 0;
    await tester.pumpWidget(materialApp(DropDownListTile<int>(
      title: const Text('test title'),
      onChanged: (int? newValue) {
        callCount += 1;
        expect(newValue, 5);
      },
      items: [
        for (int i = 0; i < 10; i++)
          DropdownMenuItem(value: i, child: Text('option $i')),
      ],
      value: 3,
    ),),);

    await tester.tap(find.text('option 3'));
    await tester.pumpAndSettle();

    expect(find.text('option 5'), findsOneWidget);
    await tester.tap(find.text('option 5'));
    await tester.pumpAndSettle();

    expect(callCount, 1);
  });
}
