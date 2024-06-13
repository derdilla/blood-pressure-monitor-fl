import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:blood_pressure_app/components/dialoges/import_preview_dialoge.dart';
import 'package:blood_pressure_app/model/export_import/csv_converter.dart';
import 'package:blood_pressure_app/model/export_import/csv_record_parsing_actor.dart';
import 'package:blood_pressure_app/model/export_import/pdf_converter.dart';
import 'package:blood_pressure_app/model/storage/export_columns_store.dart';
import 'package:blood_pressure_app/model/storage/export_csv_settings_store.dart';
import 'package:blood_pressure_app/model/storage/export_pdf_settings_store.dart';
import 'package:blood_pressure_app/model/storage/export_settings_store.dart';
import 'package:blood_pressure_app/model/storage/intervall_store.dart';
import 'package:blood_pressure_app/model/storage/settings_store.dart';
import 'package:blood_pressure_app/platform_integration/platform_client.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:health_data_store/health_data_store.dart';
import 'package:jsaver/jSaver.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';

// FIXME: import and export all datatypes (intakes, ...)

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
                    final converter = CsvConverter(
                      Provider.of<CsvExportSettings>(context, listen: false),
                      Provider.of<ExportColumnsManager>(context, listen: false),
                    );
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
                    final repo = context.read<BloodPressureRepository>();
                    await Future.forEach<BloodPressureRecord>(importedRecords, repo.add);
                    messenger.showSnackBar(SnackBar(content: Text(
                      localizations.importSuccess(importedRecords.length),),),);
                    break;
                  case 'db':
                    if (file.path == null) return;
                    final repo = context.read<BloodPressureRepository>();
                    final importedDB = await HealthDataStore.load(await openReadOnlyDatabase(file.path!));
                    await Future.forEach(
                      await importedDB.bpRepo.get(DateRange.all()),
                      repo.add,
                    );
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
void performExport(BuildContext context, [AppLocalizations? localizations]) async {
  localizations ??= AppLocalizations.of(context);
  final exportSettings = Provider.of<ExportSettings>(context, listen: false);
  final filename = 'blood_press_${DateTime.now().toIso8601String()}';
  switch (exportSettings.exportFormat) {
    case ExportFormat.db:
      final path = join(await getDatabasesPath(), 'blood_pressure.db');

      if (context.mounted) await _exportFile(context, path, '$filename.db', 'text/sqlite');
      break;
    case ExportFormat.csv:
      final csvConverter = CsvConverter(
        Provider.of<CsvExportSettings>(context, listen: false),
        Provider.of<ExportColumnsManager>(context, listen: false),
      );
      final csvString = csvConverter.create(await _getRecords(context));
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
      final pdf = await pdfConverter.create(await _getRecords(context));
      if (context.mounted) await _exportData(context, pdf, '$filename.pdf', 'text/pdf');
  }
}

/// Get the records that should be exported.
Future<List<BloodPressureRecord>> _getRecords(BuildContext context) {
  final range = Provider.of<IntervallStoreManager>(context, listen: false).exportPage.currentRange;
  final model = RepositoryProvider.of<BloodPressureRepository>(context);
  return model.get(range);
}

/// Save to default export path or share by providing a path.
Future<void> _exportFile(BuildContext context, String path, String fullFileName, String mimeType) async {
  final settings = Provider.of<ExportSettings>(context, listen: false);
  if (settings.defaultExportDir.isEmpty) {
    await PlatformClient.shareFile(path, mimeType, fullFileName);
  } else {
    await JSaver.instance.save(
        fromPath: path,
        androidPathOptions: AndroidPathOptions(toDefaultDirectory: true),
    );
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(AppLocalizations.of(context)!.success(settings.defaultExportDir)),),);
  }
}

/// Save to default export path or share by providing binary data.
Future<void> _exportData(BuildContext context, Uint8List data, String fullFileName, String mimeType) async {
  final settings = Provider.of<ExportSettings>(context, listen: false);
  if (settings.defaultExportDir.isEmpty) {
    await PlatformClient.shareData(data, mimeType, fullFileName);
  } else {
    final file = File(joinPath(Directory.systemTemp.path, fullFileName));
    file.writeAsBytesSync(data);
    await _exportFile(context, file.path, fullFileName, mimeType);
  }
}
