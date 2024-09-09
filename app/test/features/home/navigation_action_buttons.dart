import 'package:blood_pressure_app/features/home/navigation_action_buttons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../util.dart';

void main() {
  testWidgets('shows all buttons', (tester) async {
    await tester.pumpWidget(materialApp(const NavigationActionButtons()));
    
    expect(find.byType(FloatingActionButton), findsNWidgets(3));
    expect(find.byIcon(Icons.add), findsOneWidget);
    expect(find.byIcon(Icons.settings), findsOneWidget);
    expect(find.byIcon(Icons.insights), findsOneWidget);
  });
}
