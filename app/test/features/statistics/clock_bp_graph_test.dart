import 'dart:math';

import 'package:blood_pressure_app/features/statistics/clock_bp_graph.dart';
import 'package:blood_pressure_app/model/storage/settings_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import '../../model/analyzer_test.dart';
import '../../util.dart';

void main() {
  testWidgets("doesn't throw when empty" , (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: ChangeNotifierProvider<Settings>(
          create: (_) => Settings(),
          child: ClockBpGraph(measurements: []),
        ),
      ),
    ));
    expect(tester.takeException(), isNull);
    expect(find.byType(ClockBpGraph), findsOneWidget);
  });
  testWidgets('renders sample data like expected in light mode', (tester) async {
    final rng = Random(1234);
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: ChangeNotifierProvider<Settings>(
          create: (_) => Settings(
            pulColor: Colors.pink,
          ),
          child: ClockBpGraph(measurements: [
            for (int i = 0; i < 50; i++)
              mockRecord(
                time: DateTime.fromMillisecondsSinceEpoch(rng.nextInt(1724578014) * 1000),
                sys: rng.nextInt(60) + 70,
                dia: rng.nextInt(60) + 40,
                pul: rng.nextInt(70) + 40,
              )
          ],),
        ),
      ),
    ));
    await expectLater(find.byType(ClockBpGraph), myMatchesGoldenFile('ClockBpGraph-light.png'));
  });
  testWidgets('renders sample data like expected in dart mode', (tester) async {
    final rng = Random(1234);
    await tester.pumpWidget(MaterialApp(
      theme: ThemeData.dark(useMaterial3: true),
      home: Scaffold(
        body: ChangeNotifierProvider<Settings>(
          create: (_) => Settings(
            pulColor: Colors.pink,
          ),
          child: ClockBpGraph(measurements: [
            for (int i = 0; i < 50; i++)
              mockRecord(
                time: DateTime.fromMillisecondsSinceEpoch(rng.nextInt(1724578014) * 1000),
                sys: rng.nextInt(60) + 70,
                dia: rng.nextInt(60) + 40,
                pul: rng.nextInt(70) + 40,
              )
          ],),
        ),
      ),
    ));
    await expectLater(find.byType(ClockBpGraph), myMatchesGoldenFile('ClockBpGraph-dark.png'));
  });
}
