import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';

/// Input to allow date and time input.
class DateTimeForm extends StatefulWidget {
  /// Create input to allow date and time input.
  const DateTimeForm({super.key,
    required this.initialTime,
    required this.validate,
    required this.onTimeSelected,
  });

  /// Initial time to display
  final DateTime initialTime;

  /// Whether to validate whether the time is after now.
  final bool validate;

  /// Call after a new time is successfully selected.
  final void Function(DateTime time) onTimeSelected;

  @override
  State<DateTimeForm> createState() => _DateTimeFormState();
}

class _DateTimeFormState extends State<DateTimeForm> {
  Future<void> _openDatePicker() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: widget.initialTime,
      firstDate: DateTime.fromMillisecondsSinceEpoch(1),
      lastDate: widget.initialTime.isAfter(now) ? widget.initialTime : now,
    );
    if (date == null) return;
    _validateAndInvoke(date.copyWith(
      hour: widget.initialTime.hour,
      minute: widget.initialTime.minute,
    ));
  }

  Future<void> _openTimePicker() async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(widget.initialTime),
    );
    if (time == null) return;
    _validateAndInvoke(widget.initialTime.copyWith(
      hour: time.hour,
      minute: time.minute,
    ));
  }

  void _validateAndInvoke(DateTime time) {
    if (widget.validate && time.isAfter(DateTime.now())) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(AppLocalizations.of(context)!.errTimeAfterNow),
      ));
      return;
    }
    widget.onTimeSelected(time);
  }

  Widget _buildInput(String content, void Function() onTap, String label) => Expanded(
    child: InputDecorator(
      child: GestureDetector(onTap: onTap, child: Text(content)),
      decoration: InputDecoration(
        labelText: label,
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final date = DateFormat('yyyy-MM-dd').format(widget.initialTime);
    final time = DateFormat('HH:mm').format(widget.initialTime);
    return Row(
      children: [
        _buildInput(date, _openDatePicker, AppLocalizations.of(context)!.date),
        SizedBox(width: 8,),
        _buildInput(time, _openTimePicker, AppLocalizations.of(context)!.time),
      ],
    );
  }
}
