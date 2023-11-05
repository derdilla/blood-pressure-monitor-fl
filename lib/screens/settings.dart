import 'dart:io';

import 'package:blood_pressure_app/components/consistent_future_builder.dart';
import 'package:blood_pressure_app/components/dialoges/enter_timeformat.dart';
import 'package:blood_pressure_app/components/dialoges/input_dialoge.dart';
import 'package:blood_pressure_app/components/settings_widgets.dart';
import 'package:blood_pressure_app/model/blood_pressure.dart';
import 'package:blood_pressure_app/model/iso_lang_names.dart';
import 'package:blood_pressure_app/model/storage/settings_store.dart';
import 'package:blood_pressure_app/platform_integration/platform_client.dart';
import 'package:blood_pressure_app/screens/subsettings/delete_data.dart';
import 'package:blood_pressure_app/screens/subsettings/export_import_screen.dart';
import 'package:blood_pressure_app/screens/subsettings/graph_markings.dart';
import 'package:blood_pressure_app/screens/subsettings/version.dart';
import 'package:blood_pressure_app/screens/subsettings/warn_about.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';
import 'package:restart_app/restart_app.dart';
import 'package:sqflite/sqflite.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.settings),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Consumer<Settings>(builder: (context, settings, child) {
        return ListView(
          children: [
            SettingsSection(title: Text(localizations.layout), children: [
              ListTile(
                key: const Key('EnterTimeFormatScreen'),
                title: Text(localizations.enterTimeFormatScreen),
                subtitle: Text(settings.dateFormatString),
                leading: const Icon(Icons.schedule),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () async {
                  final pickedFormat = await showTimeFormatPickerDialoge(context, settings.dateFormatString);
                  if (pickedFormat != null) {
                    settings.dateFormatString = pickedFormat;
                  }
                },
              ),
              DropDownSettingsTile<ThemeMode>(
                key: const Key('theme'),
                leading: const Icon(Icons.brightness_4),
                title: Text(localizations.theme),
                value: settings.themeMode,
                items: [
                  DropdownMenuItem(value: ThemeMode.system, child: Text(localizations.system)),
                  DropdownMenuItem(value: ThemeMode.dark, child: Text(localizations.dark)),
                  DropdownMenuItem(value: ThemeMode.light, child: Text(localizations.light))
                ],
                onChanged: (ThemeMode? value) {
                  if (value != null) settings.themeMode = value;
                },
              ),
              ColorSelectionListTile(
                key: const Key('accentColor'),
                onMainColorChanged: (color) => settings.accentColor = color,
                initialColor: settings.accentColor,
                title: Text(localizations.accentColor)),
              DropDownSettingsTile<Locale?>(
                key: const Key('language'),
                leading: const Icon(Icons.language),
                title: Text(localizations.language),
                value: settings.language,
                items: [
                  DropdownMenuItem(value: null, child: Text(localizations.system)),
                  for (final l in AppLocalizations.supportedLocales)
                    DropdownMenuItem(value: l, child: Text(getDisplayLanguage(l) ?? l.languageCode)),
                ],
                onChanged: (Locale? value) {
                  settings.language = value;
                },
              ),
              SliderSettingsTile(
                key: const Key('graphLineThickness'),
                title: Text(localizations.graphLineThickness),
                leading: const Icon(Icons.line_weight),
                onChanged: (double value) {
                  settings.graphLineThickness = value;
                },
                initialValue: settings.graphLineThickness,
                start: 1,
                end: 5,
                stepSize: 1,
              ),
              SliderSettingsTile(
                key: const Key('animationSpeed'),
                title: Text(localizations.animationSpeed),
                leading: const Icon(Icons.speed),
                onChanged: (double value) {
                  settings.animationSpeed = value.toInt();
                },
                initialValue: settings.animationSpeed.toDouble(),
                start: 0,
                end: 1000,
                stepSize: 50,
              ),
              ColorSelectionListTile(
                key: const Key('sysColor'),
                onMainColorChanged: (color) => settings.sysColor = color,
                initialColor: settings.sysColor,
                  title: Text(localizations.sysColor)),
              ColorSelectionListTile(
                key: const Key('diaColor'),
                onMainColorChanged: (color) => settings.diaColor = color,
                initialColor: settings.diaColor,
                title: Text(localizations.diaColor)),
              ColorSelectionListTile(
                key: const Key('pulColor'),
                onMainColorChanged: (color) => settings.pulColor = color,
                initialColor: settings.pulColor,
                title: Text(localizations.pulColor)),
              SwitchSettingsTile(
                key: const Key('useLegacyList'),
                initialValue: settings.useLegacyList,
                onToggle: (value) {
                  settings.useLegacyList = value;
                },
                leading: const Icon(Icons.list_alt_outlined),
                title: Text(localizations.useLegacyList)),
            ]),

            SettingsSection(title: Text(localizations.behavior), children: [
              SwitchSettingsTile(
                key: const Key('allowManualTimeInput'),
                initialValue: settings.allowManualTimeInput,
                onToggle: (value) {
                  settings.allowManualTimeInput = value;
                },
                leading: const Icon(Icons.details),
                title: Text(localizations.allowManualTimeInput)),
              SwitchSettingsTile(
                key: const Key('validateInputs'),
                initialValue: settings.validateInputs,
                title: Text(localizations.validateInputs),
                leading: const Icon(Icons.edit),
                onToggle: (value) {
                  settings.validateInputs = value;
                }),
              SwitchSettingsTile(
                key: const Key('allowMissingValues'),
                initialValue: settings.allowMissingValues,
                title: Text(localizations.allowMissingValues),
                leading: const Icon(Icons.report_off_outlined),
                onToggle: (value) {
                  settings.allowMissingValues = value;
                }),
              SwitchSettingsTile(
                key: const Key('confirmDeletion'),
                initialValue: settings.confirmDeletion,
                title: Text(localizations.confirmDeletion),
                leading: const Icon(Icons.check),
                onToggle: (value) {
                  settings.confirmDeletion = value;
                }),
              InputSettingsTile(
                key: const Key('sysWarn'),
                title: Text(localizations.sysWarn),
                leading: const Icon(Icons.warning_amber_outlined),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                initialValue: settings.sysWarn.toInt().toString(),
                onEditingComplete: (String? value) {
                  if (value == null || value.isEmpty || (int.tryParse(value) == null)) {
                    return;
                  }
                  settings.sysWarn = int.parse(value);
                },
                decoration: InputDecoration(hintText: localizations.sysWarn),
                inputWidth: 120,
              ),
              InputSettingsTile(
                key: const Key('diaWarn'),
                title: Text(localizations.diaWarn),
                leading: const Icon(Icons.warning_amber_outlined),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                initialValue: settings.diaWarn.toInt().toString(),
                onEditingComplete: (String? value) {
                  if (value == null || value.isEmpty || (int.tryParse(value) == null)) {
                    return;
                  }
                  settings.diaWarn = int.parse(value);
                },
                decoration: InputDecoration(hintText: localizations.diaWarn),
                inputWidth: 120,
              ),
              ListTile(
                key: const Key('determineWarnValues'),
                leading: const Icon(Icons.settings_applications_outlined),
                title: Text(localizations.determineWarnValues),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => NumberInputDialoge(
                      hintText: localizations.age,
                      onParsableSubmit: (age) {
                        settings.sysWarn = BloodPressureWarnValues.getUpperSysWarnValue(age);
                        settings.diaWarn = BloodPressureWarnValues.getUpperDiaWarnValue(age);
                        Navigator.of(context).pop();
                        Navigator.of(context).pop();
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const SettingsPage()),
                        );
                      },
                    )
                  );
                },
              ),
              ListTile(
                key: const Key('AboutWarnValuesScreen'),
                title: Text(localizations.aboutWarnValuesScreen),
                subtitle: Text(localizations.aboutWarnValuesScreenDesc),
                leading: const Icon(Icons.info_outline),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AboutWarnValuesScreen()),
                  );
                }
              ),
              ListTile(
                key: const Key('GraphMarkingsScreen'),
                title: Text(localizations.customGraphMarkings),
                leading: const Icon(Icons.legend_toggle_outlined),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const GraphMarkingsScreen()),
                  );
                }
              ),
              SwitchSettingsTile(
                title: Text(localizations.drawRegressionLines),
                leading: const Icon(Icons.trending_down_outlined),
                subtitle: Text(localizations.drawRegressionLinesDesc),
                initialValue: settings.drawRegressionLines,
                onToggle: (value) {
                  settings.drawRegressionLines = value;
                }
              ),
              SwitchSettingsTile(
                title: Text(localizations.startWithAddMeasurementPage),
                subtitle: Text(localizations.startWithAddMeasurementPageDescription),
                leading: const Icon(Icons.electric_bolt_outlined),
                initialValue: settings.startWithAddMeasurementPage,
                onToggle: (value) {
                  settings.startWithAddMeasurementPage = value;
                }
              ),
            ]),
            SettingsSection(
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
                    }
                ),
                ListTile(
                    title: Text(localizations.exportSettings),
                    leading: const Icon(Icons.tune),
                    onTap: () async {
                      String dbPath = await getDatabasesPath();
                      assert(dbPath != inMemoryDatabasePath);
                      dbPath = join(dbPath, 'config.db');
                      assert(Platform.isAndroid);
                      PlatformClient.shareFile(dbPath, 'application/vnd.sqlite3');
                    }
                ),
                ListTile(
                    title: Text(localizations.importSettings),
                    subtitle: Text(localizations.requiresAppRestart),
                    leading: const Icon(Icons.settings_backup_restore),
                    onTap: () async {
                      final messenger = ScaffoldMessenger.of(context);
                      var result = await FilePicker.platform.pickFiles(
                        allowMultiple: false,
                        withData: false,
                      );
                      if (result == null) {
                        messenger.showSnackBar(SnackBar(content: Text(localizations.errNoFileOpened)));
                        return;
                      }
                      var path = result.files.single.path;
                      if (path == null) {
                        messenger.showSnackBar(SnackBar(content: Text(localizations.errCantReadFile)));
                        return;
                      }

                      String dbPath = await getDatabasesPath();
                      assert(dbPath != inMemoryDatabasePath);
                      dbPath = join(dbPath, 'config.db');
                      File(path).copySync(dbPath);
                      if (!await Restart.restartApp()) {
                        messenger.showSnackBar(SnackBar(content: Text(localizations.pleaseRestart)));
                        return;
                      }
                    }
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
                    }
                )
              ],
            ),
            SettingsSection(title: Text(localizations.aboutWarnValuesScreen), children: [
              ListTile(
                  key: const Key('version'),
                  title: Text(localizations.version),
                  leading: const Icon(Icons.info_outline),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  subtitle: ConsistentFutureBuilder<PackageInfo>(
                    future: PackageInfo.fromPlatform(),
                    cacheFuture: true,
                    onData: (context, info) => Text(info.version)
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const VersionScreen()),
                    );
                  }
              ),
              ListTile(
                key: const Key('sourceCode'),
                title: Text(localizations.sourceCode),
                leading: const Icon(Icons.merge),
                onTap: () async {
                  final scaffoldMessenger = ScaffoldMessenger.of(context);
                  var url = Uri.parse('https://github.com/NobodyForNothing/blood-pressure-monitor-fl');
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url, mode: LaunchMode.externalApplication);
                  } else {
                    scaffoldMessenger.showSnackBar(SnackBar(
                        content: Text(localizations.errCantOpenURL(url.toString()))));
                  }
                },
              ),
              ListTile(
                key: const Key('licenses'),
                title: Text(localizations.licenses),
                leading: const Icon(Icons.policy_outlined),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  showLicensePage(context: context);
                },
              ),
            ])
          ],
        );
      }),
    );
  }
}
