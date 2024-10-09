import 'package:blood_pressure_app/features/input/forms/form_base.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';

/// Input to allow date and time input.
class DateTimeForm extends FormBase<DateTime> {
  /// Create input to allow date and time input.
  const DateTimeForm({super.key,
    required super.initialValue,
    required this.validate,
  });

  /// Whether to validate whether the time is after now.
  final bool validate;

  @override
  FormStateBase<DateTime, DateTimeForm> createState() => DateTimeFormState();
}

/// State of a [DateTimeForm].
class DateTimeFormState extends FormStateBase<DateTime, DateTimeForm> {
  late DateTime _time;

  @override
  void initState() {
    super.initState();
    _time = widget.initialValue ?? DateTime.now();
  }

  @override
  DateTime? save() => validate() ? _time : null;

  @override
  bool validate() {
    if (widget.validate && _time.isAfter(DateTime.now())) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(AppLocalizations.of(context)!.errTimeAfterNow),
      )); // TODO: display error as below
      return false;
    }
    return true;
  }

  Future<void> _openDatePicker() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: _time,
      firstDate: DateTime.fromMillisecondsSinceEpoch(1),
      lastDate: _time.isAfter(now) ? _time : now,
    );
    if (date == null) return;
    setState(() => _time = date.copyWith(
      hour: _time.hour,
      minute: _time.minute,
    ));

  }

  Future<void> _openTimePicker() async {
    final timeOfDay = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_time),
    );
    if (timeOfDay == null) return;
    setState(() => _time = _time.copyWith(
      hour: timeOfDay.hour,
      minute: timeOfDay.minute,
    ));
  }

  Widget _buildInput(String content, void Function() onTap, String label) => Expanded(
    child: InputDecorator(
      decoration: InputDecoration(
        labelText: label,
      ),
      child: GestureDetector(
        onTap: onTap,
        child: Text(content, style: Theme.of(context).textTheme.bodyLarge)
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final date = DateFormat('yyyy-MM-dd').format(_time);
    final timeOfDay = DateFormat('HH:mm').format(_time);
    return Row(
      children: [
        _buildInput(date, _openDatePicker, AppLocalizations.of(context)!.date),
        SizedBox(width: 8,),
        _buildInput(timeOfDay, _openTimePicker, AppLocalizations.of(context)!.time),
      ],
    );
  }
}
