import 'package:blood_pressure_app/features/settings/tiles/titled_column.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../util.dart';

void main() {
  testWidgets('should show title and widgets', (tester) async {
    await tester.pumpWidget(materialApp(TitledColumn(
      title: const Text('test title'),
      children: [
        const ListTile(title: Text('ListTile text 1'),),
        SwitchListTile(
            title: const Text('SwitchListTile text'),
            value: true, onChanged: (v) {},),
        const ListTile(title: Text('ListTile text 2'),),
      ],
    ),),);
    expect(tester.takeException(), isNull);

    expect(find.text('test title'), findsOneWidget);
    expect(find.text('ListTile text 1'), findsOneWidget);
    expect(find.text('SwitchListTile text'), findsOneWidget);
    expect(find.text('ListTile text 2'), findsOneWidget);
  });
  testWidgets('should show title first', (tester) async {
    await tester.pumpWidget(materialApp(TitledColumn(
      title: const Text('test title'),
      children: [
        const ListTile(title: Text('ListTile text 1'),),
        SwitchListTile(
            title: const Text('SwitchListTile text'),
            value: true, onChanged: (v) {},),
        const ListTile(title: Text('ListTile text 2'),),
      ],
    ),),);

    expect(find.byType(Column), findsOneWidget);
    expect(find.descendant(
        of: find.byType(Column).first,
        matching: find.text('test title'),),
      findsOneWidget,
    );
  });
}
