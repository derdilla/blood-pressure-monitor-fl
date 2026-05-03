import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:blood_pressure_app/data_util/consistent_future_builder.dart';
import 'package:blood_pressure_app/features/health_connect/health_connect_screen.dart';
import 'package:blood_pressure_app/features/settings/behavior_screen.dart';
import 'package:blood_pressure_app/features/settings/delete_data_screen.dart';
import 'package:blood_pressure_app/features/settings/export_import_screen.dart';
import 'package:blood_pressure_app/features/settings/features_screen.dart';
import 'package:blood_pressure_app/features/settings/graph_screen.dart';
import 'package:blood_pressure_app/features/settings/style_screen.dart';
import 'package:blood_pressure_app/features/settings/tiles/titled_column.dart';
import 'package:blood_pressure_app/features/settings/version_screen.dart';
import 'package:blood_pressure_app/l10n/app_localizations.dart';
import 'package:blood_pressure_app/logging.dart';
import 'package:blood_pressure_app/model/storage/db/config_db.dart';
import 'package:blood_pressure_app/model/storage/db/file_settings_loader.dart';
import 'package:blood_pressure_app/model/storage/db/settings_loader.dart';
import 'package:blood_pressure_app/model/storage/export_columns_store.dart';
import 'package:blood_pressure_app/model/storage/storage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

/// Primary settings page to manage basic settings and link to subsettings.
class SettingsPage extends StatelessWidget {
  /// Create a primary settings screen.
  const SettingsPage({super.key});

