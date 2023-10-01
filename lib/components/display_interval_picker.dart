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
      final String intervallDisplayText;
      switch (settings.graphStepSize) {
        case TimeStep.day:
          intervallDisplayText = DateFormat.yMMMd(AppLocalizations.of(context)!.localeName).format(settings.displayDataStart);
          break;
        case TimeStep.week:
          final dayOfYear = int.parse(DateFormat("D").format(settings.displayDataStart));
          final weekOfYear = ((dayOfYear - settings.displayDataStart.weekday + 10) / 7).floor();
          intervallDisplayText = AppLocalizations.of(context)!.weekOfYear(weekOfYear, settings.displayDataStart.year);
          break;
        case TimeStep.month:
          intervallDisplayText =  DateFormat.yMMM(AppLocalizations.of(context)!.localeName).format(settings.displayDataStart);
          break;
        case TimeStep.year:
          intervallDisplayText = DateFormat.y(AppLocalizations.of(context)!.localeName).format(settings.displayDataStart);
          break;
        case TimeStep.lifetime:
          intervallDisplayText =  '-';
          break;
        case TimeStep.last7Days:
        case TimeStep.last30Days:
        case TimeStep.custom:
          final f = DateFormat.yMMMd(AppLocalizations.of(context)!.localeName);
          intervallDisplayText = '${f.format(settings.displayDataStart)} - ${f.format(settings.displayDataEnd)}';
          break;
      }
      return Column(
        children: [
          Text(intervallDisplayText, overflow: TextOverflow.ellipsis,),
          const SizedBox(
            height: 2,
          ),
          Row(children: [
            Expanded(
              flex: 3,
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
              flex: 4,
              child: DropdownButton<TimeStep>(
                value: settings.graphStepSize,
                isExpanded: true,
                onChanged: (TimeStep? value) async {
                  if (value == TimeStep.custom) {
                    final res = await showDateRangePicker(
                        context: context,
                        firstDate: DateTime.fromMillisecondsSinceEpoch(1),
                        lastDate: DateTime.now());
                    if (res != null) {
                      settings.graphStepSize = value!;
                      settings.displayDataStart = res.start;
                      settings.displayDataEnd = res.end;
                    }
                  } else if (value != null) {
                    settings.changeStepSize(value);
                  }
                },
                items: TimeStep.options.map<DropdownMenuItem<TimeStep>>((v) {
                  return DropdownMenuItem(value: v, child: Text(TimeStep.getName(v, context)));
                }).toList(),
              ),
            ),
            Expanded(
              flex: 3,
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
