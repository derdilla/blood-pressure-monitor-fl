import 'package:blood_pressure_app/data_util/entry_context.dart';
import 'package:blood_pressure_app/model/storage/storage.dart';
import 'package:blood_pressure_app/screens/settings_screen.dart';
import 'package:blood_pressure_app/screens/statistics_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

/// Column of floating action buttons to navigate to [SettingsPage],
/// [StatisticsScreen] or [EntryUtils.createEntry]
class NavigationActionButtons extends StatelessWidget {
  /// Create main FAB navigation column.
  const NavigationActionButtons({super.key});

  @override
  Widget build(BuildContext context) => Consumer<Settings>(
    builder: (context, settings, _) => Column(
      verticalDirection: VerticalDirection.up,
      children: [
        SizedBox.square(
          dimension: 75,
          child: FittedBox(
            child: FloatingActionButton(
              heroTag: 'floatingActionAdd',
              tooltip: AppLocalizations.of(context)!.addMeasurement,
              autofocus: true,
              onPressed: context.createEntry,
              child: const Icon(Icons.add,),
            ),
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        FloatingActionButton(
          heroTag: 'floatingActionStatistics',
          tooltip: AppLocalizations.of(context)!.statistics,
          backgroundColor: const Color(0xFF6F6F6F),
          onPressed: () => Navigator.of(context).push(MaterialPageRoute<void>(
            builder: (BuildContext context) => const StatisticsScreen(),
          )),
          child: const Icon(Icons.insights, color: Colors.black),
        ),
        const SizedBox(
          height: 10,
        ),
        FloatingActionButton(
          heroTag: 'floatingActionSettings',
          tooltip: AppLocalizations.of(context)!.settings,
          backgroundColor: const Color(0xFF6F6F6F),
          child: const Icon(Icons.settings, color: Colors.black),
          onPressed: () => Navigator.of(context).push(MaterialPageRoute<void>(
            builder: (BuildContext context) => const SettingsPage(),
          )),
        ),
      ],
    ),
  );

}