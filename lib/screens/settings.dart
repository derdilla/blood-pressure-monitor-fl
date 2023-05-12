import 'package:blood_pressure_app/components/complex_settings.dart';
import 'package:blood_pressure_app/model/blood_pressure.dart';
import 'package:blood_pressure_app/model/settings.dart';
import 'package:blood_pressure_app/screens/enter_timeformat.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Consumer<Settings>(
          builder: (context, settings, child) {
            return Scaffold(
              body: ListView(
                children: [
                  SettingsSection(
                      title: const Text('layout'),
                      children: [
                        SwitchSettingsTile(
                            initialValue: settings.allowManualTimeInput,
                            onToggle: (value) {
                              settings.allowManualTimeInput = value;
                            },
                            leading: const Icon(Icons.details),
                            title: const Text('allow manual time input')
                        ),
                        SettingsTile(
                          title: const Text('time format'),
                          leading: const Icon(Icons.schedule),
                          trailing: Icon(Icons.arrow_forward_ios, color: Theme.of(context).highlightColor,),
                          description: Text(settings.dateFormatString),
                          onPressed: (context) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => EnterTimeFormatScreen()),
                            );
                          },
                        ),
                        SwitchSettingsTile(
                            initialValue: settings.followSystemDarkMode,
                            onToggle: (value) {
                              settings.followSystemDarkMode = value;
                            },
                            leading: const Icon(Icons.auto_mode),
                            title: const Text('follow system dark mode')
                        ),
                        SwitchSettingsTile(
                          initialValue: (() {
                            if (settings.followSystemDarkMode) {
                              return MediaQuery.of(context).platformBrightness == Brightness.dark;
                            }
                            return settings.darkMode;
                          })(),
                          onToggle: (value) {
                            settings.darkMode = value;
                          },
                          leading: const Icon(Icons.dark_mode),
                          title: const Text('enable dark mode'),
                          disabled: settings.followSystemDarkMode,
                        ),
                        //settings.accentColor = settings.createMaterialColor((color ?? Colors.teal).value);
                        ColorSelectionSettingsTile(
                            onMainColorChanged: (color) => settings.accentColor = settings.createMaterialColor((color ?? Colors.teal).value),
                            initialColor: settings.accentColor,
                            title: const Text('theme color')
                        ),
                        ColorSelectionSettingsTile(
                            onMainColorChanged: (color) => settings.sysColor = settings.createMaterialColor((color ?? Colors.green).value),
                            initialColor: settings.sysColor,
                            title: const Text('systolic color')
                        ),
                        ColorSelectionSettingsTile(
                            onMainColorChanged: (color) => settings.diaColor = settings.createMaterialColor((color ?? Colors.teal).value),
                            initialColor: settings.diaColor,
                            title: const Text('diastolic color')
                        ),
                        ColorSelectionSettingsTile(
                            onMainColorChanged: (color) => settings.pulColor = settings.createMaterialColor((color ?? Colors.red).value),
                            initialColor: settings.pulColor,
                            title: const Text('pulse color')
                        ),
                      ]
                  ),
                  SettingsSection(
                    title: const Text('data'),
                    children: [
                      SwitchSettingsTile(
                          initialValue: settings.useExportCompatability,
                          title: const Text('compatability export'),
                          description: const Text('sets export mime type to text instead of csv'),
                          onToggle: (value) {
                            settings.useExportCompatability = value;
                          }
                      ),
                      SettingsTile(
                        title: const Text('export'),
                        leading: const Icon(Icons.save),
                        onPressed: (context) =>  Provider.of<BloodPressureModel>(context, listen: false).save((success, msg) {
                          if (success && msg != null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(msg)));
                          } else if (!success && msg != null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Error: $msg')));
                          }
                        }
                            , exportAsText: settings.useExportCompatability),
                      ),
                      SettingsTile(
                        title: const Text('import'),
                        leading: const Icon(Icons.file_upload),
                        onPressed: (context) =>  Provider.of<BloodPressureModel>(context, listen: false).import((res, String? err) {
                          if (res) {

                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Error: ${err ?? 'unknown error'}')));
                          }
                        }),
                      ),
                    ],
                  )
                ],
              ),
            );
          }
      ),
    );
  }
}


