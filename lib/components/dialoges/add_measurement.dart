import 'dart:math';

import 'package:blood_pressure_app/components/date_time_picker.dart';
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

  late DateTime time;

  @override
  void initState() {
    super.initState();
    time = widget.initialRecord?.creationTime ?? DateTime.now();
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
    // FocusNode? focusNode, TODO: check if works without
  }) {
    return Expanded(
      child: TextFormField(
        initialValue: (initialValue ?? '').toString(),
        decoration: getInputDecoration(hintText),
        keyboardType: TextInputType.number,
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
            onPressed: () {
              Navigator.of(context).pop(null);
            },
            icon: const Icon(Icons.close)
        ),
        actions: [
          TextButton(
              onPressed: () {
                if (formKey.currentState?.validate() ?? false) {
                  // TODO: save; get values from form
                }
                /*if(inputs valid) {
                  Navigator.of(context).pop(timeFormatFieldController.text);
                }*/
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
            const SizedBox(height: 10,),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                buildValueInput(localizations,
                  hintText: localizations.sysLong,
                  initialValue: widget.initialRecord?.systolic,
                ),
                const SizedBox(width: 10,),
                buildValueInput(localizations,
                  hintText: localizations.diaLong,
                  initialValue: widget.initialRecord?.diastolic,
                ),
                const SizedBox(width: 10,),
                buildValueInput(localizations,
                  hintText: localizations.pulLong,
                  initialValue: widget.initialRecord?.pulse,
                ),
              ],
            ),
            const SizedBox(height: 10,),
            TextFormField(
              initialValue: widget.initialRecord?.notes,
              decoration: getInputDecoration(localizations.addNote),
              minLines: 1,
              maxLines: 4,
            )

            // TODO: color input
          ],
        ),
      ),
    );
  }
}

Future<BloodPressureRecord> showAddMeasurementDialoge([BloodPressureRecord? initialRecord]) async {
  // TODO: implement and change method signature
  throw UnimplementedError();
}