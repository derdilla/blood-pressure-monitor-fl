import 'package:blood_pressure_app/components/color_picker.dart';
import 'package:blood_pressure_app/features/settings/tiles/color_picker_list_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../util.dart';

void main() {
  testWidgets('should initialize without errors', (tester) async {
    await tester.pumpWidget(materialApp(ColorSelectionListTile(
      title: const Text('Test'),
      onMainColorChanged: (Color value) {
        assert(false, 'should not be called');
      },
      initialColor: Colors.teal,),),);
    expect(tester.takeException(), isNull);
  });
  testWidgets('should preview color', (tester) async {
    await tester.pumpWidget(materialApp(ColorSelectionListTile(
      title: const Text('Test'),
      onMainColorChanged: (Color value) {
        assert(false, 'should not be called');
      },
      initialColor: Colors.teal,),),);

    expect(find.byType(CircleAvatar), findsOneWidget);
    expect(tester.widget(find.byType(CircleAvatar)), isA<CircleAvatar>().having(
            (p0) => p0.backgroundColor, 'display color', Colors.teal,),);
  });
  testWidgets('should show colorPicker on tap', (tester) async {
    await tester.pumpWidget(materialApp(ColorSelectionListTile(
      title: const Text('Test'),
      onMainColorChanged: (Color value) {
        assert(false, 'should not be called');
      },
      initialColor: Colors.teal,),),);

    expect(find.byType(ColorPicker), findsNothing);
    await tester.tap(find.byType(ListTile));
    await tester.pumpAndSettle();
    expect(find.byType(ColorPicker), findsOneWidget);
  });
  testWidgets('should notify on color changed', (tester) async {
    int callCount = 0;
    await tester.pumpWidget(materialApp(ColorSelectionListTile(
      title: const Text('Test'),
      onMainColorChanged: (Color value) {
        callCount += 1;
        expect(value, Colors.red);
      },
      initialColor: Colors.teal,),),);

    expect(find.byType(ColorPicker), findsNothing);
    await tester.tap(find.byType(ListTile));
    await tester.pumpAndSettle();
    expect(find.byType(ColorPicker), findsOneWidget);

    await tester.tap(find.byElementPredicate(findColored(Colors.red)));
    await tester.pumpAndSettle();
    expect(find.byType(ColorPicker), findsNothing);

    expect(callCount, 1);
  });
  testWidgets('should hide color when transparent is selected', (tester) async {
    await tester.pumpWidget(materialApp(ColorSelectionListTile(
      title: const Text('Test'),
      onMainColorChanged: (Color value) {
        assert(false, 'should not be called');
      },
      initialColor: Colors.transparent,),),);

    expect(find.byType(CircleAvatar), findsNothing);
  });
}

/// Finds the widget with a specific color inside a [ColorPicker], when put into a [CommonFinders.byElementPredicate].
bool Function(Element e) findColored(Color color) => (e) =>
    e.widget is Container &&
      (e.widget as Container).decoration is BoxDecoration &&
        ((e.widget as Container).decoration as BoxDecoration).color == color;
