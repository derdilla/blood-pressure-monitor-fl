import 'package:blood_pressure_app/components/settings/slider_list_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../util.dart';

void main() {
  group('SliderListTile', () {
    testWidgets('should not throw errors', (widgetTester) async {
      await widgetTester.pumpWidget(materialApp(SliderListTile(
        title: const Text('test title'),
        onChanged: (double newValue) {
          assert(false, 'should not be called');
        },
        value: 15,
        min: 1,
        max: 20,
      )));
      expect(widgetTester.takeException(), isNull);
      await widgetTester.pumpWidget(materialApp(SliderListTile(
        title: const Text('Very long title that could overflow'),
        onChanged: (double newValue) {
          assert(false, 'should not be called');
        },
        value: 15,
        min: 1,
        max: 20,
        stepSize: 0.001,
        leading: const Icon(Icons.add),
        trailing: const Icon(Icons.add),
        subtitle: const Text('While sliders support subtitle widgets, they should not interfere with the slider!'),
      )));
      expect(widgetTester.takeException(), isNull);
    });
    testWidgets('should report value changes', (widgetTester) async {
      int callCount = 0;
      await widgetTester.pumpWidget(materialApp(SliderListTile(
        title: const Text('title'),
        onChanged: (double newValue) {
          callCount += 1;
          expect(newValue, 8);
        },
        value: 3,
        min: 1,
        max: 10,
        subtitle: const Text('While sliders support subtitle widgets, they should not interfere with the slider!'),
      )));

      final topLeft = widgetTester.getTopLeft(find.byType(Slider));
      final bottomRight = widgetTester.getBottomRight(find.byType(Slider));

      final slider8Position = topLeft + ((bottomRight - topLeft) * 8 / 10);
      await widgetTester.tapAt(slider8Position);
      await widgetTester.pumpAndSettle();
      expect(callCount, 1);
    });
  });
}