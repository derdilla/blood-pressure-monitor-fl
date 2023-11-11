import 'dart:math';

import 'package:blood_pressure_app/components/date_time_picker.dart';
import 'package:blood_pressure_app/components/settings/settings_widgets.dart';
import 'package:blood_pressure_app/model/blood_pressure.dart';
import 'package:blood_pressure_app/model/storage/storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';

/// Input mask for entering measurements.
class AddMeasurementDialoge extends StatefulWidget {
  /// Create a input mask for entering measurements.
  /// 
  /// This is usually created through the [showAddMeasurementDialoge] function.
  const AddMeasurementDialoge(
      {super.key,
      required this.settings,
      this.initialRecord});

  /// Settings are followed by the dialoge.
  final Settings settings;

  /// Values that are prefilled.
  ///
  /// When this is null the timestamp is [DateTime.now] and the other fields will be empty.
  final BloodPressureRecord? initialRecord;

  @override
  State<AddMeasurementDialoge> createState() => _AddMeasurementDialogeState();
}

class _AddMeasurementDialogeState extends State<AddMeasurementDialoge> {
  final formKey = GlobalKey<FormState>();
  final firstFocusNode = FocusNode();

  /// Currently selected time.
  late DateTime time;

  /// Current selected needlePin.
  MeasurementNeedlePin? needlePin;

  /// Last [FormState.save]d systolic value.
  int? systolic;

  /// Last [FormState.save]d diastolic value.
  int? diastolic;

  /// Last [FormState.save]d pulse value.
  int? pulse;

  /// Last [FormState.save]d note.
  String? notes;

  @override
  void initState() {
    super.initState();
    time = widget.initialRecord?.creationTime ?? DateTime.now();
    needlePin = widget.initialRecord?.needlePin;

    firstFocusNode.requestFocus();
  }


  @override
  void dispose() {
    firstFocusNode.dispose();
    super.dispose();
  }

  Widget buildTimeInput(AppLocalizations localizations) =>
    ListTile(
      title: Text(DateFormat(widget.settings.dateFormatString).format(time)),
      trailing: const Icon(Icons.edit),
      shape: RoundedRectangleBorder(
          side: BorderSide(
              width: 2,
              color: Theme.of(context).primaryColor
          ),
          borderRadius: BorderRadius.circular(20)
      ),
      onTap: () async {
        final messenger = ScaffoldMessenger.of(context);
        var selectedTime = await showDateTimePicker(
            context: context,
            firstDate: DateTime.fromMillisecondsSinceEpoch(1),
            lastDate: DateTime.now(),
            initialDate: time
        );
        if (selectedTime == null) {
          return;
        }
        final now = DateTime.now();
        if (widget.settings.validateInputs && selectedTime.isAfter(now)) {
          messenger.showSnackBar(SnackBar(
              content: Text(localizations.errTimeAfterNow)));
          selectedTime = selectedTime.copyWith(
              hour: max(selectedTime.hour, now.hour),
              minute: max(selectedTime.minute, now.minute)
          );
        }
        setState(() {
          time = selectedTime!;
        });
      },
    );

  Widget buildValueInput(AppLocalizations localizations, {
    int? initialValue,
    String? hintText,
    void Function(String?)? onSaved,
    FocusNode? focusNode,
  }) {
    return Expanded(
      child: TextFormField(
        initialValue: (initialValue ?? '').toString(),
        decoration: getInputDecoration(hintText),
        keyboardType: TextInputType.number,
        focusNode: focusNode,
        onSaved: onSaved,
        inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly],
        onChanged: (String? value) {
          if (value != null && value.isNotEmpty && (int.tryParse(value) ?? -1) > 40) {
            FocusScope.of(context).nextFocus();
          }
        },
        validator: (String? value) {
          if (value == null || value.isEmpty || int.tryParse(value) == null) {
            return localizations.errNaN;
          } else if (widget.settings.validateInputs && (int.tryParse(value) ?? -1) <= 30) {
            return localizations.errLt30;
          } else if (widget.settings.validateInputs && (int.tryParse(value) ?? 0) >= 400) {
            // https://pubmed.ncbi.nlm.nih.gov/7741618/
            return localizations.errUnrealistic;
          }
          return null;
        },
      ),
    );
  }


  InputDecoration getInputDecoration(String? labelText) {
    final border = OutlineInputBorder(
        borderSide: BorderSide(
          width: 2,
          color: Theme.of(context).primaryColor,
        ),
        borderRadius: BorderRadius.circular(20)
    );
    return InputDecoration(
      hintText: labelText,
      labelText: labelText,
      errorMaxLines: 5,
      border: border,
      enabledBorder: border,
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        forceMaterialTransparency: true,
        leading: IconButton(
            onPressed: () => Navigator.of(context).pop(null),
            icon: const Icon(Icons.close)
        ),
        actions: [
          TextButton(
              onPressed: () {
                if (formKey.currentState?.validate() ?? false) {
                  formKey.currentState?.save();
                  final record = BloodPressureRecord(time, systolic, diastolic, pulse, notes ?? '', needlePin: needlePin);
                  Navigator.of(context).pop(record);
                }
              },
              child: Text(localizations.btnSave)
          )
        ],
      ),
      body: Form(
        key: formKey,
        child: ListView(
          children: [
            if (widget.settings.allowManualTimeInput)
              buildTimeInput(localizations),
            const SizedBox(height: 16,),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                buildValueInput(localizations,
                  focusNode: firstFocusNode,
                  hintText: localizations.sysLong,
                  initialValue: widget.initialRecord?.systolic,
                  onSaved: (value) => setState(() => systolic = int.tryParse(value ?? '')),
                ),
                const SizedBox(width: 16,),
                buildValueInput(localizations,
                  hintText: localizations.diaLong,
                  initialValue: widget.initialRecord?.diastolic,
                  onSaved: (value) => setState(() => diastolic = int.tryParse(value ?? '')),
                ),
                const SizedBox(width: 16,),
                buildValueInput(localizations,
                  hintText: localizations.pulLong,
                  initialValue: widget.initialRecord?.pulse,
                  onSaved: (value) => setState(() => pulse = int.tryParse(value ?? '')),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: TextFormField(
                initialValue: widget.initialRecord?.notes,
                decoration: getInputDecoration(localizations.addNote),
                minLines: 1,
                //maxLines: 4, There is a bug in the flutter framework: https://github.com/flutter/flutter/issues/138219
                onSaved: (value) => setState(() => notes = value),
              ),
            ),
            ColorSelectionListTile(
              title: Text(localizations.color),
              onMainColorChanged: (Color value) {
                if (value == Colors.transparent) {
                  setState(() {
                    needlePin = null;
                  });
                } else {
                  setState(() {
                    needlePin = MeasurementNeedlePin(value);
                  });
                }
              },
              initialColor: needlePin?.color ?? Colors.transparent,
              shape: RoundedRectangleBorder(
                  side: BorderSide(
                      width: 2,
                      color: needlePin?.color ?? Theme.of(context).primaryColor
                  ),
                  borderRadius: BorderRadius.circular(20)
              )
            ),
          ],
        ),
      ),
    );
  }
}

Future<BloodPressureRecord?> showAddMeasurementDialoge(BuildContext context, Settings settings, [BloodPressureRecord? initialRecord]) =>
  showDialog<BloodPressureRecord?>(context: context, builder: (context) => Dialog.fullscreen(
    child: AddMeasurementDialoge(settings: settings, initialRecord: initialRecord,),
  ));