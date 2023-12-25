import 'package:blood_pressure_app/components/settings/dropdown_list_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../util.dart';

void main() {
  group('DropDownListTile', () {
    testWidgets('should not throw errors', (widgetTester) async {
      await widgetTester.pumpWidget(materialApp(DropDownListTile<int>(
        title: const Text('test title'),
        onChanged: (int? newValue) {
          assert(false, 'should not be called');
        },
        items: [
          for (int i = 0; i < 10; i++)
            DropdownMenuItem(value: i, child: Text('option $i'))
        ],
        value: 3,
      )));
      expect(widgetTester.takeException(), isNull);
      await widgetTester.pumpWidget(materialApp(DropDownListTile<int>(
        title: const Text('This is a very long test title.'),
        subtitle: const Text('This is a very long test subtitle that should go over multiple lines.'),
        leading: const Icon(Icons.add),
        onChanged: (int? newValue) {
          assert(false, 'should not be called');
        },
        items: [
          for (int i = 0; i < 1000; i++)
            DropdownMenuItem(value: i, child: Text('option $i'))
        ],
        value: 527,
      )));
      expect(widgetTester.takeException(), isNull);
    });
    testWidgets('should display selected option', (widgetTester) async {
      await widgetTester.pumpWidget(materialApp(DropDownListTile<int>(
        title: const Text('test title'),
        onChanged: (int? newValue) {
          assert(false, 'should not be called');
        },
        items: [
          for (int i = 0; i < 10; i++)
            DropdownMenuItem(value: i, child: Text('option $i'))
        ],
        value: 3,
      )));
      expect(find.text('option 3'), findsOneWidget);
      expect(find.text('option 4'), findsNothing);
    });
    testWidgets('should call onChanged on option selected', (widgetTester) async {
      int callCount = 0;
      await widgetTester.pumpWidget(materialApp(DropDownListTile<int>(
        title: const Text('test title'),
        onChanged: (int? newValue) {
          callCount += 1;
          expect(newValue, 5);
        },
        items: [
          for (int i = 0; i < 10; i++)
            DropdownMenuItem(value: i, child: Text('option $i'))
        ],
        value: 3,
      )));

      await widgetTester.tap(find.text('option 3'));
      await widgetTester.pumpAndSettle();

      expect(find.text('option 5'), findsOneWidget);
      await widgetTester.tap(find.text('option 5'));
      await widgetTester.pumpAndSettle();

      expect(callCount, 1);
    });
  });
}