import 'dart:async';

import 'package:blood_pressure_app/model/blood_pressure/medicine/medicine_intake.dart';
import 'package:blood_pressure_app/model/storage/settings_store.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'measurement_list_entry.dart';

/// Medicine intake to display in a list.
class IntakeListEntry extends StatelessWidget {
  /// Display a medicine intake on a list tile.
  const IntakeListEntry({super.key,
    required this.settings,
    required this.intake,
    this.delete,
  });

  /// Settings to customize basic behavior.
  final Settings settings;

  /// Intake that provides the data to display.
  final MedicineIntake intake;

  /// Function to delete this intake.
  ///
  /// Gets called after the delete button has been pressed and the deletion got
  /// confirmed.
  /// When null no deletion button is displayed.
  final FutureOr<void> Function()? delete;

  @override
  Widget build(BuildContext context) => ListTile(
    title: Text(intake.medicine.designation),
    subtitle: Text(DateFormat(settings.dateFormatString).format(intake.timestamp)),
    trailing: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(intake.dosis.toString()),
        if (delete != null)
          IconButton(
            onPressed: () async {
              bool confirmedDeletion = true;
              if (settings.confirmDeletion) {
                confirmedDeletion = await showConfirmDeletionDialoge(context);
              }
              if (confirmedDeletion) delete!();
            },
            icon: const Icon(Icons.delete)
          ), // TODO: show in graph
      ],
    ),
    leading: const Icon(Icons.medication),
    iconColor: intake.medicine.color,
  );


}