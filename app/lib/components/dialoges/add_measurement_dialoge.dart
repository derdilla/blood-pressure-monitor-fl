import 'dart:math';

import 'package:blood_pressure_app/components/bluetooth_input.dart';
import 'package:blood_pressure_app/components/date_time_picker.dart';
import 'package:blood_pressure_app/components/dialoges/fullscreen_dialoge.dart';
import 'package:blood_pressure_app/components/settings/settings_widgets.dart';
import 'package:blood_pressure_app/main.dart'; // TODO: remove
import 'package:blood_pressure_app/model/blood_pressure/medicine/medicine.dart';
import 'package:blood_pressure_app/model/blood_pressure/medicine/medicine_intake.dart';
import 'package:blood_pressure_app/model/blood_pressure/needle_pin.dart';
import 'package:blood_pressure_app/model/blood_pressure/record.dart';
import 'package:blood_pressure_app/model/storage/storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';

/// Input mask for entering measurements.
class AddEntryDialoge extends StatefulWidget {
  /// Create a input mask for entering measurements.
  /// 
  /// This is usually created through the [showAddEntryDialoge] function.
  const AddEntryDialoge({super.key,
    required this.settings,
    this.initialRecord,
  });

  /// Settings are followed by the dialoge.
  final Settings settings;

  /// Values that are prefilled.
  ///
  /// When this is null the timestamp is [DateTime.now] and the other fields
  /// will be empty.
  ///
  /// When an initial record is set medicine input is not possible because it is
  /// saved separately.
  final BloodPressureRecord? initialRecord;

  @override
  State<AddEntryDialoge> createState() => _AddEntryDialogeState();
}

class _AddEntryDialogeState extends State<AddEntryDialoge> {
  final recordFormKey = GlobalKey<FormState>();
  final medicationFormKey = GlobalKey<FormState>();

  final sysFocusNode = FocusNode();
  final diaFocusNode = FocusNode();
  final pulFocusNode = FocusNode();
  final noteFocusNode = FocusNode();

  late final TextEditingController sysController;
  late final TextEditingController diaController;
  late final TextEditingController pulController;
  late final TextEditingController noteController;


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
  
  /// Index of the selected medicine in non hidden medications.
  ///
  /// Non hidden medications are obtained at the start of the build method.
  int? medicineId;

  /// Whether to show the medication dosis input
  bool _showMedicineDosisInput = false;

  /// Entered dosis of medication.
  double? medicineDosis;

  /// Newlines in the note field.
  int _noteCurrentNewLineCount = 0;

  /// Whether any of the measurement fields was once non-empty.
  ///
  /// Those fields are:
  /// - sys, dia, pul
  /// - note
  /// - color
  bool _measurementFormActive = false;

  @override
  void initState() {
    super.initState();
    time = widget.initialRecord?.creationTime ?? DateTime.now();
    needlePin = widget.initialRecord?.needlePin;
    sysController = TextEditingController();
    diaController = TextEditingController();
    pulController = TextEditingController();
    noteController = TextEditingController();
    _loadFields(widget.initialRecord);

    if (widget.initialRecord != null) {
      _measurementFormActive = true;
    }

    sysFocusNode.requestFocus();
    ServicesBinding.instance.keyboard.addHandler(_onKey);
  }

  @override
  void dispose() {
    sysController.dispose();
    sysFocusNode.dispose();
    diaFocusNode.dispose();
    pulFocusNode.dispose();
    noteFocusNode.dispose();
    ServicesBinding.instance.keyboard.removeHandler(_onKey);
    super.dispose();
  }

  /// Sets fields to values in a [record].
  void _loadFields(BloodPressureRecord? record) {
    time = record?.creationTime ?? DateTime.now();
    if (record?.needlePin != null) needlePin = record?.needlePin;
    if (record?.systolic != null) sysController.text = record!.systolic!.toString();
    if (record?.diastolic != null) diaController.text = record!.diastolic!.toString();
    if (record?.pulse != null) pulController.text = record!.pulse!.toString();
    if (record?.notes != null) noteController.text = record!.notes;
  }

  bool _onKey(KeyEvent event) {
    if (event is! KeyDownEvent) return false;
    final isBackspace = event.logicalKey.keyId == 0x00100000008;
    if (!isBackspace) return false;
    recordFormKey.currentState?.save();
    if (diaFocusNode.hasFocus && diastolic == null 
        || pulFocusNode.hasFocus && pulse == null
        || noteFocusNode.hasFocus && (notes?.isEmpty ?? true)
    ) FocusScope.of(context).previousFocus();
    return false;
  }

