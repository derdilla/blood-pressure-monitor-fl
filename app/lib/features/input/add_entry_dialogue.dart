import 'dart:async';

import 'package:blood_pressure_app/components/fullscreen_dialoge.dart';
import 'package:blood_pressure_app/features/input/forms/add_entry_form.dart';
import 'package:blood_pressure_app/logging.dart';
import 'package:blood_pressure_app/model/storage/storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:blood_pressure_app/l10n/app_localizations.dart';
import 'package:health_data_store/health_data_store.dart';

/// Input mask for entering measurements.
class AddEntryDialogue extends StatefulWidget {
  /// Create a input mask for entering measurements.
  /// 
  /// This is usually created through the [showAddEntryDialogue] function.
  const AddEntryDialogue({super.key,
    this.availableMeds,
    this.initialRecord,
  });

  /// Values that are prefilled.
  ///
  /// When this is null the timestamp is [DateTime.now] and the other fields
  /// will be empty.
  final AddEntryFormValue? initialRecord;

  /// All medicines selectable.
  ///
  /// Hides med input when this is empty or null.
  final List<Medicine>? availableMeds;

  @override
  State<AddEntryDialogue> createState() => _AddEntryDialogueState();
}

class _AddEntryDialogueState extends State<AddEntryDialogue> with TypeLogger {
  final formKey = GlobalKey<AddEntryFormState>();

  void _onSavePressed() {
    if (formKey.currentState?.validate() ?? false) {
      final AddEntryFormValue? result = formKey.currentState?.save();
      logger.finer('Returning result: $result');
      Navigator.pop(context, result);
    } else {
      // Errors are displayed below their specific widgets
    }
  }

  @override
  Widget build(BuildContext context) => FullscreenDialoge(
    actionButtonText: AppLocalizations.of(context)!.btnSave,
    onActionButtonPressed: _onSavePressed,
    bottomAppBar: context.select((Settings s) => s.bottomAppBars),
    body: AddEntryForm(
      key: formKey,
      initialValue: widget.initialRecord,
      meds: widget.availableMeds ?? [],
    ),
  );
}

/// Shows a dialogue to input a blood pressure measurement or a medication.
Future<AddEntryFormValue?> showAddEntryDialogue(
  BuildContext context,
  MedicineRepository medRepo,
  [AddEntryFormValue? initialRecord,
]) async {
  final meds = await medRepo.getAll();
  if (context.mounted) {
    return showDialog<AddEntryFormValue>(
      context: context, builder: (context) =>
        AddEntryDialogue(
          initialRecord: initialRecord,
          availableMeds: meds,
        ),
    );
  }
  return null;
}
