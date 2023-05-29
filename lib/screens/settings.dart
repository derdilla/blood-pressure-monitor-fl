import 'package:blood_pressure_app/components/settings_widgets.dart';
import 'package:blood_pressure_app/model/blood_pressure.dart';
import 'package:blood_pressure_app/model/settings_store.dart';
import 'package:blood_pressure_app/screens/subsettings/enter_timeformat.dart';
import 'package:blood_pressure_app/screens/subsettings/warn_about.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Consumer<Settings>(
        builder: (context, settings, child) {
          return ListView(
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
                        MaterialPageRoute(builder: (context) => const EnterTimeFormatScreen()),
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
                  SliderSettingsTile(
                    title: const Text('icon size'),
                    leading: const Icon(Icons.zoom_in),
                    onChanged: (double value) {
                      settings.iconSize = value;
                    },
                    initialValue: settings.iconSize,
                    start: 15,
                    end: 70,
                    stepSize: 5,
                  ),
                  SliderSettingsTile(
                    title: const Text('line thickness'),
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
                    title: const Text('animation duration'),
                    leading: const Icon(Icons.speed),
                    onChanged: (double value) {
                      settings.animationSpeed = value.toInt();
                    },
                    initialValue: settings.animationSpeed.toDouble(),
                    start: 0,
                    end: 1000,
                    stepSize: 50,
                  ),
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
                  title: const Text('behavior'),
                  children: [
                    SwitchSettingsTile(
                        initialValue: settings.validateInputs,
                        title: const Text('validate inputs'),
                        leading: const Icon(Icons.edit),
                        onToggle: (value) {
                          settings.validateInputs = value;
                        }
                    ),
                    InputSettingsTile(
                      title: const Text('age'),
                      description: const Text('determines warn values'),
                      leading: const Icon(Icons.manage_accounts_outlined),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly
                      ],
                      initialValue: settings.age.toString(),
                      onEditingComplete: (String? value) {
                        if (value == null || value.isEmpty
                            || (int.tryParse(value) == null)) {
                          return;
                        }
                        settings.age = int.tryParse(value) as int; // no error possible as per above's condition
                      },
                      decoration: const InputDecoration(
                          hintText: 'age'
                      ),
                      inputWidth: 80,
                      disabled: false,
                      // although no function provided, when overriding warn values,
                      // this field intentionally doesn't get disabled, as this
                      // would cause unexpected jumps in layout
                    ),
                    SettingsTile(
                        title: const Text('about'),
                        description: const Text('more information on warn values'),
                        leading: const Icon(Icons.info_outline),
                        onPressed: (context) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const AboutWarnValuesScreen()),
                          );
                        }
                    ),
                    SwitchSettingsTile(
                      initialValue: settings.overrideWarnValues,
                      onToggle: (value) {
                        settings.overrideWarnValues = value;
                      },
                      leading: const Icon(Icons.tune),
                      title: const Text('override warn values'),
                    ),
                    InputSettingsTile(
                      title: const Text('systolic warn'),
                      leading: const Icon(Icons.settings_applications_outlined),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly
                      ],
                      initialValue: settings.sysWarn.toInt().toString(),
                      onEditingComplete: (String? value) {
                        if (value == null || value.isEmpty
                            || (double.tryParse(value) == null)) {
                          return;
                        }
                        // no error possible as per above's condition
                        settings.sysWarn = double.tryParse(value) as double;
                      },
                      decoration: const InputDecoration(
                          hintText: 'systolic warn'
                      ),
                      inputWidth: 120,
                      disabled: !settings.overrideWarnValues,
                    ),
                    InputSettingsTile(
                      title: const Text('diastolic warn'),
                      leading: const Icon(Icons.settings_applications_outlined),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly
                      ],
                      initialValue: settings.diaWarn.toInt().toString(),
                      onEditingComplete: (String? value) {
                        if (value == null || value.isEmpty
                            || (double.tryParse(value) == null)) {
                          return;
                        }
                        // no error possible as per above's condition
                        settings.diaWarn = double.tryParse(value) as double;
                      },
                      decoration: const InputDecoration(
                          hintText: 'diastolic warn'
                      ),
                      inputWidth: 120,
                      disabled: !settings.overrideWarnValues,
                    ),
                  ]
              ),
              SettingsSection(
                title: const Text('data'),
                children: [
                  SwitchSettingsTile(
                      initialValue: settings.useExportCompatability,
                      title: const Text('compatability export'),
                      description: const Text('sets export mime type to text'),
                      leading: const Icon(Icons.support),
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
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('import successful')));
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error: ${err ?? 'unknown error'}')));
                      }
                    }),
                  ),
                ],
              ),
              SettingsSection(
                  title: const Text('about'),
                  children: [
                    SettingsTile(
                      title: const Text('source code'),
                      leading: const Icon(Icons.merge),
                      onPressed: (context) async {
                        var url = Uri.parse('https://github.com/NobodyForNothing/blood-pressure-monitor-fl');
                        if (await canLaunchUrl(url)) {
                          await launchUrl(url, mode: LaunchMode.externalApplication);
                        } else {
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Can\'t open URL:\nhttps://github.com/NobodyForNothing/blood-pressure-monitor-fl')));
                        }
                        },
                    ),
                    SettingsTile(
                      title: const Text('3rd party licenses'),
                      leading: const Icon(Icons.policy_outlined),
                      trailing: Icon(Icons.arrow_forward_ios, color: Theme.of(context).highlightColor,),
                      onPressed: (context) {
                        showLicensePage(context: context);
                      },
                    ),
                  ]
              )
            ],
            );
          }
      ),
    );
  }
}


