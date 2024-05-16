import 'package:blood_pressure_app/components/bluetooth_input/input_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows all elements', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: InputCard(
        onClosed: () {},
        title: const Text('Some title'),
        child: const CircularProgressIndicator(),
      ),
    ));

    expect(find.text('Some title'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.byIcon(Icons.close), findsOneWidget);

    expect(
      tester.getBottomLeft(find.text('Some title')).dy,
      lessThan(tester.getTopLeft(find.byType(CircularProgressIndicator)).dy),
    );
    expect(
      tester.getBottomLeft(find.byIcon(Icons.close)).dy,
      lessThan(tester.getTopLeft(find.byType(CircularProgressIndicator)).dy),
    );
  });

  testWidgets('hides correct elements', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: InputCard(
        child: Text('content'),
      ),
    ));

    expect(find.text('content'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.byIcon(Icons.close), findsNothing);
  });

  testWidgets('triggers close listener', (WidgetTester tester) async {
    int closeCount = 0;
    await tester.pumpWidget(MaterialApp(
      home: InputCard(
        child: const SizedBox.shrink(),
        onClosed: () {
          closeCount++;
        },
      ),
    ));

    expect(find.byIcon(Icons.close), findsOneWidget);
    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();
    expect(closeCount, 1);
  });
}