  Widget _buildTimeInput(AppLocalizations localizations) =>
    ListTile(
      title: Text(DateFormat(widget.settings.dateFormatString).format(time)),
      trailing: const Icon(Icons.edit),
      shape: _buildShapeBorder(),
      onTap: () async {
        final messenger = ScaffoldMessenger.of(context);
        var selectedTime = await showDateTimePicker(
            context: context,
            firstDate: DateTime.fromMillisecondsSinceEpoch(1),
            lastDate: DateTime.now(),
            initialDate: time,
        );
        if (selectedTime == null) {
          return;
        }
        final now = DateTime.now();
        if (widget.settings.validateInputs && selectedTime.isAfter(now)) {
          messenger.showSnackBar(SnackBar(
              content: Text(localizations.errTimeAfterNow),),);
          selectedTime = selectedTime.copyWith(
              hour: max(selectedTime.hour, now.hour),
              minute: max(selectedTime.minute, now.minute),
          );
        }
        setState(() {
          time = selectedTime!;
        });
      },
    );

  /// Build a input for values in the measurement form (sys, dia, pul).
  Widget _buildValueInput(AppLocalizations localizations, {
    int? initialValue,
    String? labelText,
    void Function(String?)? onSaved,
    FocusNode? focusNode,
    TextEditingController? controller,
    String? Function(String?)? validator,
  }) {
    assert(initialValue == null || controller == null);
    return Expanded(
      child: TextFormField(
        initialValue: initialValue?.toString(),
        decoration: InputDecoration(
          labelText: labelText,
        ),
        keyboardType: TextInputType.number,
        focusNode: focusNode,
        onSaved: onSaved,
        controller: controller,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        onChanged: (String value) {
          if (value.isNotEmpty) _measurementFormActive = true;
          if (value.isNotEmpty
              && (int.tryParse(value) ?? -1) > 40) {
            FocusScope.of(context).nextFocus();
          }
        },
        validator: (String? value) {
          if (!widget.settings.allowMissingValues
              && (value == null
                  || value.isEmpty
                  || int.tryParse(value) == null)) {
            return localizations.errNaN;
          } else if (widget.settings.validateInputs
              && (int.tryParse(value ?? '') ?? -1) <= 30) {
            return localizations.errLt30;
          } else if (widget.settings.validateInputs
              && (int.tryParse(value ?? '') ?? 0) >= 400) {
            // https://pubmed.ncbi.nlm.nih.gov/7741618/
            return localizations.errUnrealistic;
          }
          return validator?.call(value);
        },
      ),
    );
  }

  /// Build the border all fields have.
  RoundedRectangleBorder _buildShapeBorder([Color? color]) =>
      RoundedRectangleBorder(
    side: Theme.of(context).inputDecorationTheme.border?.borderSide
        ?? const BorderSide(width: 3),
    borderRadius: BorderRadius.circular(20),
  );

