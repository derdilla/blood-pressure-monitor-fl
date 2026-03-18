import 'dart:async';

import 'package:blood_pressure_app/components/confirm_deletion_dialog.dart';
import 'package:blood_pressure_app/components/fullscreen_dialog.dart';
import 'package:blood_pressure_app/features/input/forms/add_entry_form.dart';
import 'package:blood_pressure_app/l10n/app_localizations.dart';
import 'package:blood_pressure_app/logging.dart';
import 'package:blood_pressure_app/model/storage/storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_data_store/health_data_store.dart';

/// Input mask for entering measurements.
class AddEntryDialog extends StatefulWidget {
  /// Create a input mask for entering measurements.
  /// 
  /// This is usually created through the [showAddEntryDialog] function.
  const AddEntryDialog({super.key,
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
  State<AddEntryDialog> createState() => _AddEntryDialogState();
}

class _AddEntryDialogState extends State<AddEntryDialog> with TypeLogger {
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

  Future<bool> shouldPop() async {
    if (context.read<Settings>().validateInputs
        && !(formKey.currentState?.isEmpty ?? true)) {
      final res = await showConfirmDeletionDialog(context,
          AppLocalizations.of(context)!.warnDiscardingData);
      return res;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: false,
    // Popping though system buttons
    onPopInvokedWithResult: (didPop, result) async {
      if(didPop) return;
      if (await shouldPop() && context.mounted) Navigator.pop(context, result);
    },
    child: FullscreenDialog(
      actionButtonText: AppLocalizations.of(context)!.btnSave,
      onActionButtonPressed: _onSavePressed,
      // Popping though in-app buttons
      canClose: shouldPop,
      bottomAppBar: context.select((Settings s) => s.bottomAppBars),
      body: AddEntryForm(
        key: formKey,
        initialValue: widget.initialRecord,
        meds: widget.availableMeds ?? [],
      ),
    ),
  );
}

/// Shows a dialog to input a blood pressure measurement or a medication.
Future<AddEntryFormValue?> showAddEntryDialog(
  BuildContext context,
  MedicineRepository medRepo,
  [AddEntryFormValue? initialRecord,
]) async {
  final meds = await medRepo.getAll();
  if (context.mounted) {
    return showDialog<AddEntryFormValue>(
      context: context, builder: (context) =>
        AddEntryDialog(
          initialRecord: initialRecord,
          availableMeds: meds,
        ),
    );
  }
  return null;
}
