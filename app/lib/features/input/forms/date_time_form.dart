import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';

/// Input to allow date and time input.
class DateTimeForm extends StatefulWidget {
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
  State<DateTimeForm> createState() => _DateTimeFormState();
}

class _DateTimeFormState extends State<DateTimeForm> {
  late DateTime _dateTime;

  List<TextEditingController> _tmpControllers = [];

  @override
  void initState() {
    super.initState();
    _dateTime = widget.initialTime;
  }

  @override
  void dispose() {
    _tmpControllers.forEach((c) => c.dispose());
    super.dispose();
  }

  Future<void> _openDatePicker() async {
    final time = await showDatePicker(
      context: context,
      initialDate: widget.initialTime,
      firstDate: DateTime.fromMillisecondsSinceEpoch(1),
      lastDate: DateTime.now().isBefore(widget.initialTime) ? widget.initialTime : DateTime.now(),
    );
    if (time == null) return;
    _validateAndPropagate(time.copyWith(
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
    _validateAndPropagate(widget.initialTime.copyWith(
      hour: time.hour,
      minute: time.minute,
    ));
  }

  void _validateAndPropagate(DateTime time) {
    if (widget.validate && time.isAfter(DateTime.now())) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(AppLocalizations.of(context)!.errTimeAfterNow),
      ));
      print(time.isAfter(DateTime.now()));
      return;
    }
    setState(() {_dateTime = time;});
    widget.onTimeSelected(time);
  }

  Widget _buildInput(String content, void Function() onTap, String label) => Expanded(
    child: TextField( // use ListTile to get style
      controller: () {
        // Hack to make field contents correctly update when changed.
        // https://github.com/flutter/flutter/issues/152816
        final controller = TextEditingController(text: content);
        _tmpControllers.add(controller);
        return controller;
      }(),
      onTap: onTap,
      decoration: InputDecoration(
        labelText: label,
      ),
      readOnly: true,
      canRequestFocus: false,
    ),
  );

  @override
  Widget build(BuildContext context) {
    final date = DateFormat('yyyy-MM-dd').format(_dateTime);
    final time = DateFormat('HH:mm').format(_dateTime);
    return Row(
      children: [
        _buildInput(date, _openDatePicker, AppLocalizations.of(context)!.date),
        SizedBox(width: 8,),
        _buildInput(time, _openTimePicker, AppLocalizations.of(context)!.time),
      ],
    );
  }
}
