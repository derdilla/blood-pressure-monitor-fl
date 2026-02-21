import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:blood_pressure_app/l10n/app_localizations.dart';
import 'package:blood_pressure_app/logging.dart';
import 'package:blood_pressure_app/model/export_import/csv_converter.dart';
import 'package:blood_pressure_app/model/export_import/excel_converter.dart';
import 'package:blood_pressure_app/model/export_import/pdf_converter.dart';
import 'package:blood_pressure_app/model/storage/export_columns_store.dart';
import 'package:blood_pressure_app/model/storage/export_csv_settings_store.dart';
import 'package:blood_pressure_app/model/storage/export_pdf_settings_store.dart';
import 'package:blood_pressure_app/model/storage/export_settings_store.dart';
import 'package:blood_pressure_app/model/storage/export_xsl_settings_store.dart';
import 'package:blood_pressure_app/model/storage/interval_store.dart';
import 'package:blood_pressure_app/model/storage/settings_store.dart';
import 'package:collection/collection.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_data_store/health_data_store.dart';
import 'package:logging/logging.dart';
import 'package:path/path.dart';
import 'package:persistent_user_dir_access_android/persistent_user_dir_access_android.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sqflite/sqflite.dart';

/// Text button to export entries like configured in the context.
class ExportButton extends StatelessWidget {
  /// Create a text button to export entries like configured in the context.
  const ExportButton({
    super.key,
    required this.share,
  });

  /// Whether to use the device sharing feature instead of the saving feature
  /// for export.
  final bool share;

  @override
  Widget build(BuildContext context) => TextButton.icon(
    label: Text(share ? AppLocalizations.of(context)!.btnShare : AppLocalizations.of(context)!.export),
    icon: Icon(share ? Icons.share : Icons.file_download_outlined),
    onPressed: () => performExport(context, share),
  );
}

Logger _logger = Logger('BPM[export_button]');

/// Perform a full export according to the configuration in [context].
void performExport(BuildContext context, bool share) async { // TODO: extract
  _logger.finer('performExport - mounted=${context.mounted}');
  final localizations = AppLocalizations.of(context);
  final exportSettings = Provider.of<ExportSettings>(context, listen: false);
  _logger.fine('performExport - exportSettings=${exportSettings.toJson()}');
  final filename = 'blood_press_${DateTime.now().toIso8601String()}';
  switch (exportSettings.exportFormat) {
    case ExportFormat.db:
      final path = join(await getDatabasesPath(), 'bp.db');
      final data = await File(path).readAsBytes();

      if (context.mounted) await _exportData(context, data, '$filename.db', 'application/vnd.sqlite3', share);
      break;
    case ExportFormat.csv:
      final csvSettings = Provider.of<CsvExportSettings>(context, listen: false);
      final exportColumnsManager = Provider.of<ExportColumnsManager>(context, listen: false);
      final csvConverter = CsvConverter(
        csvSettings,
        exportColumnsManager,
        await RepositoryProvider.of<MedicineRepository>(context).getAll(),
      );
      if (!context.mounted) {
        _logger.warning('performExport - No longer mounted: stopping export');
        return;
      }
      final csvString = csvConverter.create(await _getEntries(context));
      _logger.fine('performExport - Created csvString=$csvString');
      final data = Uint8List.fromList(utf8.encode(csvString));
      if (context.mounted) {
        _logger.finer('performExport - Calling _exportData');
        await _exportData(context, data, '$filename.csv', 'text/csv', share);
      } else  {
        _logger.warning('performExport - No longer mounted: stopping export');
      }
      break;
    case ExportFormat.pdf:
      final pdfConverter = PdfConverter(
          Provider.of<PdfExportSettings>(context, listen: false),
          localizations!,
          Provider.of<Settings>(context, listen: false),
          Provider.of<ExportColumnsManager>(context, listen: false),
      );
      final pdf = await pdfConverter.create(await _getEntries(context));
      if (context.mounted) await _exportData(context, pdf, '$filename.pdf', 'text/pdf', share);
      break;
    case ExportFormat.xsl:
      final excelExportSettings = Provider.of<ExcelExportSettings>(context,
          listen: false);
      final exportColumnsManager = Provider.of<ExportColumnsManager>(context,
          listen: false);
      final xslConverter = ExcelConverter(
        excelExportSettings,
        exportColumnsManager,
        await RepositoryProvider.of<MedicineRepository>(context).getAll(),
      );
      if (!context.mounted) return;
      final string = xslConverter.create(await _getEntries(context));
      final data = Uint8List.fromList(utf8.encode(string));
      if (context.mounted) await _exportData(context, data, '$filename.xsl', 'application/vnd.ms-excel', share);
      break;
  }

  if (context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(
        children: [
          Icon(Icons.check_circle, color: Colors.green),
          SizedBox(width: 8.0),
          Text(localizations!.exportSuccess),
        ],
      ),
    ));
  }
}

