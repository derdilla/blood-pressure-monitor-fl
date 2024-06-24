import 'dart:math';

import 'package:blood_pressure_app/components/date_time_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';

/// Input to allow date and time input.
class DateTimeForm extends StatelessWidget {
  /// Create input to allow date and time input.
  const DateTimeForm({super.key,
    required this.dateFormatString,
    required this.initialTime,
    required this.validate,
    required this.onTimeSelected,
  });

  /// String to display datetime as
  final String dateFormatString;

  /// Initial time to display
  final DateTime initialTime;

  /// Whether to validate whether the time is after now.
  final bool validate;

  /// Call after a new time is successfully selected.
  final void Function(DateTime time) onTimeSelected;

  @override
  Widget build(BuildContext context) => ListTile(
    title: Text(DateFormat(dateFormatString).format(initialTime)),
    trailing: const Icon(Icons.edit),
    onTap: () async {
      final messenger = ScaffoldMessenger.of(context);
      var selectedTime = await showDateTimePicker(
        context: context,
        firstDate: DateTime.fromMillisecondsSinceEpoch(1),
        lastDate: DateTime.now(),
        initialDate: initialTime,
      );
      if (selectedTime == null) {
        return;
      }
      final now = DateTime.now();
      if (validate && selectedTime.isAfter(now)) {
        messenger.showSnackBar(SnackBar(
          content: Text(AppLocalizations.of(context)!.errTimeAfterNow),),);
        selectedTime = selectedTime.copyWith(
          hour: max(selectedTime.hour, now.hour),
          minute: max(selectedTime.minute, now.minute),
        );
      }
      if (selectedTime != initialTime) onTimeSelected(selectedTime);
    },
  );

}
