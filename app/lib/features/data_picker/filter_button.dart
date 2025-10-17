import 'dart:math';

import 'package:blood_pressure_app/l10n/app_localizations.dart';
import 'package:blood_pressure_app/model/storage/interval_store.dart';
import 'package:flutter/material.dart';

/// Button that shows an menu to configure a display intervalls filter.
class FilterButton extends StatefulWidget {
  /// Create button that shows an menu to configure a display intervalls filter.
  const FilterButton({super.key, required this.interval});

  /// The interval to configure
  final IntervalStorage interval;

  @override
  State<FilterButton> createState() => _FilterButtonState();
}

class _FilterButtonState extends State<FilterButton> {
  TimeOfDay _extractTime(double decimalHours) {
    final totalMinutes = (decimalHours * 60).round();
    final duration = Duration(minutes: totalMinutes);
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    return TimeOfDay(hour: hours, minute: minutes);
  }

  TimeOfDay get _start => widget.interval.timeLimitRange?.start
      ?? TimeOfDay(hour: 0, minute: 0);
  TimeOfDay get _end => widget.interval.timeLimitRange?.end
      ?? TimeOfDay(hour: 23, minute: 59);

  @override
  Widget build(BuildContext context) => MenuAnchor(
    menuChildren: [
      Padding(
        padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 0.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(TimeOfDay(hour: 0, minute: 0).format(context)),
            Text(TimeOfDay(hour: 23, minute: 59).format(context)),
          ],
        ),
      ),
      SliderTheme(
        data: SliderThemeData(
          showValueIndicator: ShowValueIndicator.onDrag,
          padding: EdgeInsets.symmetric(horizontal: 12.0)
        ),
        child: RangeSlider(
          // 15 minute intervalls
          divisions: 24.0 ~/ 0.25,
          min: 0.0,
          max: 23.99,
          labels: RangeLabels(_start.format(context), _end.format(context)),
          values: RangeValues(_start.hour + _start.minute.toDouble() / 60.0,
                              _end.hour + _end.minute.toDouble() / 60.0),
          onChanged: (v) {
            setState(() {
              widget.interval.timeLimitRange = TimeRange(
                start: _extractTime(min(v.start, v.end)),
                end: _extractTime(max(v.start, v.end)),
              );
            });
          },
        ),
      ),
      Align(
        alignment: Alignment.centerRight,
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: TextButton(
            onPressed: () => widget.interval.timeLimitRange = null,
            child: Text(AppLocalizations.of(context)!.reset),
          ),
        ),
      )
    ],
    builder: (BuildContext context, MenuController controller, Widget? child) => IconButton(
      onPressed: () {
        if (controller.isOpen) {
          controller.close();
        } else {
          controller.open();
        }
      },
      icon: Icon(Icons.filter_alt),
    ),
  );
}
