import 'package:blood_pressure_app/model/datarange_extension.dart';
import 'package:blood_pressure_app/model/storage/intervall_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

/// A selector for [IntervallStorage] values.
///
/// Allows selection [IntervallStorage.currentRange] and moving intervall wise
/// in both directions.
class IntervalPicker extends StatelessWidget {
  /// Create a selector for [IntervallStorage] values.
  const IntervalPicker({super.key, required this.type});

  /// Which range to display and modify.
  final IntervallStoreManagerLocation type;
  
  @override
  Widget build(BuildContext context) => Consumer<IntervallStoreManager>(
    builder: (context, intervallStoreManager, child) {
      final intervall = intervallStoreManager.get(type);
      final loc = AppLocalizations.of(context)!;
      final String intervallDisplayText = switch (intervall.stepSize) {
        TimeStep.day => DateFormat.yMMMd(loc.localeName).format(intervall.currentRange.start),
        TimeStep.week => (){
          final dayOfYear = int.parse(DateFormat('D').format(intervall.currentRange.start));
          final weekOfYear = ((dayOfYear - intervall.currentRange.start.weekday + 10) / 7).floor();
          return loc.weekOfYear(weekOfYear, intervall.currentRange.start.year);
        }(),
        TimeStep.month => DateFormat.yMMM(loc.localeName).format(intervall.currentRange.start),
        TimeStep.year => DateFormat.y(loc.localeName).format(intervall.currentRange.start),
        TimeStep.lifetime => '-',
        TimeStep.last7Days || TimeStep.last30Days || TimeStep.custom => (){
          final f = DateFormat.yMMMd(loc.localeName);
          return '${f.format(intervall.currentRange.start)} - ${f.format(intervall.currentRange.end)}';
        }(),
      };
      return Column(
        children: [
          Text(intervallDisplayText, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 2),
          Row(
            children: [
              Expanded(
                flex: 3,
                child: MaterialButton(
                  onPressed: () => intervall.moveDataRangeByStep(-1),
                  child: const Icon(Icons.chevron_left, size: 48),
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
                        lastDate: DateTime.now(),
                      );
                      if (res != null) {
                        intervall.changeStepSize(value!);
                        intervall.currentRange = res.dateRange;
                      }
                    } else if (value != null) {
                      intervall.changeStepSize(value);
                    }
                  },
                  items: [
                    for (final e in TimeStep.options)
                      DropdownMenuItem(value: e, child: Text(e.getName(loc))),
                  ]
                ),
              ),
              Expanded(
                flex: 3,
                child: MaterialButton(
                  onPressed: () => intervall.moveDataRangeByStep(1),
                  child: const Icon(Icons.chevron_right, size: 48),
                ),
              ),
            ],
          ),
        ],
      );
    },
  );
}
