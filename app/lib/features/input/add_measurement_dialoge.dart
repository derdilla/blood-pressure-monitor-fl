import 'dart:async';

import 'package:blood_pressure_app/components/fullscreen_dialoge.dart';
import 'package:blood_pressure_app/features/bluetooth/backend/bluetooth_backend.dart';
import 'package:blood_pressure_app/features/bluetooth/bluetooth_input.dart';
import 'package:blood_pressure_app/features/input/add_bodyweight_dialoge.dart';
import 'package:blood_pressure_app/features/input/forms/date_time_form.dart';
import 'package:blood_pressure_app/features/settings/tiles/color_picker_list_tile.dart';
import 'package:blood_pressure_app/model/blood_pressure/pressure_unit.dart';
import 'package:blood_pressure_app/model/storage/storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:health_data_store/health_data_store.dart';
import 'package:provider/provider.dart';

/// Input mask for entering measurements.
class AddEntryDialoge extends StatefulWidget {
  /// Create a input mask for entering measurements.
  /// 
  /// This is usually created through the [showAddEntryDialoge] function.
  const AddEntryDialoge({super.key,
    required this.availableMeds,
    this.initialRecord,
  });

  /// Values that are prefilled.
  ///
  /// When this is null the timestamp is [DateTime.now] and the other fields
  /// will be empty.
  ///
  /// When an initial record is set medicine input is not possible because it is
  /// saved separately.
  final FullEntry? initialRecord;

  /// All medicines selectable.
  ///
  /// Hides med input when this is empty.
  final List<Medicine> availableMeds;

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
  final dosisFocusNote = FocusNode();

  late final TextEditingController sysController;
  late final TextEditingController diaController;
  late final TextEditingController pulController;
  late final TextEditingController noteController;

  /// Currently selected time.
  late DateTime time;

  /// Current selected note color.
  Color? color;

  /// Last [FormState.save]d systolic value.
  int? systolic;

  /// Last [FormState.save]d diastolic value.
  int? diastolic;

  /// Last [FormState.save]d pulse value.
  int? pulse;
  
  /// Medicine to save.
  Medicine? selectedMed;

  /// Whether to show the medication dosis input
  bool _showMedicineDosisInput = false;

  /// Entered dosis of medication.
  ///
  /// Prefilled with default dosis of selected medicine.
  double? medicineDosis;

  @override
  void initState() {
    super.initState();
    sysController = TextEditingController();
    diaController = TextEditingController();
    pulController = TextEditingController();
    noteController = TextEditingController();
    _loadFields(widget.initialRecord);

    sysFocusNode.requestFocus();
    ServicesBinding.instance.keyboard.addHandler(_onKey);
  }


  @override
  void dispose() {
    sysController.dispose();
    diaController.dispose();
    pulController.dispose();
    noteController.dispose();

    sysFocusNode.dispose();
    diaFocusNode.dispose();
    pulFocusNode.dispose();
    noteFocusNode.dispose();
    ServicesBinding.instance.keyboard.removeHandler(_onKey);
    super.dispose();
  }

  /// Sets fields to values in a [record].
  void _loadFields(FullEntry? entry) {
    final settings = context.read<Settings>();
    time = entry?.time ?? DateTime.now();
    final int? colorValue = entry?.color;
    final sysValue = switch(settings.preferredPressureUnit) {
      PressureUnit.mmHg => entry?.sys?.mmHg,
      PressureUnit.kPa => entry?.sys?.kPa.round(),
    };
    final diaValue = switch(settings.preferredPressureUnit) {
      PressureUnit.mmHg => entry?.dia?.mmHg,
      PressureUnit.kPa => entry?.dia?.kPa.round(),
    };
    if (colorValue != null) color = Color(colorValue);
    if (entry?.sys != null) sysController.text = sysValue.toString();
    if (entry?.dia != null) diaController.text = diaValue.toString();
    if (entry?.pul != null) pulController.text = entry!.pul!.toString();
    if (entry?.note != null) noteController.text = entry!.note!;
  }

