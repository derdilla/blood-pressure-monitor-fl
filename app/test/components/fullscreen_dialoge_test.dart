import 'package:blood_pressure_app/components/fullscreen_dialoge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../util.dart';

void main() {
  testWidgets('shows passed body and bar', (tester) async {
    await tester.pumpWidget(materialApp(const FullscreenDialoge(
      actionButtonText: 'BTN',
      closeIcon: Icons.access_time,
      actions: [Text('ACTION')],
      body: Text('BODY'),
      bottomAppBar: false,
    )));
    expect(find.text('BTN'), findsOneWidget);
    expect(find.text('BODY'), findsOneWidget);
    expect(find.text('ACTION'), findsOneWidget);
    expect(find.byIcon(Icons.access_time), findsOneWidget);
    expect(find.byIcon(Icons.close), findsNothing);
  });
  testWidgets('close button pops scope', (tester) async {
    int popInvokedCount = 0;
    await tester.pumpWidget(materialApp(PopScope(
      onPopInvoked: (_) => popInvokedCount++,
      child: const FullscreenDialoge(
        closeIcon: Icons.add,
        bottomAppBar: false,
        actionButtonText: null,
      ),
    )));

    expect(popInvokedCount, 0);
    await tester.tap(find.byIcon(Icons.add));
    expect(popInvokedCount, 1);
  });
  testWidgets('action button callback works', (tester) async {
    int actionCallbackCount = 0;
    await tester.pumpWidget(materialApp(FullscreenDialoge(
      actionButtonText: 'BTN',
      onActionButtonPressed: () => actionCallbackCount++,
      bottomAppBar: false,
    )));

    expect(actionCallbackCount, 0);
    await tester.tap(find.text('BTN'));
    expect(actionCallbackCount, 1);
    await tester.tap(find.text('BTN'));
    expect(actionCallbackCount, 2);
  });
  testWidgets('app bar is positioned according to bottomAppBar', (tester) async {
    await tester.pumpWidget(materialApp(const FullscreenDialoge(
      closeIcon: Icons.add,
      bottomAppBar: false,
      actionButtonText: null,
    )));
    expect(tester.getTopLeft(find.byType(AppBar)), tester.getTopLeft(find.byType(FullscreenDialoge)));
    final double topAppBarYPos = tester.getTopLeft(find.byType(AppBar)).dy;

    await tester.pumpWidget(materialApp(const FullscreenDialoge(
      closeIcon: Icons.add,
      bottomAppBar: true,
      actionButtonText: null,
    )));
    expect(tester.getBottomRight(find.byType(AppBar)), tester.getBottomRight(find.byType(FullscreenDialoge)));
    
    expect(tester.getTopLeft(find.byType(AppBar)).dy, greaterThan(topAppBarYPos));
  });
  testWidgets('bottomAppBar adds 4 units of padding to the top', (tester) async {
    await tester.pumpWidget(materialApp(const FullscreenDialoge(
      closeIcon: Icons.add,
      bottomAppBar: false,
      actionButtonText: null,
      body: Text('A'),
    )));
    final double bodyStart = tester.getTopLeft(find.text('A')).dy - tester.getBottomRight(find.byType(AppBar)).dy;

    await tester.pumpWidget(materialApp(const FullscreenDialoge(
      closeIcon: Icons.add,
      bottomAppBar: true,
      actionButtonText: null,
      body: Text('A'),
    )));

    expect(tester.getTopLeft(find.text('A')).dy, greaterThan(bodyStart));
    expect(tester.getTopLeft(find.text('A')).dy, bodyStart + 4.0);
  });
}
