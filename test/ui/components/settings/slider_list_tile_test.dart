import 'package:blood_pressure_app/components/settings/slider_list_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SliderListTile', () {
    testWidgets('should not throw without errors', (widgetTester) async {
      await widgetTester.pumpWidget(_materialApp(SliderListTile(
        title: const Text('test title'),
        onChanged: (double newValue) {  },
        value: 15,
        min: 1,
        max: 20,
      )));
      await widgetTester.pumpWidget(_materialApp(SliderListTile(
        title: const Text('Very long title that could overflow'),
        onChanged: (double newValue) {  },
        value: 15,
        min: 1,
        max: 20,
        stepSize: 0.001,
        leading: const Icon(Icons.add),
        trailing: const Icon(Icons.add),
      )));
    });
    testWidgets('should report value changes', (widgetTester) async {
      int callCount = 0;
      await widgetTester.pumpWidget(_materialApp(SliderListTile(
        title: const Text('title'),
        onChanged: (double newValue) {
          callCount += 1;
          expect(newValue, 8);
        },
        value: 3,
        min: 1,
        max: 10,
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

Widget _materialApp(Widget child) {
  return MaterialApp(
    home: Scaffold(body: child),
  );
}