import 'package:blood_pressure_app/components/color_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'util.dart';

void main() {
  testWidgets('should initialize without errors', (tester) async {
    await tester.pumpWidget(materialApp(ColorPicker(onColorSelected: (color) {})));
    await tester.pumpWidget(materialApp(ColorPicker(availableColors: const [], onColorSelected: (color) {})));
    await tester.pumpWidget(materialApp(ColorPicker(showTransparentColor: false, onColorSelected: (color) {})));
    await tester.pumpWidget(materialApp(ColorPicker(circleSize: 15, onColorSelected: (color) {})));
    await tester.pumpWidget(
        materialApp(ColorPicker(availableColors: const [], initialColor: Colors.red, onColorSelected: (color) {})),);
    expect(tester.takeException(), isNull);
  });
  testWidgets('should report correct picked color', (tester) async {
    int onColorSelectedCallCount = 0;
    await tester.pumpWidget(materialApp(ColorPicker(onColorSelected: (color) {
      expect(color, Colors.blue);
      onColorSelectedCallCount += 1;
    },),),);

    final containers = find.byType(Container).evaluate();
    final blueColor = containers.where((element) { // find widgets with color blue
      final widget = (element.widget as Container);
      final decoration = widget.decoration;
      if (decoration != null && decoration is BoxDecoration) {
        return decoration.color == Colors.blue;
      }
      return false;
    });
    expect(blueColor.length, 1);
    await tester.tap(find.byWidget(blueColor.first.widget));
    expect(onColorSelectedCallCount, 1);
  });
}
