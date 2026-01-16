import 'package:blood_pressure_app/features/settings/add_medication_dialoge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health_data_store/health_data_store.dart';

import '../../util.dart';

void main() {
  testWidgets('should prefill initialValue', (tester) async {
    await tester.pumpWidget(materialApp(AddMedicationDialoge(
      initialValue: Medicine(
        designation: 'testmed 1',
        color: Colors.red.toARGB32(),
        dosis: Weight.mg(12.34),
      ),)));
    expect(find.text('testmed 1'), findsOneWidget);
    expect(find.text('12.34'), findsOneWidget);
  });
}