  bool _onKey(KeyEvent event) {
    if (event is! KeyDownEvent) return false;
    final isBackspace = event.logicalKey.keyId == 0x00100000008;
    if (!isBackspace) return false;
    recordFormKey.currentState?.save();
    if (diaFocusNode.hasFocus && diastolic == null 
        || pulFocusNode.hasFocus && pulse == null
        || noteFocusNode.hasFocus && noteController.text.isEmpty
    ) {
      FocusScope.of(context).previousFocus();
    }
    return false;
  }

  /// Build a input for values in the measurement form (sys, dia, pul).
  Widget _buildValueInput(AppLocalizations localizations, Settings settings, {
    String? labelText,
    void Function(String?)? onSaved,
    FocusNode? focusNode,
    TextEditingController? controller,
    String? Function(String?)? validator,
  }) => Expanded(
    child: TextFormField(
      decoration: InputDecoration(
        labelText: labelText,
      ),
      keyboardType: TextInputType.number,
      focusNode: focusNode,
      onSaved: onSaved,
      controller: controller,
      style: Theme.of(context).textTheme.bodyLarge,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      onChanged: (String value) {
        if (value.isNotEmpty
            && (int.tryParse(value) ?? -1) > 40) {
          FocusScope.of(context).nextFocus();
        }
      },
      validator: (String? value) {
        if (!settings.allowMissingValues
            && (value == null
                || value.isEmpty
                || int.tryParse(value) == null)) {
          return localizations.errNaN;
        } else if (settings.validateInputs
            && (int.tryParse(value ?? '') ?? -1) <= 30) {
          return localizations.errLt30;
        } else if (settings.validateInputs
            && (int.tryParse(value ?? '') ?? 0) >= 400) {
          // https://pubmed.ncbi.nlm.nih.gov/7741618/
          return localizations.errUnrealistic;
        }
        return validator?.call(value);
      },
    ),
  );

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final settings = context.watch<Settings>();
    return FullscreenDialoge(
      onActionButtonPressed: () {
        BloodPressureRecord? record;
        Note? note;
        final List<MedicineIntake> intakes = [];

        final bool shouldHaveRecord = (sysController.text.isNotEmpty
          || diaController.text.isNotEmpty
          || pulController.text.isNotEmpty);

        if (shouldHaveRecord && (recordFormKey.currentState?.validate() ?? false)) {
          recordFormKey.currentState?.save();
          if (systolic != null || diastolic != null || pulse != null) {
            final pressureUnit = settings.preferredPressureUnit;
            record = BloodPressureRecord(
              time: time,
              sys: systolic == null ? null : pressureUnit.wrap(systolic!),
              dia: diastolic == null ? null : pressureUnit.wrap(diastolic!),
              pul: pulse,
            );
          }
        }


        if (noteController.text.isNotEmpty || color != null) {
          note = Note(
            time: time,
            note: noteController.text.isEmpty ? null : noteController.text,
            color: color?.value,
          );
        }
        if (_showMedicineDosisInput
            && (medicationFormKey.currentState?.validate() ?? false)) {
          medicationFormKey.currentState?.save();
          if (medicineDosis != null
              && selectedMed != null) {
            intakes.add(MedicineIntake(
              time: time,
              medicine: selectedMed!,
              dosis: Weight.mg(medicineDosis!),
            ));
          }
        }

        if (record != null || intakes.isNotEmpty || note != null) {
          if (record == null && shouldHaveRecord) return; // Errors are shown
          if (intakes.isEmpty && _showMedicineDosisInput) return; // Errors are shown
          record ??= BloodPressureRecord(time: time);
          note ??= Note(time: time);
          Navigator.pop(context, (record, note, intakes));
        }
      },
      actionButtonText: localizations.btnSave,
      bottomAppBar: settings.bottomAppBars,
      body: SizeChangedLayoutNotifier(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          children: [
            if (settings.bleInput)
              BluetoothInput(
                manager: BluetoothManager.create(),
                onMeasurement: (record) => setState(
                  () => _loadFields((record, Note(time: record.time, note: noteController.text, color: color?.value), [])),
                ),
              ),
            if (settings.allowManualTimeInput)
              DateTimeForm(
                validate: settings.validateInputs,
                initialTime: time,
                onTimeSelected: (newTime) => setState(() {
                  time = newTime;
                }),
              ),
            Form(
              key: recordFormKey,
              child: Column(
                children: [
                  const SizedBox(height: 16,),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildValueInput(localizations, settings,
                        focusNode: sysFocusNode,
                        labelText: localizations.sysLong,
                        controller: sysController,
                        onSaved: (value) =>
                            setState(() => systolic = int.tryParse(value ?? '')),
                      ),
                      const SizedBox(width: 8,),
                      _buildValueInput(localizations, settings,
                        labelText: localizations.diaLong,
                        controller: diaController,
                        onSaved: (value) =>
                            setState(() => diastolic = int.tryParse(value ?? '')),
                        focusNode: diaFocusNode,
                        validator: (value) {
                          if (settings.validateInputs
                              && (int.tryParse(value ?? '') ?? 0)
                                  >= (int.tryParse(sysController.text) ?? 1)
                          ) {
                            return AppLocalizations.of(context)?.errDiaGtSys;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(width: 8,),
                      _buildValueInput(localizations, settings,
                        labelText: localizations.pulLong,
                        controller: pulController,
                        focusNode: pulFocusNode,
                        onSaved: (value) =>
                            setState(() => pulse = int.tryParse(value ?? '')),
                      ),
                    ],
                  ),
                ],
              ),
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
              ),
            ),
            InputDecorator(
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.zero,
              ),
              child: ColorSelectionListTile(
                title: Text(localizations.color, style: Theme.of(context).textTheme.bodyLarge,),
                onMainColorChanged: (Color value) => setState(() {
                  color = (value == Colors.transparent) ? null : value;
                }),
                initialColor: color ?? Colors.transparent,
              ),
            ),
            if (widget.initialRecord == null && widget.availableMeds.isNotEmpty)
              Form(
                key: medicationFormKey,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<Medicine?>(
                          isExpanded: true,
                          value: selectedMed,
                          items: [
                            for (final med in widget.availableMeds)
                              DropdownMenuItem(
                                value: med,
                                child: Text(med.designation, style: Theme.of(context).textTheme.bodyLarge,),
                              ),
                            DropdownMenuItem(
                              child: Text(localizations.noMedication, style: Theme.of(context).textTheme.bodyLarge,),
                            ),
                          ],
                          onChanged: (v) {
                            setState(() {
                              if (v != null) {
                                _showMedicineDosisInput = true;
                                selectedMed = v;
                                medicineDosis = v.dosis?.mg;
                                dosisFocusNote.requestFocus();
                              } else {
                                _showMedicineDosisInput = false;
                                selectedMed = null;
                              }
                            });
                          },
                        ),
                      ),
                      if (_showMedicineDosisInput)
                        const SizedBox(width: 14,),
                      if (_showMedicineDosisInput)
                        Expanded(
                          child: TextFormField(
                            initialValue: medicineDosis?.toString(),
                            decoration: InputDecoration(
                              labelText: localizations.dosis,
                            ),
                            style: Theme.of(context).textTheme.bodyLarge,
                            focusNode: dosisFocusNote,
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

            if (settings.weightInput)
              ListTile(
                title: Text(localizations.enterWeight),
                leading: const Icon(Icons.scale),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () async {
                  final repo = context.read<BodyweightRepository>();
                  final weight = await showDialog<Weight>(context: context, builder: (_) => const AddBodyweightDialoge());
                  if (weight != null) {
                    await repo.add(BodyweightRecord(time: time, weight: weight));
                    if (context.mounted) Navigator.pop(context);
                  }
                },
              ),
          ],
        ),
      ),
    );
  }
}

/// Shows a dialoge to input a blood pressure measurement or a medication.
Future<FullEntry?> showAddEntryDialoge(
  BuildContext context,
  MedicineRepository medRepo,
  [FullEntry? initialRecord,
]) async {
  final meds = await medRepo.getAll();
  return showDialog<FullEntry>(
    context: context, builder: (context) => AddEntryDialoge(
      initialRecord: initialRecord,
      availableMeds: meds,
    ),
  );
}
