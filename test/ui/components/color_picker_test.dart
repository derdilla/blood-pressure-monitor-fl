import 'package:blood_pressure_app/components/color_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ColorPicker', () {
    testWidgets('should initialize without errors', (widgetTester) async {
      await widgetTester.pumpWidget(_materialApp(ColorPicker(onColorSelected: (color) {})));
      await widgetTester.pumpWidget(_materialApp(ColorPicker(availableColors: const [], onColorSelected: (color) {})));
      await widgetTester.pumpWidget(_materialApp(ColorPicker(showTransparentColor: false, onColorSelected: (color) {})));
      await widgetTester.pumpWidget(_materialApp(ColorPicker(circleSize: 15, onColorSelected: (color) {})));
      await widgetTester.pumpWidget(_materialApp(ColorPicker(availableColors: const [], initialColor: Colors.red, onColorSelected: (color) {})));
      expect(widgetTester.takeException(), isNull);
    });
    testWidgets('should report correct picked color', (widgetTester) async {
      int onColorSelectedCallCount = 0;
      await widgetTester.pumpWidget(_materialApp(ColorPicker(onColorSelected: (color) {
        expect(color, Colors.blue);
        onColorSelectedCallCount += 1;
      })));

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
      await widgetTester.tap(find.byWidget(blueColor.first.widget));
      expect(onColorSelectedCallCount, 1);
    });
  });
}

Widget _materialApp(Widget child) {
  return MaterialApp(
    home: Scaffold(body: child),
  );
}