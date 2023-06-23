import 'package:blood_pressure_app/model/settings_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class IntervalPicker extends StatelessWidget {
  const IntervalPicker({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<Settings>(builder: (context, settings, child) {
      final Widget intervallDisplay;
      switch (settings.graphStepSize) {
        case TimeStep.day:
          intervallDisplay = Text(DateFormat.yMMMd(AppLocalizations.of(context)!.localeName).format(settings.displayDataStart));
          break;
        case TimeStep.week:
          final dayOfYear = int.parse(DateFormat("D").format(settings.displayDataStart));
          final weekOfYear = ((dayOfYear - settings.displayDataStart.weekday + 10) / 7).floor();
          intervallDisplay = Text(AppLocalizations.of(context)!.weekOfYear(weekOfYear, settings.displayDataStart.year));
          break;
        case TimeStep.month:
          intervallDisplay =  Text(DateFormat.yMMM(AppLocalizations.of(context)!.localeName).format(settings.displayDataStart));
          break;
        case TimeStep.year:
          intervallDisplay =  Text(DateFormat.y(AppLocalizations.of(context)!.localeName).format(settings.displayDataStart));
          break;
        case TimeStep.lifetime:
          intervallDisplay =  const Text('-');
          break;
        default:
          assert(false);
          intervallDisplay =  const Text('-');
      }
      return Column(
        children: [
          intervallDisplay,
          const SizedBox(
            height: 2,
          ),
          Row(children: [
            Expanded(
              flex: 30,
              child: MaterialButton(
                onPressed: () {
                  settings.moveDisplayDataByStep(-1);
                },
                child: const Icon(
                  Icons.chevron_left,
                  size: 48,
                ),
              ),
            ),
            Expanded(
              flex: 40,
              child: DropdownButton<int>(
                value: settings.graphStepSize,
                isExpanded: true,
                onChanged: (int? value) {
                  if (value != null) {
                    settings.changeStepSize(value);
                  }
                },
                items: TimeStep.options.map<DropdownMenuItem<int>>((v) {
                  return DropdownMenuItem(value: v, child: Text(TimeStep.getName(v, context)));
                }).toList(),
              ),
            ),
            Expanded(
              flex: 30,
              child: MaterialButton(
                onPressed: () {
                  settings.moveDisplayDataByStep(1);
                },
                child: const Icon(
                  Icons.chevron_right,
                  size: 48,
                ),
              ),
            ),
          ]),
        ],
      );
    });
  }
}
