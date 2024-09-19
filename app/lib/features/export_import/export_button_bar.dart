import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:blood_pressure_app/features/export_import/import_preview_dialoge.dart';
import 'package:blood_pressure_app/model/blood_pressure/model.dart';
import 'package:blood_pressure_app/model/blood_pressure/record.dart';
import 'package:blood_pressure_app/model/export_import/csv_converter.dart';
import 'package:blood_pressure_app/model/export_import/csv_record_parsing_actor.dart';
import 'package:blood_pressure_app/model/export_import/pdf_converter.dart';
import 'package:blood_pressure_app/model/storage/export_columns_store.dart';
import 'package:blood_pressure_app/model/storage/export_csv_settings_store.dart';
import 'package:blood_pressure_app/model/storage/export_pdf_settings_store.dart';
import 'package:blood_pressure_app/model/storage/export_settings_store.dart';
import 'package:blood_pressure_app/model/storage/interval_store.dart';
import 'package:blood_pressure_app/model/storage/settings_store.dart';
import 'package:blood_pressure_app/platform_integration/platform_client.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:health_data_store/health_data_store.dart';
import 'package:path/path.dart';
import 'package:persistent_user_dir_access_android/persistent_user_dir_access_android.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';

/// Button row to export and import the current configuration.
class ExportButtonBar extends StatelessWidget {
  /// Create buttons for im- and exporting measurements.
  const ExportButtonBar({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Container(
      height: 60,
      color: Theme.of(context).colorScheme.onInverseSurface,
      child: Center(
        child: Row(
        children: [
          Expanded(
            flex: 50,
            child: MaterialButton(
              height: 60,
              child: Text(localizations.export),
              onPressed: () => performExport(context, localizations),
            ),
          ),
          const VerticalDivider(),
          Expanded(
            flex: 50,
            child: MaterialButton(
              height: 60,
              child: Text(localizations.import),
              onPressed: () async {
                final messenger = ScaffoldMessenger.of(context);

                final file = (await FilePicker.platform.pickFiles(
                  withData: true,
                ))?.files.firstOrNull;
                if (file == null) {
                  _showError(messenger, localizations.errNoFileOpened);
                  return;
                }
                if (!context.mounted) return;
                switch(file.extension?.toLowerCase()) {
                  case 'csv':
                    final binaryContent = file.bytes;
                    if (binaryContent == null) {
                      _showError(messenger, localizations.errCantReadFile);
                      return;
                    }
                    if (!context.mounted) return;
                    final converter = CsvConverter(
                      Provider.of<CsvExportSettings>(context, listen: false),
                      Provider.of<ExportColumnsManager>(context, listen: false),
                      await RepositoryProvider.of<MedicineRepository>(context).getAll(),
                    );
                    if (!context.mounted) return;
                    final importedRecords = await showImportPreview(
                      context,
                      CsvRecordParsingActor(
                        converter,
                        utf8.decode(binaryContent),
                      ),
                      Provider.of<ExportColumnsManager>(context, listen: false),
                      Provider.of<Settings>(context, listen: false).bottomAppBars,
                    );
                    if (importedRecords == null || !context.mounted) return;
                    final bpRepo = RepositoryProvider.of<BloodPressureRepository>(context);
                    final noteRepo = RepositoryProvider.of<NoteRepository>(context);
                    final intakeRepo = RepositoryProvider.of<MedicineIntakeRepository>(context);
                    await Future.forEach<FullEntry>(importedRecords, (e) async {
                      if (e.sys != null || e.dia != null || e.pul != null) {
                        await bpRepo.add(e.$1);
                      }
                      if (e.note != null || e.color != null) {
                        await noteRepo.add(e.$2);
                      }
                      if (e.$3.isNotEmpty) {
                        await Future.forEach(e.$3, intakeRepo.add);
                      }
                    });
                    messenger.showSnackBar(SnackBar(content: Text(
                      localizations.importSuccess(importedRecords.length),),),);
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

                    try { // Update legacy format
                      final model = (records.isNotEmpty || notes.isNotEmpty || intakes.isNotEmpty)
                        ? null
                        : await BloodPressureModel.create(dbPath: file.path!, isFullPath: true);
                      for (final OldBloodPressureRecord oldR in (await model?.all) ?? []) {
                        if (oldR.systolic != null || oldR.diastolic != null || oldR.pulse != null) {
                          records.add(BloodPressureRecord(
                            time: oldR.creationTime,
                            sys: oldR.systolic == null ? null :Pressure.mmHg(oldR.systolic!),
                            dia: oldR.diastolic == null ? null :Pressure.mmHg(oldR.diastolic!),
                            pul: oldR.pulse,
                          ));
                        }
                        if (oldR.notes.isNotEmpty || oldR.needlePin != null) {
                          notes.add(Note(
                            time: oldR.creationTime,
                            note: oldR.notes.isEmpty ? null : oldR.notes,
                            color: oldR.needlePin?.color.value,
                          ));
                        }
                      }
                      await model?.close();
                    } catch (e) {
                      // DB not importable
                    }

                    await Future.forEach(records, bpRepo.add);
                    await Future.forEach(notes, noteRepo.add);
                    await Future.forEach(intakes, intakeRepo.add);

                    messenger.showSnackBar(SnackBar(content: Text(
                      localizations.importSuccess(records.length),),),);
                    break;
                  default:
                    _showError(messenger, localizations.errWrongImportFormat);
                }
              },
            ),
          ),
          ],
        ),
      ),
    );
  }

  void _showError(ScaffoldMessengerState messenger, String text) =>
      messenger.showSnackBar(SnackBar(content: Text(text)));
}

/// Perform a full export according to the configuration in [context].
void performExport(BuildContext context, [AppLocalizations? localizations]) async { // TODO: extract
  localizations ??= AppLocalizations.of(context);
  final exportSettings = Provider.of<ExportSettings>(context, listen: false);
  final filename = 'blood_press_${DateTime.now().toIso8601String()}';
  switch (exportSettings.exportFormat) {
    case ExportFormat.db:
      final path = join(await getDatabasesPath(), 'bp.db');
      final data = await File(path).readAsBytes();

      if (context.mounted) await _exportData(context, data, '$filename.db', 'application/vnd.sqlite3');
      break;
    case ExportFormat.csv:
      final csvConverter = CsvConverter(
        Provider.of<CsvExportSettings>(context, listen: false),
        Provider.of<ExportColumnsManager>(context, listen: false),
        await RepositoryProvider.of<MedicineRepository>(context).getAll(),
      );
      final csvString = csvConverter.create(await _getEntries(context));
      final data = Uint8List.fromList(utf8.encode(csvString));
      if (context.mounted) await _exportData(context, data, '$filename.csv', 'text/csv');
      break;
    case ExportFormat.pdf:
      final pdfConverter = PdfConverter(
          Provider.of<PdfExportSettings>(context, listen: false),
          localizations!,
          Provider.of<Settings>(context, listen: false),
          Provider.of<ExportColumnsManager>(context, listen: false),
      );
      final pdf = await pdfConverter.create(await _getEntries(context));
      if (context.mounted) await _exportData(context, pdf, '$filename.pdf', 'text/pdf');
  }
}

/// Get the records that should be exported (oldest first).
Future<List<FullEntry>> _getEntries(BuildContext context) async {
  final range = Provider.of<IntervalStoreManager>(context, listen: false).exportPage.currentRange;
  final bpRepo = RepositoryProvider.of<BloodPressureRepository>(context);
  final noteRepo = RepositoryProvider.of<NoteRepository>(context);
  final intakeRepo = RepositoryProvider.of<MedicineIntakeRepository>(context);

  final records = await bpRepo.get(range);
  final notes = await noteRepo.get(range);
  final intakes = await intakeRepo.get(range);

  final entries = FullEntryList.merged(records, notes, intakes);
  entries.sort((a, b) => a.time.compareTo(b.time));
  return entries;
}

/// Save to default export path or share by providing binary data.
Future<void> _exportData(BuildContext context, Uint8List data, String fullFileName, String mimeType) async {
  final settings = Provider.of<ExportSettings>(context, listen: false);
  if (settings.defaultExportDir.isEmpty) {
    await PlatformClient.shareData(data, mimeType, fullFileName);
  } else {
    const userDir = PersistentUserDirAccessAndroid();
    await userDir.writeFile(settings.defaultExportDir, fullFileName, mimeType, data);
  }
}
