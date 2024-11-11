import 'package:blood_pressure_app/features/statistics/value_graph.dart';
import 'package:blood_pressure_app/model/horizontal_graph_line.dart';
import 'package:blood_pressure_app/model/storage/storage.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health_data_store/health_data_store.dart';
import 'package:provider/provider.dart';

import '../../model/analyzer_test.dart';
import '../../util.dart';
import '../measurement_list/measurement_list_entry_test.dart';

void main() {
  test('Creates correct sys series', () {
    final records = [
      mockRecord(time: DateTime(2000), sys: 123),
      mockRecord(time: DateTime(2001), sys: 120),
      // ignore: avoid_redundant_argument_values
      mockRecord(time: DateTime(2002), sys: null),
      mockRecord(time: DateTime(2003), sys: 123),
      mockRecord(time: DateTime(2004), sys: 200),
    ];
    assert(records.isSorted((a, b) => a.time.compareTo(b.time)));

    final graph = records.sysGraph();
    expect(graph, hasLength(4));
    expect(graph.isSorted((a, b) => a.$1.compareTo(b.$1)), isTrue);
    expect(graph.elementAt(0).$2, 123);
    expect(graph.elementAt(1).$2, 120);
    expect(graph.elementAt(2).$2, 123);
    expect(graph.elementAt(3).$2, 200);
  });
  test('Creates correct dia series', () {
    final records = [
      mockRecord(time: DateTime(2000), dia: 123),
      mockRecord(time: DateTime(2001), dia: 120),
      // ignore: avoid_redundant_argument_values
      mockRecord(time: DateTime(2002), dia: null),
      mockRecord(time: DateTime(2003), dia: 123),
      mockRecord(time: DateTime(2004), dia: 200),
    ];
    assert(records.isSorted((a, b) => a.time.compareTo(b.time)));

    final graph = records.diaGraph();
    expect(graph, hasLength(4));
    expect(graph.isSorted((a, b) => a.$1.compareTo(b.$1)), isTrue);
    expect(graph.elementAt(0).$2, 123);
    expect(graph.elementAt(1).$2, 120);
    expect(graph.elementAt(2).$2, 123);
    expect(graph.elementAt(3).$2, 200);
  });
  test('Creates correct pul series', () {
    final records = [
      mockRecord(time: DateTime(2000), pul: 123),
      mockRecord(time: DateTime(2001), pul: 120),
      // ignore: avoid_redundant_argument_values
      mockRecord(time: DateTime(2002), pul: null),
      mockRecord(time: DateTime(2003), pul: 123),
      mockRecord(time: DateTime(2004), pul: 200),
    ];
    assert(records.isSorted((a, b) => a.time.compareTo(b.time)));

    final graph = records.pulGraph();
    expect(graph, hasLength(4));
    expect(graph.isSorted((a, b) => a.$1.compareTo(b.$1)), isTrue);
    expect(graph.elementAt(0).$2, 123.0);
    expect(graph.elementAt(1).$2, 120.0);
    expect(graph.elementAt(2).$2, 123.0);
    expect(graph.elementAt(3).$2, 200.0);
  });
  testWidgets('BloodPressureValueGraph shows when there are not enough values', (tester) async {
    await tester.pumpWidget(_buildGraph([], [], []));
    final localizations = await AppLocalizations.delegate.load(const Locale('en'));
    expect(find.text(localizations.errNotEnoughDataToGraph), findsOneWidget);
  });
  testWidgets('graph with all extras is rendered correctly', (tester) async {
    await tester.pumpWidget(_buildGraph([
      mockRecord(time: DateTime(2005), sys: 123, dia: 80, pul: 50),
      mockRecord(time: DateTime(2003), sys: 110, dia: 73, pul: 130),
      mockRecord(time: DateTime(2003, 5), sys: 140, dia: 74, pul: 64),
      mockRecord(time: DateTime(2007), sys: 132, dia: 100, pul: 75),
    ], [
      (DateTime(2005), Colors.purple),
      (DateTime(2005, 3), Colors.tealAccent),
      (DateTime(2007), Colors.yellow),
    ], [
      mockIntake(mockMedicine(color: Colors.blueGrey), time: DateTime(2005).millisecondsSinceEpoch),
      mockIntake(mockMedicine(color: Colors.indigoAccent), time: DateTime(2004).millisecondsSinceEpoch),
    ],
    settings: Settings(
      drawRegressionLines: true,
      graphLineThickness: 3.2,
      diaWarn: 75,
      needlePinBarWidth: 7.0,
      horizontalGraphLines: [
        HorizontalGraphLine(Colors.lightBlue, 113),
        HorizontalGraphLine(Colors.amber, 45),
      ]
    )));
    await tester.pumpAndSettle();
    final localizations = await AppLocalizations.delegate.load(const Locale('en'));
    expect(find.text(localizations.errNotEnoughDataToGraph), findsNothing);

    await expectLater(find.byType(BloodPressureValueGraph), myMatchesGoldenFile('full_graph-years.png'));
  });

  testWidgets('BloodPressureValueGraph is fine with enough values in sys category', (tester) async {
    await tester.pumpWidget(_buildGraph([
      mockRecord(time: DateTime(2005), sys: 123),
      mockRecord(time: DateTime(2003), sys: 110),
    ], [], []));
    final localizations = await AppLocalizations.delegate.load(const Locale('en'));
    expect(find.text(localizations.errNotEnoughDataToGraph), findsNothing);
  });
  testWidgets('BloodPressureValueGraph is fine with enough values in dia category', (tester) async {
    await tester.pumpWidget(_buildGraph([
      mockRecord(time: DateTime(2005), dia: 123),
      mockRecord(time: DateTime(2003), dia: 110),
    ], [], []));
    final localizations = await AppLocalizations.delegate.load(const Locale('en'));
    expect(find.text(localizations.errNotEnoughDataToGraph), findsNothing);
  });
  testWidgets('BloodPressureValueGraph is fine with enough values in pul category', (tester) async {
    await tester.pumpWidget(_buildGraph([
      mockRecord(time: DateTime(2005), pul: 123),
      mockRecord(time: DateTime(2003), pul: 110),
    ], [], []));
    final localizations = await AppLocalizations.delegate.load(const Locale('en'));
    expect(find.text(localizations.errNotEnoughDataToGraph), findsNothing);
  });

  testWidgets('graph renders area at start correctly', (tester) async {
    await tester.pumpWidget(_buildGraph([
        mockRecord(time: DateTime(2003), sys: 170, dia: 100, pul: 50),
        mockRecord(time: DateTime(2005), sys: 110, dia: 70, pul: 50),
      ], [], [],
      settings: Settings(
        diaWarn: 75,
        sysWarn: 120,
      ),
    ));
    await tester.pumpAndSettle();
    final localizations = await AppLocalizations.delegate.load(const Locale('en'));
    expect(find.text(localizations.errNotEnoughDataToGraph), findsNothing);

    await expectLater(find.byType(BloodPressureValueGraph), myMatchesGoldenFile('value-graph-start-warn.png'));
  });
  testWidgets('graph renders area at end correctly', (tester) async {
    await tester.pumpWidget(_buildGraph([
      mockRecord(time: DateTime(2005), sys: 170, dia: 100, pul: 50),
      mockRecord(time: DateTime(2003), sys: 110, dia: 70, pul: 50),
    ], [], [],
      settings: Settings(
        diaWarn: 75,
        sysWarn: 120,
      ),
    ));
    await tester.pumpAndSettle();
    final localizations = await AppLocalizations.delegate.load(const Locale('en'));
    expect(find.text(localizations.errNotEnoughDataToGraph), findsNothing);

    await expectLater(find.byType(BloodPressureValueGraph), myMatchesGoldenFile('value-graph-end-warn.png'));
  });
}

Widget _buildGraph(
  List<BloodPressureRecord> data,
  List<(DateTime, Color)> colors,
  List<MedicineIntake> intakes, {
  Settings? settings,
}) => materialApp(ChangeNotifierProvider<Settings>.value(
  value: settings ?? Settings(),
  child: SizedBox(
    width: 500,
    height: 300,
    child: BloodPressureValueGraph(
      records: data,
      colors: colors.map((e) => Note(time: e.$1, color: e.$2.value)).toList(),
      intakes: intakes,
    ),
  ),
));
