import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// First shows a DatePicker for the day then shows a TimePicker for the time of day.
///
/// As per the decision of the material design team a TimePicker isn't able to limit the range
/// (https://github.com/flutter/flutter/issues/23717#issuecomment-966601311), therefore a manual check for the time of
/// day will be needed. Refer to the validator on the AddMeasurementPage for an example
Future<DateTime?> showDateTimePicker({
  required BuildContext context,
  DateTime? initialDate,
  DateTime? firstDate,
  DateTime? lastDate,
}) async {
  initialDate ??= DateTime.now();
  firstDate ??= initialDate.subtract(const Duration(days: 365 * 100));
  lastDate ??= firstDate.add(const Duration(days: 365 * 200));

  final DateTime? selectedDate = await showDatePicker(
      context: context, initialDate: initialDate, firstDate: firstDate, lastDate: lastDate, confirmText: AppLocalizations.of(context)!.btnNext);

  if (selectedDate == null) return null;
  if (!context.mounted) return null;

  final TimeOfDay? selectedTime = await showTimePicker(
    context: context,
    initialTime: TimeOfDay.fromDateTime(initialDate),
  );

  if (selectedTime == null) return null;
  return DateTime(
    selectedDate.year,
    selectedDate.month,
    selectedDate.day,
    selectedTime.hour,
    selectedTime.minute,
  );
}
