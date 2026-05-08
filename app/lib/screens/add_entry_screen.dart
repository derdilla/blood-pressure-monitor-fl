import 'package:blood_pressure_app/features/export_import/export_button.dart';
import 'package:blood_pressure_app/features/input/add_entry_dialog.dart';
import 'package:blood_pressure_app/features/input/forms/add_entry_form.dart';
import 'package:blood_pressure_app/model/storage/storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_data_store/health_data_store.dart';

/// Harness for AddEntryDialog that handles save events and provides data.
class AddEntryScreen extends StatelessWidget {
  const AddEntryScreen({
    super.key,
    required this.initialMedicineList,
  });

  final List<Medicine> initialMedicineList;

  @override
  Widget build(BuildContext context) {
    final recordRepo = RepositoryProvider.of<BloodPressureRepository>(context);
    final noteRepo = RepositoryProvider.of<NoteRepository>(context);
    final intakeRepo = RepositoryProvider.of<MedicineIntakeRepository>(context);
    final weightRepo = RepositoryProvider.of<BodyweightRepository>(context);

    return PopScope(
      onPopInvokedWithResult: (_, entry) async {
        if (entry is! AddEntryFormValue) return;

        if (entry.record != null) await recordRepo.add(entry.record!);
        if (entry.note != null) await noteRepo.add(entry.note!);
        if (entry.intake != null) await intakeRepo.add(entry.intake!);
        if (entry.weight != null) await weightRepo.add(entry.weight!);

        if (context.mounted &&
            context.read<ExportSettings>().exportAfterEveryEntry) {
          performExport(context, false);
        }
      },
      child: AddEntryDialog(
        availableMeds: initialMedicineList,
        // TODO: initialMeasurement,
      ),
    );
  }
}
