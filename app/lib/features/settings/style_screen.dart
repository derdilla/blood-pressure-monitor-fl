import 'package:blood_pressure_app/features/settings/enter_timeformat_dialog.dart';
import 'package:blood_pressure_app/features/settings/tiles/color_picker_list_tile.dart';
import 'package:blood_pressure_app/features/settings/tiles/dropdown_list_tile.dart';
import 'package:blood_pressure_app/features/settings/tiles/slider_list_tile.dart';
import 'package:blood_pressure_app/l10n/app_localizations.dart';
import 'package:blood_pressure_app/model/iso_lang_names.dart';
import 'package:blood_pressure_app/model/storage/settings_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class StyleScreen extends StatelessWidget {
  const StyleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<Settings>();
    final localizations = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(localizations.appStyleSettings)),
      body: ListView(
        children: [
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
          ListTile(
            key: const Key('EnterTimeFormatScreen'),
            title: Text(localizations.enterTimeFormatScreen),
            subtitle: Text(settings.dateFormatString),
            leading: const Icon(Icons.schedule),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () async {
              final pickedFormat = await showTimeFormatPickerDialog(context,
                settings.dateFormatString,
                settings.bottomAppBars,);
              if (pickedFormat != null) {
                settings.dateFormatString = pickedFormat;
              }
            },
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
            onMainColorChanged: (color) => settings.accentColor = color,
            initialColor: settings.accentColor,
            title: Text(localizations.accentColor),
          ),
          ColorSelectionListTile(
            onMainColorChanged: (color) => settings.sysColor = color,
            initialColor: settings.sysColor,
            title: Text(localizations.sysColor),
          ),
          ColorSelectionListTile(
            onMainColorChanged: (color) => settings.diaColor = color,
            initialColor: settings.diaColor,
            title: Text(localizations.diaColor),
          ),
          ColorSelectionListTile(
            onMainColorChanged: (color) => settings.pulColor = color,
            initialColor: settings.pulColor,
            title: Text(localizations.pulColor),
          ),
          SwitchListTile(
            value: settings.compactList,
            onChanged: (value) {
              settings.compactList = value;
            },
            secondary: const Icon(Icons.list_alt_outlined),
            title: Text(localizations.compactList),
          ),
          SwitchListTile(
            title: Text(localizations.bottomAppBars),
            secondary: const Icon(Icons.vertical_align_bottom),
            value: settings.bottomAppBars,
            onChanged: (value) {
              settings.bottomAppBars = value;
            },
          ),
        ],
      ),
    );
  }
}
