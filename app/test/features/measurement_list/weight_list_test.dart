import 'package:blood_pressure_app/features/measurement_list/weight_list.dart';
import 'package:blood_pressure_app/model/storage/interval_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health_data_store/health_data_store.dart';

import '../../util.dart';

void main() {
  testWidgets('shows all elements in time range in order', (tester) async {
    final interval = IntervalStorage();
    interval.changeStepSize(TimeStep.lifetime);

    await tester.pumpWidget(await appBaseWithData(
      weights: [
        BodyweightRecord(time: DateTime(2001), weight: Weight.kg(123.0)),
        BodyweightRecord(time: DateTime(2003), weight: Weight.kg(122.1)),
        BodyweightRecord(time: DateTime(2000), weight: Weight.kg(70.0)),
        BodyweightRecord(time: DateTime(2002), weight: Weight.kg(7000.12345)),
      ],
      intervallStoreManager: IntervalStoreManager(interval, IntervalStorage(), IntervalStorage()),
      const WeightList(rangeType: IntervalStoreManagerLocation.mainPage),
    ));
    await tester.pumpAndSettle();

    expect(find.byType(ListTile), findsNWidgets(4));
    expect(find.text('123 kg'), findsOneWidget);
    expect(find.text('122.1 kg'), findsOneWidget);
    expect(find.text('70 kg'), findsOneWidget);
    expect(find.text('7000.12 kg'), findsOneWidget);

    expect(
      tester.getCenter(find.textContaining('2003')).dy,
      lessThan(tester.getCenter(find.textContaining('2002')).dy),
    );
    expect(
      tester.getCenter(find.textContaining('2002')).dy,
      lessThan(tester.getCenter(find.textContaining('2001')).dy),
    );
    expect(
      tester.getCenter(find.textContaining('2001')).dy,
      lessThan(tester.getCenter(find.textContaining('2000')).dy),
    );
  });
}
