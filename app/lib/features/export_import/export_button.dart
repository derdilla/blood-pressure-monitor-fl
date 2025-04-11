import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:blood_pressure_app/model/export_import/csv_converter.dart';
import 'package:blood_pressure_app/model/export_import/pdf_converter.dart';
import 'package:blood_pressure_app/model/storage/export_columns_store.dart';
import 'package:blood_pressure_app/model/storage/export_csv_settings_store.dart';
import 'package:blood_pressure_app/model/storage/export_pdf_settings_store.dart';
import 'package:blood_pressure_app/model/storage/export_settings_store.dart';
import 'package:blood_pressure_app/model/storage/interval_store.dart';
import 'package:blood_pressure_app/model/storage/settings_store.dart';
import 'package:collection/collection.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:blood_pressure_app/l10n/app_localizations.dart';
import 'package:health_data_store/health_data_store.dart';
import 'package:path/path.dart';
import 'package:persistent_user_dir_access_android/persistent_user_dir_access_android.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';

/// Text button to export entries like configured in the context.
class ExportButton extends StatelessWidget {
  /// Create a text button to export entries like configured in the context.
  const ExportButton({super.key});

  @override
  Widget build(BuildContext context) => TextButton.icon(
    label: Text(AppLocalizations.of(context)!.export),
    icon: Icon(Icons.file_download_outlined),
    onPressed: () => performExport(context),
  );
}

/// Perform a full export according to the configuration in [context].
void performExport(BuildContext context) async { // TODO: extract
  final localizations = AppLocalizations.of(context);
  final exportSettings = Provider.of<ExportSettings>(context, listen: false);
  final filename = 'blood_press_${DateTime.now().toIso8601String()}';
  switch (exportSettings.exportFormat) {
    case ExportFormat.db:
      final path = join(await getDatabasesPath(), 'bp.db');
      final data = await File(path).readAsBytes();

      if (context.mounted) await _exportData(context, data, '$filename.db', 'application/vnd.sqlite3');
      break;
    case ExportFormat.csv:
      final csvSettings = Provider.of<CsvExportSettings>(context, listen: false);
      final exportColumnsManager = Provider.of<ExportColumnsManager>(context, listen: false);
      final csvConverter = CsvConverter(
        csvSettings,
        exportColumnsManager,
        await RepositoryProvider.of<MedicineRepository>(context).getAll(),
      );
      if (!context.mounted) return;
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
Future<List<(DateTime, BloodPressureRecord, Note, List<MedicineIntake>, Weight?)>> _getEntries(BuildContext context) async {
  final range = Provider.of<IntervalStoreManager>(context, listen: false).exportPage.currentRange;
  final bpRepo = RepositoryProvider.of<BloodPressureRepository>(context);
  final noteRepo = RepositoryProvider.of<NoteRepository>(context);
  final intakeRepo = RepositoryProvider.of<MedicineIntakeRepository>(context);
  final weightRepo = RepositoryProvider.of<BodyweightRepository>(context);

  final records = await bpRepo.get(range);
  final notes = await noteRepo.get(range);
  final intakes = await intakeRepo.get(range);
  final weights = await weightRepo.get(range);

  final entries = FullEntryList.merged(records, notes, intakes);

  final entriesWithWeight = entries
      .map((e) => (e.time, e.recordObj, e.noteObj, e.intakes, weights.firstWhereOrNull((w) => e.time == w.time)?.weight))
      .toList();
  for (final e in weights.where((w) => entriesWithWeight.firstWhereOrNull((n) => n.$1 == w.time) == null)) {
    entriesWithWeight.add((e.time, BloodPressureRecord(time: e.time), Note(time: e.time), [], e.weight));
  }

  entriesWithWeight.sort((a, b) => a.$1.compareTo(b.$1));
  return entriesWithWeight;
}

/// Save to default export path or share by providing binary data.
Future<void> _exportData(BuildContext context, Uint8List data, String fullFileName, String mimeType) async {
  final settings = Provider.of<ExportSettings>(context, listen: false);
  if (settings.defaultExportDir.isEmpty || !Platform.isAndroid) {
    await FilePicker.platform.saveFile(
      type: FileType.any, // mimeType
      fileName: fullFileName,
      bytes: data,
    );
  } else {
    const userDir = PersistentUserDirAccessAndroid();
    await userDir.writeFile(settings.defaultExportDir, fullFileName, mimeType, data);
  }
}
