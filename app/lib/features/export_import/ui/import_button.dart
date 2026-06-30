import 'dart:convert';

import 'package:blood_pressure_app/features/export_import/model/csv_converter.dart';
import 'package:blood_pressure_app/features/export_import/model/csv_record_parsing_actor.dart';
import 'package:blood_pressure_app/features/export_import/ui/import_preview_dialog.dart';
import 'package:blood_pressure_app/features/input/forms/add_entry_form.dart';
import 'package:blood_pressure_app/l10n/app_localizations.dart';
import 'package:blood_pressure_app/model/storage/storage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_data_store/health_data_store.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';

/// Text button to import entries like configured in the context.
class ImportButton extends StatelessWidget {
  /// Create text button to import entries like configured in the context.
  const ImportButton({super.key});

  @override
  Widget build(BuildContext context) => TextButton.icon(
    label: Text(AppLocalizations.of(context)!.import),
    icon: Icon(Icons.file_upload_outlined),
    onPressed: () async {
      final localizations = AppLocalizations.of(context)!;
      final messenger = ScaffoldMessenger.of(context);
      final exportSettings = context.read<ExportSettings>();

      final file = (await FilePicker.pickFiles(
        withData: true,
      ))?.files.firstOrNull;
      if (file == null) {
        messenger.showSnackBar(SnackBar(content: Text(localizations.errNoFileOpened)));
        return;
      }
      if (!context.mounted) return;
      switch(file.extension?.toLowerCase()) {
        case 'csv':
          final binaryContent = file.bytes;
          if (binaryContent == null) {
            messenger.showSnackBar(SnackBar(content: Text(localizations.errCantReadFile)));
            return;
          }
          if (!context.mounted) return;
          final csvSettings = Provider.of<CsvExportSettings>(context, listen: false);
          final exportColumnsManager = Provider.of<ExportColumnsManager>(context, listen: false);
          final converter = CsvConverter(
            csvSettings,
            exportColumnsManager,
            await RepositoryProvider.of<MedicineRepository>(context).getAll(),
            exportSettings,
          );
          if (!context.mounted) return;
          final importedRecords = await showImportPreview(
            context,
            CsvRecordParsingActor(
              converter,
              utf8.decode(binaryContent),
            ),
            exportColumnsManager,
            Provider.of<Settings>(context, listen: false).bottomAppBars,
          );
          if (importedRecords == null || !context.mounted) return;
          final bpRepo = RepositoryProvider.of<BloodPressureRepository>(context);
          final noteRepo = RepositoryProvider.of<NoteRepository>(context);
          final intakeRepo = RepositoryProvider.of<MedicineIntakeRepository>(context);
          final weightRepo = RepositoryProvider.of<BodyweightRepository>(context);
          await Future.forEach<AddEntryFormValue>(importedRecords, (e) async {
            if (e.sys != null || e.dia != null || e.pul != null) {
              await bpRepo.add(e.record!);
            }
            if (e.note != null) await noteRepo.add(e.note!);
            if (e.weight != null) await weightRepo.add(e.weight!);
            if (e.intake != null) await intakeRepo.add(e.intake!);
          });
          messenger.showSnackBar(SnackBar(content: Text(localizations.importSuccess(importedRecords.length))));
          break;
        case 'db':
          if (file.path == null) return;
          final bpRepo = RepositoryProvider.of<BloodPressureRepository>(context);
          final noteRepo = RepositoryProvider.of<NoteRepository>(context);
          final intakeRepo = RepositoryProvider.of<MedicineIntakeRepository>(context);

          final List<BloodPressureRecord> records = [];
          final List<Note> notes = [];
          final List<MedicineIntake> intakes = [];
          try {
            final db = await openReadOnlyDatabase(file.path!);
            final importedDB = await HealthDataStore.load(db, true);
            records.addAll(await importedDB.bpRepo.get(DateRange.all()));
            notes.addAll(await importedDB.noteRepo.get(DateRange.all()));
            intakes.addAll(await importedDB.intakeRepo.get(DateRange.all()));
            await db.close();
          } catch (e) {
            // DB doesn't conform new format
          }


          await Future.forEach(records, bpRepo.add);
          await Future.forEach(notes, noteRepo.add);
          await Future.forEach(intakes, intakeRepo.add);

          messenger.showSnackBar(SnackBar(content: Text(localizations.importSuccess(records.length))));
          break;
        default:
          messenger.showSnackBar(SnackBar(content: Text(localizations.errWrongImportFormat)));
      }
    },
  );
}
