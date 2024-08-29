import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive_io.dart';
import 'package:blood_pressure_app/components/input_dialoge.dart';
import 'package:blood_pressure_app/data_util/consistent_future_builder.dart';
import 'package:blood_pressure_app/features/settings/delete_data_screen.dart';
import 'package:blood_pressure_app/features/settings/enter_timeformat_dialoge.dart';
import 'package:blood_pressure_app/features/settings/export_import_screen.dart';
import 'package:blood_pressure_app/features/settings/graph_markings_screen.dart';
import 'package:blood_pressure_app/features/settings/medicine_manager_screen.dart';
import 'package:blood_pressure_app/features/settings/tiles/color_picker_list_tile.dart';
import 'package:blood_pressure_app/features/settings/tiles/dropdown_list_tile.dart';
import 'package:blood_pressure_app/features/settings/tiles/number_input_list_tile.dart';
import 'package:blood_pressure_app/features/settings/tiles/slider_list_tile.dart';
import 'package:blood_pressure_app/features/settings/tiles/titled_column.dart';
import 'package:blood_pressure_app/features/settings/version_screen.dart';
import 'package:blood_pressure_app/features/settings/warn_about_screen.dart';
import 'package:blood_pressure_app/model/blood_pressure/pressure_unit.dart';
import 'package:blood_pressure_app/model/blood_pressure/warn_values.dart';
import 'package:blood_pressure_app/model/iso_lang_names.dart';
import 'package:blood_pressure_app/model/storage/db/config_db.dart';
import 'package:blood_pressure_app/model/storage/db/file_settings_loader.dart';
import 'package:blood_pressure_app/model/storage/db/settings_loader.dart';
import 'package:blood_pressure_app/model/storage/export_columns_store.dart';
import 'package:blood_pressure_app/model/storage/storage.dart';
import 'package:blood_pressure_app/platform_integration/platform_client.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