  void Function() thenGoTo(BuildContext context,
      Widget Function(BuildContext context) builder) => () {
      Navigator.push(
        context,
        MaterialPageRoute<void>(builder: builder),
      );
    };

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final settings = context.watch<Settings>();
    return Material(
      child: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar.large(
              title: Text(localizations.settings),
              backgroundColor: Theme.of(context).primaryColor,
            ),
            SliverToBoxAdapter(
              child: TitledColumn(title: Text(localizations.generalSettingsSection), children: [
                ListTile(
                  title: Text(localizations.featuresSetting),
                  leading: const Icon(Icons.toggle_off_outlined),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: thenGoTo(context, (_) => const FeaturesScreen()),
                ),
                ListTile(
                  title: Text(localizations.behavior),
                  leading: const Icon(Icons.settings),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: thenGoTo(context, (_) => const BehaviorScreen()),
                ),
                ListTile(
                  title: Text(localizations.graphSettings),
                  leading: const Icon(Icons.trending_down_outlined),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: thenGoTo(context, (_) => const GraphScreen()),
                ),
                ListTile(
                  title: Text(localizations.appStyleSettings),
                  leading: const Icon(Icons.color_lens_outlined),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: thenGoTo(context, (_) => const StyleScreen()),
                ),
              ]),
            ),
            SliverToBoxAdapter(
              child: TitledColumn(
                title: Text(localizations.data),
                children: [
                  ListTile(
                    title: Text(localizations.healthConnect),
                    leading: const Icon(Icons.sync),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: thenGoTo(context, (_) => const HealthConnectScreen()),
                  ),
                  ListTile(
                    title: Text(localizations.exportImport),
                    leading: const Icon(Icons.download),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: thenGoTo(context, (_) => const ExportImportScreen()),
                  ),
                  ListTile(
                    title: Text(localizations.delete),
                    leading: const Icon(Icons.delete),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: thenGoTo(context, (_) => const DeleteDataScreen()),
                  ),
                ],
              ),
            ),
            SliverToBoxAdapter(
              child: TitledColumn(title: Text(localizations.aboutWarnValuesScreen), children: [
                ListTile(
                    title: Text(localizations.version),
                    leading: const Icon(Icons.info_outline),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    subtitle: ConsistentFutureBuilder<PackageInfo>(
                      future: PackageInfo.fromPlatform(),
                      cacheFuture: true,
                      onData: (context, info) => Text(info.version),
                    ),
                    onTap: thenGoTo(context, (_) => const VersionScreen()),
                ),
                ListTile(
                  title: Text(localizations.sourceCode),
                  leading: const Icon(Icons.merge),
                  trailing: const Icon(Icons.open_in_new),
                  onTap: () async {
                    final scaffoldMessenger = ScaffoldMessenger.of(context);
                    final url = Uri.parse('https://github.com/derdilla/blood-pressure-monitor-fl');
                    if (await canLaunchUrl(url)) {
                      await launchUrl(url, mode: LaunchMode.externalApplication);
                    } else {
                      scaffoldMessenger.showSnackBar(SnackBar(
                          content: Text(localizations.errCantOpenURL(url.toString())),),);
                    }
                  },
                ),
                ListTile(
                  title: Text(localizations.licenses),
                  leading: const Icon(Icons.policy_outlined),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () => showLicensePage(context: context),
                ),
                ListTile(
                  title: Text(localizations.exportSettings),
                  leading: const Icon(Icons.tune),
                  onTap: () async {
                    final messenger = ScaffoldMessenger.of(context);
                    final loader = await FileSettingsLoader.load();
                    final archive = loader.createArchive();
                    if (archive == null) {
                      messenger.showSnackBar(SnackBar(content: Text(localizations.errCantCreateArchive)));
                      return;
                    }
                    final compressedArchive = ZipEncoder().encodeBytes(archive);
                    await FilePicker.platform.saveFile(
                      type: FileType.any, // application/zip
                      fileName: 'bloodPressureSettings.zip',
                      bytes: compressedArchive,
                    );
                  },
                ),
                ListTile(
                  title: Text(localizations.importSettings),
                  subtitle: Text(localizations.requiresAppRestart),
                  leading: const Icon(Icons.settings_backup_restore),
                  onTap: () async {
                    final messenger = ScaffoldMessenger.of(context);
                    final exportSettings = context.read<ExportSettings>();
                    final csvExportSettings = context.read<CsvExportSettings>();
                    final pdfExportSettings = context.read<PdfExportSettings>();
                    final xlsExportSettings = context.read<ExcelExportSettings>();
                    final healthConnectSettings = context.read<HealthConnectSettings>();
                    final intervalStoreManager = context.read<IntervalStoreManager>();
                    final exportColumnsManager = context.read<ExportColumnsManager>();
                    final result = await FilePicker.platform.pickFiles();
                    if (result == null) {
                      messenger.showSnackBar(SnackBar(content: Text(localizations.errNoFileOpened)));
                      return;
                    }
                    final path = result.files.single.path;
                    if (path == null) {
                      messenger.showSnackBar(SnackBar(content: Text(localizations.errCantReadFile)));
                      return;
                    }

                    late SettingsLoader loader;
                    if (path.endsWith('db')) {
                      final configDB = await ConfigDB.open(dbPath: path, isFullPath: true);
                      if(configDB == null) return; // too old (doesn't contain settings yet)
                      loader = ConfigDao(configDB);
                    } else if (path.endsWith('zip')) {
                      try {
                        final decoded = ZipDecoder().decodeStream(InputFileStream(result.files.single.path!));
                        final dir = join(Directory.systemTemp.path, 'settingsBackup');
                        await extractArchiveToDisk(decoded, dir);
                        loader = await FileSettingsLoader.load(dir);
                      } on FormatException catch (e, stack) {
                        messenger.showSnackBar(SnackBar(content: Text(localizations.invalidZip)));
                        log.severe('invalid zip', e, stack);
                        return;
                      }
                    } else {
                      messenger.showSnackBar(SnackBar(content: Text(localizations.errNotImportable)));
                      return;
                    }

                    settings.copyFrom(await loader.loadSettings());
                    exportSettings.copyFrom(await loader.loadExportSettings());
                    csvExportSettings.copyFrom(await loader.loadCsvExportSettings());
                    pdfExportSettings.copyFrom(await loader.loadPdfExportSettings());
                    xlsExportSettings.copyFrom(await loader.loadXlsExportSettings());
                    healthConnectSettings.copyFrom(await loader.loadHealthConnectSettings());
                    intervalStoreManager.copyFrom(await loader.loadIntervalStorageManager());
                    exportColumnsManager.copyFrom(await loader.loadExportColumnsManager());

                    messenger.showSnackBar(SnackBar(content: Text(localizations.success(localizations.importSettings))));
                  },
                ),
              ],),
            ),
          ],
        ),
      ),
    );
  }
}
