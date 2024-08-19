import 'package:blood_pressure_app/features/statistics/value_graph.dart';
import 'package:blood_pressure_app/model/storage/storage.dart';
import 'package:collection/collection.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../model/analyzer_test.dart';

void main() {
  test('Creates correct sys series', () {
    final records = [
      mockRecord(time: DateTime(2000), sys: 123),
      mockRecord(time: DateTime(2001), sys: 120),
      mockRecord(time: DateTime(2002), sys: null),
      mockRecord(time: DateTime(2003), sys: 123),
      mockRecord(time: DateTime(2004), sys: 200),
    ];
    assert(records.isSorted((a, b) => a.time.compareTo(b.time)));

    final graph = records.sysGraph();
    expect(graph, hasLength(4));
    expect(graph.isSorted((a, b) => a.$1.compareTo(b.$1)), isTrue);
    expect(graph.elementAt(0).$2, 123 * 0.133322);
    expect(graph.elementAt(1).$2, 120 * 0.133322);
    expect(graph.elementAt(2).$2, 123 * 0.133322);
    expect(graph.elementAt(3).$2, 200 * 0.133322);
  });
  test('Creates correct dia series', () {
    final records = [
      mockRecord(time: DateTime(2000), dia: 123),
      mockRecord(time: DateTime(2001), dia: 120),
      mockRecord(time: DateTime(2002), dia: null),
      mockRecord(time: DateTime(2003), dia: 123),
      mockRecord(time: DateTime(2004), dia: 200),
    ];
    assert(records.isSorted((a, b) => a.time.compareTo(b.time)));

    final graph = records.diaGraph();
    expect(graph, hasLength(4));
    expect(graph.isSorted((a, b) => a.$1.compareTo(b.$1)), isTrue);
    expect(graph.elementAt(0).$2, 123 * 0.133322);
    expect(graph.elementAt(1).$2, 120 * 0.133322);
    expect(graph.elementAt(2).$2, 123 * 0.133322);
    expect(graph.elementAt(3).$2, 200 * 0.133322);
  });
  test('Creates correct pul series', () {
    final records = [
      mockRecord(time: DateTime(2000), pul: 123),
      mockRecord(time: DateTime(2001), pul: 120),
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
  testWidgets('BloodPressureValueGraph throws assertion error without enough values', (tester) async {
    await expectLater(
      () => tester.pumpWidget(BloodPressureValueGraph(records: [], settings: Settings(),)),
      throwsAssertionError,
    );
  });
  testWidgets('BloodPressureValueGraph throws assertion error with unsorted values', (tester) async {
    await expectLater(
      () => tester.pumpWidget(BloodPressureValueGraph(records: [
        mockRecord(time: DateTime(2005), sys: 1),
        mockRecord(time: DateTime(2003), sys: 1),
        mockRecord(time: DateTime(2007), sys: 1),
      ], settings: Settings())),
      throwsAssertionError,
    );
  });
  testWidgets('BloodPressureValueGraph can be instantiated with valid values', (tester) async {
    await expectLater(
      () => tester.pumpWidget(BloodPressureValueGraph(records: [
        mockRecord(time: DateTime(2003), sys: 1),
        mockRecord(time: DateTime(2005), sys: 1),
        mockRecord(time: DateTime(2007), sys: 1),
      ], settings: Settings())),
      returnsNormally,
    );
  });
}
