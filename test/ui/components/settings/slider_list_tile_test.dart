import 'package:blood_pressure_app/components/settings/slider_list_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../util.dart';

void main() {
  testWidgets('should not throw errors', (tester) async {
    await tester.pumpWidget(materialApp(SliderListTile(
      title: const Text('test title'),
      onChanged: (double newValue) {
        assert(false, 'should not be called');
      },
      value: 15,
      min: 1,
      max: 20,
    ),),);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(materialApp(SliderListTile(
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
    ),),);
    expect(tester.takeException(), isNull);
  });
  testWidgets('should report value changes', (tester) async {
    int callCount = 0;
    await tester.pumpWidget(materialApp(SliderListTile(
      title: const Text('title'),
      onChanged: (double newValue) {
        callCount += 1;
        expect(newValue, 8);
      },
      value: 3,
      min: 1,
      max: 10,
      subtitle: const Text('While sliders support subtitle widgets, they should not interfere with the slider!'),
    ),),);

    final topLeft = tester.getTopLeft(find.byType(Slider));
    final bottomRight = tester.getBottomRight(find.byType(Slider));

    final slider8Position = topLeft + ((bottomRight - topLeft) * 8 / 10);
    await tester.tapAt(slider8Position);
    await tester.pumpAndSettle();
    expect(callCount, 1);
  });
}
