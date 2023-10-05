import 'package:blood_pressure_app/model/settings_store.dart';
import 'package:blood_pressure_app/model/storage/intervall_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class IntervalPicker extends StatelessWidget {
  const IntervalPicker({super.key, required this.type});

  final IntervallStoreManagerLocation type;
  
  @override
  Widget build(BuildContext context) {
    return Consumer<IntervallStoreManager>(builder: (context, intervallStoreManager, child) {
      final intervall = intervallStoreManager.get(type);
      final String intervallDisplayText;
      switch (intervall.stepSize) {
        case TimeStep.day:
          intervallDisplayText = DateFormat.yMMMd(AppLocalizations.of(context)!.localeName).format(intervall.currentRange.start);
          break;
        case TimeStep.week:
          final dayOfYear = int.parse(DateFormat("D").format(intervall.currentRange.start));
          final weekOfYear = ((dayOfYear - intervall.currentRange.start.weekday + 10) / 7).floor();
          intervallDisplayText = AppLocalizations.of(context)!.weekOfYear(weekOfYear, intervall.currentRange.start.year);
          break;
        case TimeStep.month:
          intervallDisplayText =  DateFormat.yMMM(AppLocalizations.of(context)!.localeName).format(intervall.currentRange.start);
          break;
        case TimeStep.year:
          intervallDisplayText = DateFormat.y(AppLocalizations.of(context)!.localeName).format(intervall.currentRange.start);
          break;
        case TimeStep.lifetime:
          intervallDisplayText =  '-';
          break;
        case TimeStep.last7Days:
        case TimeStep.last30Days:
        case TimeStep.custom:
          final f = DateFormat.yMMMd(AppLocalizations.of(context)!.localeName);
          intervallDisplayText = '${f.format(intervall.currentRange.start)} - ${f.format(intervall.currentRange.end)}';
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
                  intervall.moveDataRangeByStep(-1);
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
                value: intervall.stepSize,
                isExpanded: true,
                onChanged: (TimeStep? value) async {
                  if (value == TimeStep.custom) {
                    final res = await showDateRangePicker(
                        context: context,
                        firstDate: DateTime.fromMillisecondsSinceEpoch(1),
                        lastDate: DateTime.now());
                    if (res != null) {
                      intervall.changeStepSize(value!);
                      intervall.currentRange = res;
                    }
                  } else if (value != null) {
                    intervall.changeStepSize(value);
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
                  intervall.moveDataRangeByStep(1);
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