/// Get the records that should be exported (oldest first).
Future<List<(DateTime, BloodPressureRecord, Note, List<MedicineIntake>, Weight?)>> _getEntries(BuildContext context) async {
  final range = Provider.of<IntervalStoreManager>(context, listen: false).exportPage.currentRange;
  _logger.fine('_getEntries - range=$range');
  final bpRepo = RepositoryProvider.of<BloodPressureRepository>(context);
  final noteRepo = RepositoryProvider.of<NoteRepository>(context);
  final intakeRepo = RepositoryProvider.of<MedicineIntakeRepository>(context);
  final weightRepo = RepositoryProvider.of<BodyweightRepository>(context);
  final intervalManager = context.read<IntervalStoreManager>();

  List<BloodPressureRecord> records = await bpRepo.get(range);
  List<Note> notes = await noteRepo.get(range);
  List<MedicineIntake> intakes = await intakeRepo.get(range);
  List<BodyweightRecord> weights = await weightRepo.get(range);

  // Apply time of day filter

  final timeLimitRange = intervalManager
      .get(IntervalStoreManagerLocation.exportPage)
      .timeLimitRange;
  if (timeLimitRange != null) {
    records = records.where((r) {
      final time = TimeOfDay.fromDateTime(r.time);
      return time.isAfter(timeLimitRange.start) && time.isBefore(timeLimitRange.end);
    }).toList();
    intakes = intakes.where((i) {
      final time = TimeOfDay.fromDateTime(i.time);
      return time.isAfter(timeLimitRange.start) && time.isBefore(timeLimitRange.end);
    }).toList();
    notes = notes.where((n) {
      final time = TimeOfDay.fromDateTime(n.time);
      return time.isAfter(timeLimitRange.start) && time.isBefore(timeLimitRange.end);
    }).toList();
    weights = weights.where((w) {
      final time = TimeOfDay.fromDateTime(w.time);
      return time.isAfter(timeLimitRange.start) && time.isBefore(timeLimitRange.end);
    }).toList();
  }

  _logger.finest('_getEntries - range=$range');

  final entries = FullEntryList.merged(records, notes, intakes);
  _logger.fine('_getEntries - merged ${records.length} records, ${notes.length}'
      ' notes, and ${intakes.length} intakes to ${entries.length} entries');

  final entriesWithWeight = entries
      .map((e) => (e.time, e.recordObj, e.noteObj, e.intakes, weights.firstWhereOrNull((w) => e.time == w.time)?.weight))
      .toList();
  for (final e in weights.where((w) => entriesWithWeight.firstWhereOrNull((n) => n.$1 == w.time) == null)) {
    entriesWithWeight.add((e.time, BloodPressureRecord(time: e.time), Note(time: e.time), [], e.weight));
  }

  _logger.fine('_getEntries - added ${weights.length} weights to get'
      ' ${entries.length} entries');

  entriesWithWeight.sort((a, b) => a.$1.compareTo(b.$1));
  return entriesWithWeight;
}

/// Save to default export path or share by providing binary data.
Future<void> _exportData(BuildContext context, Uint8List data, String fullFileName, String mimeType, bool share) async {
  if (share) {
    _logger.fine('_exportData - Saving file using SharePlus');
    final result = await SharePlus.instance.share(ShareParams(
      title: AppLocalizations.of(context)!.bloodPressure,
      files: [XFile.fromData(data, name: fullFileName, mimeType: mimeType)]
    ));
    log.info('_exportData - Shared data with result: $result');
    return;
  }

  final settings = Provider.of<ExportSettings>(context, listen: false);
  if (settings.defaultExportDir.isEmpty || !Platform.isAndroid) {
    _logger.fine('_exportData - Saving file using FilePicker');
    await FilePicker.platform.saveFile(
      type: FileType.any, // mimeType
      fileName: fullFileName,
      bytes: data,
    );
  } else {
    _logger.fine('_exportData - Saving file using PersistentUserDirAccessAndroid');
    const userDir = PersistentUserDirAccessAndroid();
    await userDir.writeFile(settings.defaultExportDir, fullFileName, mimeType, data);
  }
}
