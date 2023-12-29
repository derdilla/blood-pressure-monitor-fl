import 'package:blood_pressure_app/model/blood_pressure/medicine/medicine_intake.dart';
import 'package:blood_pressure_app/model/storage/settings_store.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Medicine intake to display in a list.
class IntakeListEntry extends StatelessWidget {
  const IntakeListEntry({super.key,
    required this.settings,
    required this.intake,
  });

  final Settings settings;

  final MedicineIntake intake;

  @override
  Widget build(BuildContext context) => ListTile(
    title: Text(intake.medicine.designation),
    subtitle: Text(DateFormat(settings.dateFormatString).format(intake.timestamp)),
    trailing: Text(intake.dosis.toString()),
    leading: const Icon(Icons.medication),
    iconColor: intake.medicine.color,
  );


}