/// Primary settings page to manage basic settings and link to subsettings.
class SettingsPage extends StatelessWidget {
  /// Create a primary settings screen.
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.settings),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Consumer<Settings>(builder: (context, settings, child) => ListView(
          children: [
            TitledColumn(title: Text(localizations.layout), children: [
              ListTile(
                key: const Key('EnterTimeFormatScreen'),
                title: Text(localizations.enterTimeFormatScreen),
                subtitle: Text(settings.dateFormatString),
                leading: const Icon(Icons.schedule),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () async {
                  final pickedFormat = await showTimeFormatPickerDialoge(context,
                      settings.dateFormatString,
                      settings.bottomAppBars,);
                  if (pickedFormat != null) {
                    settings.dateFormatString = pickedFormat;
                  }
                },
              ),
              DropDownListTile<ThemeMode>(
                leading: const Icon(Icons.brightness_4),
                title: Text(localizations.theme),
                value: settings.themeMode,
                items: [
                  DropdownMenuItem(value: ThemeMode.system, child: Text(localizations.system)),
                  DropdownMenuItem(value: ThemeMode.dark, child: Text(localizations.dark)),
                  DropdownMenuItem(value: ThemeMode.light, child: Text(localizations.light)),
                ],
                onChanged: (ThemeMode? value) {
                  if (value != null) settings.themeMode = value;
                },
              ),
              ColorSelectionListTile(
                onMainColorChanged: (color) => settings.accentColor = color,
                initialColor: settings.accentColor,
                title: Text(localizations.accentColor),),
              DropDownListTile<Locale?>(
                leading: const Icon(Icons.language),
                title: Text(localizations.language),
                value: settings.language,
                items: [
                  DropdownMenuItem(child: Text(localizations.system)),
                  for (final l in AppLocalizations.supportedLocales)
                    DropdownMenuItem(value: l, child: Text(getDisplayLanguage(l))),
                ],
                onChanged: (Locale? value) {
                  settings.language = value;
                },
              ),
              SliderListTile(
                title: Text(localizations.graphLineThickness),
                leading: const Icon(Icons.line_weight),
                onChanged: (double value) {
                  settings.graphLineThickness = value;
                },
                value: settings.graphLineThickness,
                min: 1,
                max: 5,
              ),
              SliderListTile(
                title: Text(localizations.needlePinBarWidth),
                subtitle: Text(localizations.needlePinBarWidthDesc),
                leading: const Icon(Icons.line_weight),
                onChanged: (double value) {
                  settings.needlePinBarWidth = value;
                },
                value: settings.needlePinBarWidth,
                min: 1,
                max: 20,
              ),
              SliderListTile(
                title: Text(localizations.animationSpeed),
                leading: const Icon(Icons.speed),
                onChanged: (double value) {
                  settings.animationSpeed = value.toInt();
                },
                value: settings.animationSpeed.toDouble(),
                min: 0,
                max: 1000,
                stepSize: 50,
              ),
              ColorSelectionListTile(
                onMainColorChanged: (color) => settings.sysColor = color,
                initialColor: settings.sysColor,
                  title: Text(localizations.sysColor),),
              ColorSelectionListTile(
                onMainColorChanged: (color) => settings.diaColor = color,
                initialColor: settings.diaColor,
                title: Text(localizations.diaColor),),
              ColorSelectionListTile(
                onMainColorChanged: (color) => settings.pulColor = color,
                initialColor: settings.pulColor,
                title: Text(localizations.pulColor),),
              SwitchListTile(
                value: settings.compactList,
                onChanged: (value) {
                  settings.compactList = value;
                },
                secondary: const Icon(Icons.list_alt_outlined),
                title: Text(localizations.compactList),),
            ],),

            TitledColumn(title: Text(localizations.behavior), children: [
              ListTile(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder:
                      (context) => const MedicineManagerScreen(),),);
                },
                leading: const Icon(Icons.medication),
                title: Text(localizations.medications),
                trailing: const Icon(Icons.arrow_forward_ios),
              ),
              SwitchListTile(
                value: settings.bleInput,
                onChanged: (Platform.isAndroid || Platform.isIOS || Platform.isMacOS)
                  ? (value) { settings.bleInput = value; }
                  : null,
                secondary: const Icon(Icons.bluetooth),
                title: Text(localizations.bluetoothInput),
                subtitle: (Platform.isAndroid || Platform.isIOS || Platform.isMacOS)
                  ? null
                  : Text(localizations.errFeatureNotSupported),
              ),
              SwitchListTile(
                value: settings.allowManualTimeInput,
                onChanged: (value) {
                  settings.allowManualTimeInput = value;
                },
                secondary: const Icon(Icons.details),
                title: Text(localizations.allowManualTimeInput),),
              SwitchListTile(
                value: settings.validateInputs,
                title: Text(localizations.validateInputs),
                secondary: const Icon(Icons.edit),
                onChanged: settings.allowMissingValues ? null : (value) {
                  assert(!settings.allowMissingValues);
                  settings.validateInputs = value;
                },),
              SwitchListTile(
                value: settings.allowMissingValues,
                title: Text(localizations.allowMissingValues),
                secondary: const Icon(Icons.report_off_outlined),
                onChanged: (value) {
                  settings.allowMissingValues = value;
                  if (value) settings.validateInputs = false;
                },),
              SwitchListTile(
                value: settings.confirmDeletion,
                title: Text(localizations.confirmDeletion),
                secondary: const Icon(Icons.check),
                onChanged: (value) {
                  settings.confirmDeletion = value;
                },),
              NumberInputListTile(
                label: localizations.sysWarn,
                leading: const Icon(Icons.warning_amber_outlined),
                value: settings.sysWarn,
                onParsableSubmit: (double value) {
                  settings.sysWarn = value.round();
                },
              ),
              NumberInputListTile(
                label: localizations.diaWarn,
                leading: const Icon(Icons.warning_amber_outlined),
                value: settings.diaWarn,
                onParsableSubmit: (double value) {
                  settings.diaWarn = value.round();
                },
              ),
              ListTile(
                leading: const Icon(Icons.settings_applications_outlined),
                title: Text(localizations.determineWarnValues),
                onTap: () async {
                  final age = (await showNumberInputDialoge(context,
                    hintText: localizations.age,
                  ))?.round();
                  if (age != null) {
                    settings.sysWarn = BloodPressureWarnValues.getUpperSysWarnValue(age);
                    settings.diaWarn = BloodPressureWarnValues.getUpperDiaWarnValue(age);
                  }
                },
              ),
              ListTile(
                title: Text(localizations.aboutWarnValuesScreen),
                subtitle: Text(localizations.aboutWarnValuesScreenDesc),
                leading: const Icon(Icons.info_outline),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AboutWarnValuesScreen()),
                  );
                },
              ),
              ListTile(
                title: Text(localizations.customGraphMarkings),
                leading: const Icon(Icons.legend_toggle_outlined),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const GraphMarkingsScreen()),
                  );
                },
              ),
              SwitchListTile(
                title: Text(localizations.drawRegressionLines),
                secondary: const Icon(Icons.trending_down_outlined),
                subtitle: Text(localizations.drawRegressionLinesDesc),
                value: settings.drawRegressionLines,
                onChanged: (value) {
                  settings.drawRegressionLines = value;
                },
              ),
              SwitchListTile(
                title: Text(localizations.startWithAddMeasurementPage),
                subtitle: Text(localizations.startWithAddMeasurementPageDescription),
                secondary: const Icon(Icons.electric_bolt_outlined),
                value: settings.startWithAddMeasurementPage,
                onChanged: (value) {
                  settings.startWithAddMeasurementPage = value;
                },
              ),
              SwitchListTile(
                title: Text(localizations.bottomAppBars),
                secondary: const Icon(Icons.vertical_align_bottom),
                value: settings.bottomAppBars,
                onChanged: (value) {
                  settings.bottomAppBars = value;
                },
              ),
              DropDownListTile<PressureUnit?>(
                leading: const Icon(Icons.language),
                title: Text(localizations.preferredPressureUnit),
                value: settings.preferredPressureUnit,
                items: [
                  for (final u in PressureUnit.values)
                    DropdownMenuItem(
                      value: u,
                      child: Text(u.name),
                    ),
                ],
                onChanged: (PressureUnit? value) {
                  if (value != null) settings.preferredPressureUnit = value;
                },
              ),
            ],),
            TitledColumn(
              title: Text(localizations.data),
              children: [
                ListTile(
                  title: Text(localizations.exportImport),
                  leading: const Icon(Icons.download),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ExportImportScreen()),
                    );
                  },
                ),
                ListTile(
                  title: Text(localizations.exportSettings),
                  leading: const Icon(Icons.tune),
                  onTap: () async {
                    final loader = await FileSettingsLoader.load();
                    final archive = loader.createArchive();
                    if (archive == null) {
                      print(1);
                      // TODO: err msg
                      return;
                    }
                    final compressedArchive = ZipEncoder().encode(archive);
                    if (compressedArchive == null) {
                      print(2);
                      // TODO: err msg
                      return;
                    }
                    final archiveData = Uint8List.fromList(compressedArchive);
                    await PlatformClient.shareData(archiveData, 'application/zip', 'bloodPressureSettings.zip');
                  },
                ),
                ListTile(
                  title: Text(localizations.importSettings),
                  subtitle: Text(localizations.requiresAppRestart),
                  leading: const Icon(Icons.settings_backup_restore),
                  onTap: () async {
                    final messenger = ScaffoldMessenger.of(context);
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
                        final decoded = ZipDecoder().decodeBytes(result.files.single.bytes ?? []); //FIXME
                        final dir = join(Directory.systemTemp.path, 'settingsBackup');
                        await extractArchiveToDisk(decoded, dir);
                        loader = await FileSettingsLoader.load(dir);
                      } on FormatException {
                        // TODO
                      }
                    } else {
                      messenger.showSnackBar(SnackBar(content: Text(localizations.errNotImportable)));
                      return;
                    }
                    settings.copyFrom(await loader.loadSettings());
                    context.read<ExportSettings>().copyFrom(await loader.loadExportSettings());
                    context.read<CsvExportSettings>().copyFrom(await loader.loadCsvExportSettings());
                    context.read<PdfExportSettings>().copyFrom(await loader.loadPdfExportSettings());
                    context.read<IntervalStoreManager>().copyFrom(await loader.loadIntervalStorageManager());
                    context.read<ExportColumnsManager>().copyFrom(await loader.loadExportColumnsManager());
                    messenger.showSnackBar(SnackBar(content: Text(localizations.success(localizations.importSettings))));
                  },
                ),
                ListTile(
                  title: Text(localizations.delete),
                  leading: const Icon(Icons.delete),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const DeleteDataScreen()),
                    );
                  },
                ),
              ],
            ),
            TitledColumn(title: Text(localizations.aboutWarnValuesScreen), children: [
              ListTile(
                  title: Text(localizations.version),
                  leading: const Icon(Icons.info_outline),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  subtitle: ConsistentFutureBuilder<PackageInfo>(
                    future: PackageInfo.fromPlatform(),
                    cacheFuture: true,
                    onData: (context, info) => Text(info.version),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const VersionScreen()),
                    );
                  },
              ),
              ListTile(
                title: Text(localizations.sourceCode),
                leading: const Icon(Icons.merge),
                trailing: const Icon(Icons.open_in_new),
                onTap: () async {
                  final scaffoldMessenger = ScaffoldMessenger.of(context);
                  final url = Uri.parse('https://github.com/NobodyForNothing/blood-pressure-monitor-fl');
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
                onTap: () {
                  showLicensePage(context: context);
                },
              ),
            ],),
          ],
        ),),
    );
  }
}
