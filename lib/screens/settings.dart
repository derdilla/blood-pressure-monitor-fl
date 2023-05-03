import 'package:blood_pressure_app/model/settings.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:settings_ui/settings_ui.dart';

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
            return SettingsList(sections: [
              SettingsSection(
                  title: const Text('common'),
                  tiles: <SettingsTile>[
                    SettingsTile.switchTile(
                        initialValue: settings.followSystemDarkMode,
                        onToggle: (value) {
                          settings.followSystemDarkMode = value;
                        },
                        leading: const Icon(Icons.auto_mode),
                        title: const Text('follow system dark mode')
                    ),
                    SettingsTile.switchTile(
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
                      enabled: !settings.followSystemDarkMode,
                    ),
                  ]
              )
            ]);
          }
      ),
    );
  }

}