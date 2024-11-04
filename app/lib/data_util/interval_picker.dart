import 'package:blood_pressure_app/model/datarange_extension.dart';
import 'package:blood_pressure_app/model/storage/interval_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:week_of_year/date_week_extensions.dart';

/// A selector for [IntervalStorage] values.
///
/// Allows selection [IntervalStorage.currentRange] and moving intervall wise
/// in both directions.
class IntervalPicker extends StatelessWidget {
  /// Create a selector for [IntervalStorage] values.
  const IntervalPicker({super.key,
    required this.type,
    this.customRangePickerCurrentDay,
  });

  /// Which range to display and modify.
  final IntervalStoreManagerLocation type;

  /// The day from which to start the custom date range picker.
  ///
  /// Defaults to the current day which is the desired value in all non-test scenarios.
  final DateTime? customRangePickerCurrentDay;
  
  @override
  Widget build(BuildContext context) => Consumer<IntervalStoreManager>(
    builder: (context, intervallStoreManager, _) {
      final intervall = intervallStoreManager.get(type);
      final loc = AppLocalizations.of(context)!;
      final start = intervall.currentRange.start;
      final end = intervall.currentRange.end;
      final String intervallDisplayText = switch (intervall.stepSize) {
        TimeStep.day => DateFormat.yMMMd().format(start),
        TimeStep.week => loc.weekOfYear(start.weekOfYear, start.year),
        TimeStep.month => DateFormat.yMMM().format(intervall.currentRange.start),
        TimeStep.year => DateFormat.y().format(intervall.currentRange.start),
        TimeStep.lifetime => '-',
        TimeStep.last7Days || TimeStep.last30Days || TimeStep.custom =>
          '${DateFormat.yMMMd().format(start)} - ${DateFormat.yMMMd().format(end)}',
      };
      return Column(
        children: [
          Text(intervallDisplayText, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 2),
          Row(
            children: [
              MaterialButton(
                onPressed: () => intervall.moveDataRangeByStep(-1),
                child: const Icon(Icons.chevron_left, size: 48),
              ),
              Expanded(
                child: DropdownButton<TimeStep>(
                  value: intervall.stepSize,
                  isExpanded: true,
                  onChanged: (TimeStep? value) async {
                    if (value == TimeStep.custom) {
                      final res = await showDateRangePicker(
                        context: context,
                        firstDate: DateTime.fromMillisecondsSinceEpoch(1),
                        lastDate: customRangePickerCurrentDay ?? DateTime.now(),
                        currentDate: customRangePickerCurrentDay,
                      );
                      if (res != null) {
                        intervall.changeStepSize(value!);
                        final dateRange = res.dateRange.copyWith(
                          end: res.end.copyWith(hour: 23, minute: 59, second: 59),
                        );
                        intervall.currentRange = dateRange;
                      }
                    } else if (value != null) {
                      intervall.changeStepSize(value);
                    }
                  },
                  items: [
                    for (final TimeStep e in TimeStep.values)
                      DropdownMenuItem(value: e, child: Text(e.localize(loc))),
                  ]
                ),
              ),
              MaterialButton(
                onPressed: () => intervall.moveDataRangeByStep(1),
                child: const Icon(Icons.chevron_right, size: 48),
              ),
            ],
          ),
        ],
      );
    },
  );
}
