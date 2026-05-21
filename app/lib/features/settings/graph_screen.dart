import 'package:blood_pressure_app/features/settings/configure_warn_values_screen.dart';
import 'package:blood_pressure_app/features/settings/graph_markings_screen.dart';
import 'package:blood_pressure_app/features/settings/tiles/slider_list_tile.dart';
import 'package:blood_pressure_app/l10n/app_localizations.dart';
import 'package:blood_pressure_app/model/storage/settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class GraphScreen extends StatelessWidget {
  const GraphScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<Settings>();
    final localizations = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(localizations.graphSettings)),
      body: ListView(
        children: [
          ListTile(
            title: Text(localizations.customGraphMarkings),
            leading: const Icon(Icons.legend_toggle_outlined),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute<void>(builder: (context) => const GraphMarkingsScreen()),
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
      
          ListTile(
            leading: const Icon(Icons.warning_amber_outlined),
            title: Text(localizations.determineWarnValues),
            subtitle: Text(localizations.aboutWarnValuesScreenDesc),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute<void>(builder: (context) => const ConfigureWarnValuesScreen()),
              );
            },
          ),
          SliderListTile(
            title: Text(localizations.maxDataInterval),
            subtitle: Text(localizations.maxDataIntervalDesc),
            leading: const Icon(Icons.auto_graph_outlined),
            onChanged: (double value) {
              settings.interruptGraphAfterNDays = value.toInt();
            },
            value: settings.interruptGraphAfterNDays.toDouble(),
            min: 0,
            max: 30,
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
        ],
      ),
    );
  }
}