  @override
  Widget build(BuildContext context) {
    final medications = widget.settings.medications.where((e) => !e.hidden);
    final localizations = AppLocalizations.of(context)!;
    return FullscreenDialoge(
      onActionButtonPressed: () {
        BloodPressureRecord? record;
        if (_measurementFormActive && (recordFormKey.currentState?.validate() ?? false)) {
          recordFormKey.currentState?.save();
          if (systolic != null || diastolic != null || pulse != null
              || (notes ?? '').isNotEmpty || needlePin != null) {
            record = BloodPressureRecord(time, systolic, diastolic, pulse,
              notes ?? '', needlePin: needlePin,);
          }
        }

        MedicineIntake? intake;
        if (_showMedicineDosisInput
            && (medicationFormKey.currentState?.validate() ?? false)) {
          medicationFormKey.currentState?.save();
          if (medicineDosis != null
              && medicineId != null) {
            intake = MedicineIntake(
              timestamp: time,
              medicine: medications
                  .where((e) => e.id == medicineId).first,
              dosis: medicineDosis!,
            );
          }
        }

        if (record != null && intake != null) {
          Navigator.pop(context, (record, intake));
        }
        if (record == null && !_measurementFormActive && intake != null) {
          Navigator.pop(context, (record, intake));
        }
        if (record != null && intake == null && medicineId == null) {
          Navigator.pop(context, (record, intake));
        }
      },
      actionButtonText: localizations.btnSave,
      bottomAppBar: widget.settings.bottomAppBars,
      body: SizeChangedLayoutNotifier(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          children: [
            // TODO: make toggleable in settings
            BluetoothInput(
              settings: widget.settings,
              onMeasurement: (record) => setState(() => _loadFields(record)),
            ),
            TextButton(onPressed: () {
              Clipboard.setData(ClipboardData(text: debugLog.join('\n')));
            }, child: Text('copy debug')), // TODO: remove
            if (widget.settings.allowManualTimeInput)
              _buildTimeInput(localizations),
            Form(
              key: recordFormKey,
              child: Column(
                children: [
                  const SizedBox(height: 16,),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildValueInput(localizations,
                        focusNode: sysFocusNode,
                        labelText: localizations.sysLong,
                        controller: sysController,
                        onSaved: (value) =>
                            setState(() => systolic = int.tryParse(value ?? '')),
                      ),
                      const SizedBox(width: 16,),
                      _buildValueInput(localizations,
                        labelText: localizations.diaLong,
                        controller: diaController,
                        onSaved: (value) =>
                            setState(() => diastolic = int.tryParse(value ?? '')),
                        focusNode: diaFocusNode,
                        validator: (value) {
                          if (widget.settings.validateInputs
                              && (int.tryParse(value ?? '') ?? 0)
                                  >= (int.tryParse(sysController.text) ?? 1)
                          ) {
                            return AppLocalizations.of(context)?.errDiaGtSys;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(width: 16,),
                      _buildValueInput(localizations,
                        labelText: localizations.pulLong,
                        controller: pulController,
                        focusNode: pulFocusNode,
                        onSaved: (value) =>
                            setState(() => pulse = int.tryParse(value ?? '')),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: TextFormField(
                      controller: noteController,
                      focusNode: noteFocusNode,
                      decoration: InputDecoration(
                        labelText: localizations.addNote,
                      ),
                      minLines: 1,
                      maxLines: 4,
                      onChanged: (value) {
                        if (value.isNotEmpty) _measurementFormActive = true;
                        final newLineCount = value.split('\n').length;
                        if (_noteCurrentNewLineCount != newLineCount) {
                          setState(() {
                            _noteCurrentNewLineCount = newLineCount;
                            Material.of(context).markNeedsPaint();
                          });
                        }
                      },
                      onSaved: (value) => setState(() => notes = value),
                    ),
                  ),
                  ColorSelectionListTile(
                    title: Text(localizations.color),
                    onMainColorChanged: (Color value) {
                      setState(() {
                        _measurementFormActive = true;
                        needlePin = (value == Colors.transparent) ? null
                            : MeasurementNeedlePin(value);
                      });
                    },
                    initialColor: needlePin?.color ?? Colors.transparent,
                    shape: _buildShapeBorder(needlePin?.color),
                  ),
                ],
              ),
            ),
            if (medications.isNotEmpty && widget.initialRecord == null)
              Form(
                key: medicationFormKey,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<Medicine?>(
                          isExpanded: true,
                          value: medications
                              .where((e) => e.id == medicineId).firstOrNull,
                          items: [
                            for (final e in medications)
                              DropdownMenuItem(
                                value: e,
                                child: Text(e.designation),
                              ),
                            DropdownMenuItem(
                              child: Text(localizations.noMedication),
                            ),
                          ], // TODO: auto select dosis on pick
                          onChanged: (v) {
                            setState(() {
                              if (v != null) {
                                _showMedicineDosisInput = true;
                                medicineId = v.id;
                                medicineDosis = v.defaultDosis;
                              } else {
                                _showMedicineDosisInput = false;
                                medicineId = null;
                              }
                            });
                          },
                        ),
                      ),
                      if (_showMedicineDosisInput)
                        const SizedBox(width: 16,),
                      if (_showMedicineDosisInput)
                        Expanded(
                          child: TextFormField(
                            initialValue: medicineDosis?.toString(),
                            decoration: InputDecoration(
                              labelText: localizations.dosis,
                            ),
                            keyboardType: TextInputType.number,
                            onChanged: (value) {
                              setState(() {
                                final dosis = int.tryParse(value)?.toDouble()
                                    ?? double.tryParse(value);
                                if(dosis != null && dosis > 0) medicineDosis = dosis;
                              });
                            },
                            inputFormatters: [FilteringTextInputFormatter.allow(
                              RegExp(r'([0-9]+(\.([0-9]*))?)'),),],
                            validator: (String? value) {
                              if (!_showMedicineDosisInput) return null;
                              if (((int.tryParse(value ?? '')?.toDouble()
                                  ?? double.tryParse(value ?? '')) ?? 0) <= 0) {
                                return localizations.errNaN;
                              }
                              return null;
                            },
                          ),
                        ),

                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Shows a dialoge to input a blood pressure measurement or a medication.
Future<(BloodPressureRecord?, MedicineIntake?)?> showAddEntryDialoge(
    BuildContext context,
    Settings settings,
    [BloodPressureRecord? initialRecord,]) =>
  showDialog<(BloodPressureRecord?, MedicineIntake?)>(
      context: context, builder: (context) =>
      Dialog.fullscreen(
        child: AddEntryDialoge(
          settings: settings,
          initialRecord: initialRecord,
        ),
      ),
  );
