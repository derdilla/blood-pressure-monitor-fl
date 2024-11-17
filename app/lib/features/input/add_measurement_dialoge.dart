import 'dart:async';

import 'package:blood_pressure_app/components/fullscreen_dialoge.dart';
import 'package:blood_pressure_app/features/input/forms/add_entry_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:health_data_store/health_data_store.dart';

/// Input mask for entering measurements.
class AddEntryDialoge extends StatefulWidget {
  /// Create a input mask for entering measurements.
  /// 
  /// This is usually created through the [showAddEntryDialoge] function.
  const AddEntryDialoge({super.key,
    required this.availableMeds,
    this.initialRecord,
  });

  /// Values that are prefilled.
  ///
  /// When this is null the timestamp is [DateTime.now] and the other fields
  /// will be empty.
  ///
  /// When an initial record is set medicine input is not possible because it is
  /// saved separately.
  final FullEntry? initialRecord;

  /// All medicines selectable.
  ///
  /// Hides med input when this is empty.
  final List<Medicine> availableMeds;

  @override
  State<AddEntryDialoge> createState() => _AddEntryDialogeState();
}

class _AddEntryDialogeState extends State<AddEntryDialoge> {
  final formKey = GlobalKey<AddEntryFormState>();

  @override
  Widget build(BuildContext context) => FullscreenDialoge(
    actionButtonText: AppLocalizations.of(context)!.btnSave,
    bottomAppBar: false, // TODO
    body: AddEntryForm(meds: widget.availableMeds),
  );
}

/// Shows a dialoge to input a blood pressure measurement or a medication.
Future<FullEntry?> showAddEntryDialoge(
  BuildContext context,
  MedicineRepository medRepo,
  [FullEntry? initialRecord,
]) async {
  final meds = await medRepo.getAll();
  return showDialog<FullEntry>(
    context: context, builder: (context) => AddEntryDialoge(
      initialRecord: initialRecord,
      availableMeds: meds,
    ),
  );
}
