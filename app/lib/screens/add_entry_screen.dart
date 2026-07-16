import 'package:blood_pressure_app/features/export_import/ui/export_button.dart';
import 'package:blood_pressure_app/features/input/add_entry_dialog.dart';
import 'package:blood_pressure_app/logging.dart';
import 'package:blood_pressure_app/model/combined_entry.dart';
import 'package:blood_pressure_app/model/storage/storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_data_store/health_data_store.dart';

/// Harness for AddEntryDialog that handles save events and provides data.
class AddEntryScreen extends StatelessWidget with TypeLogger {
  const AddEntryScreen({
    super.key,
    this.initialRecord
  });

  final CombinedEntry? initialRecord;

  @override
  Widget build(BuildContext context) {
    final recordRepo = RepositoryProvider.of<BloodPressureRepository>(context);
    final noteRepo = RepositoryProvider.of<NoteRepository>(context);
    final intakeRepo = RepositoryProvider.of<MedicineIntakeRepository>(context);
    final weightRepo = RepositoryProvider.of<BodyweightRepository>(context);

    return PopScope(
      onPopInvokedWithResult: (_, entry) async {
        if (entry is! List) {
          logger.warning('Ignoring pop result due to type mismatch: ${entry.runtimeType}');
          return;
        }
        final castedList = entry.cast<CombinedEntry>();
        assert(castedList.isNotEmpty);

        if (initialRecord?.record != null) await recordRepo.remove(initialRecord!.record!);
        if (initialRecord?.note != null) await noteRepo.remove(initialRecord!.note!);
        if (initialRecord?.intake != null) await intakeRepo.remove(initialRecord!.intake!);
        if (initialRecord?.weight != null) await weightRepo.remove(initialRecord!.weight!);

        for (final entry in castedList) {
          if (entry.record != null) await recordRepo.add(entry.record!);
          if (entry.note != null) await noteRepo.add(entry.note!);
          if (entry.intake != null) await intakeRepo.add(entry.intake!);
          if (entry.weight != null) await weightRepo.add(entry.weight!);
        }

        if (context.mounted &&
            context.read<ExportSettings>().exportAfterEveryEntry) {
          performExport(context, false);
        }
      },
      child: AddEntryDialog(
        initialRecord: initialRecord,
      ),
    );
  }
}
