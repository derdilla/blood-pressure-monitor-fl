
import 'package:blood_pressure_app/components/statistics/value_distribution.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import '../util.dart';

void main() {
  testWidgets('should show centered info when values are empty', (widgetTester) async {
    await widgetTester.pumpWidget(materialApp(const ValueDistribution(
      color: Colors.red,
      values: [],
    ),),);
    expect(find.byType(ValueDistribution), findsOneWidget);
    final localizations = await AppLocalizations.delegate.load(const Locale('en'));
    expect(find.byType(Text), findsOneWidget);
    expect(find.text(localizations.errNoData), findsOneWidget);

    final errorCenter = widgetTester.getCenter(find.byType(Text));
    final canvasCenter = widgetTester.getCenter(find.byType(MaterialApp));
    expect(errorCenter, equals(canvasCenter));;
  },);

  testWidgets('should draw labels at correct positions', (widgetTester) async {
    await widgetTester.pumpWidget(materialApp(const SizedBox(
      height: 50,
      width: 180,
      child: ValueDistribution(
        color: Colors.red,
        values: [5,6,3,8,8,10], // min 3, max 10, avg 6 + 2/3
      ),
    ),),);

    expect(find.byType(ValueDistribution), findsOneWidget);
    expect(find.byType(ValueDistribution),
        paintsExactlyCountTimes(#drawParagraph, 3),);
    const posBelowCenter = 9.0;
    expect(find.byType(ValueDistribution), paints
      ..paragraph(offset: const Offset(0.0, posBelowCenter))
      ..paragraph(offset: const Offset(66.0, posBelowCenter)) // overflows at the end
      ..paragraph(offset: const Offset(68.0, posBelowCenter)),
    );
  },);

  testWidgets('should correct amount of value bars', (widgetTester) async {
    await widgetTester.pumpWidget(materialApp(const SizedBox(
      height: 50,
      width: 180,
      child: ValueDistribution(
        color: Colors.red,
        values: [1,2,3,3,4,5],
      ),
    ),),);

    expect(find.byType(ValueDistribution), findsOneWidget);
    expect(find.byType(ValueDistribution), paints
      ..line(color: Colors.red.shade500)
      ..line(color: Colors.red.shade500)
      ..line(color: Colors.red.shade500)
      ..line(color: Colors.red.shade500)
      ..line(color: Colors.red.shade500)
      ..line(color: Colors.white70) // start drawing decoration
    ,);
  },);
  testWidgets('should have semantics labels with correct values', (widgetTester) async {
    await widgetTester.pumpWidget(materialApp(const SizedBox(
      height: 50,
      width: 180,
      child: ValueDistribution(
        color: Colors.red,
        values: [5,6,3,8,8,10], // min 3, max 10, avg 6 + 2/3
      ),
    ),),);

    final localizations = await AppLocalizations.delegate.load(const Locale('en'));
    final labels = _getAllLabels(widgetTester.getSemantics(find.byType(ValueDistribution)));

    expect(labels, contains(localizations.minOf('3')));
    expect(labels, contains(localizations.maxOf('10')));
    expect(labels, contains(localizations.avgOf('7')));
  },);
}

/// Recursively fetches the labels of the semantics node and all its children.
List<String> _getAllLabels(SemanticsNode node) {
  final labels = [node.label];
  node.visitChildren((node) {
    labels.addAll(_getAllLabels(node));
    return true;
  });
  return labels;
}
