import 'dart:async';

import 'package:blood_pressure_app/features/bluetooth/backend/bluetooth_backend.dart';
import 'package:blood_pressure_app/features/bluetooth/bluetooth_input.dart';
import 'package:blood_pressure_app/features/bluetooth/logic/bluetooth_cubit.dart';
import 'package:blood_pressure_app/features/input/forms/blood_pressure_form.dart';
import 'package:blood_pressure_app/features/input/forms/date_time_form.dart';
import 'package:blood_pressure_app/features/input/forms/form_base.dart';
import 'package:blood_pressure_app/features/input/forms/form_switcher.dart';
import 'package:blood_pressure_app/features/input/forms/medicine_intake_form.dart';
import 'package:blood_pressure_app/features/input/forms/note_form.dart';
import 'package:blood_pressure_app/features/input/forms/weight_form.dart';
import 'package:blood_pressure_app/features/old_bluetooth/bluetooth_input.dart';
import 'package:blood_pressure_app/l10n/app_localizations.dart';
import 'package:blood_pressure_app/logging.dart';
import 'package:blood_pressure_app/model/storage/bluetooth_input_mode.dart';
import 'package:blood_pressure_app/model/storage/storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_data_store/health_data_store.dart';
import 'package:provider/provider.dart';

/// Primary form to enter all types of entries.
class AddEntryForm extends FormBase<AddEntryFormValue> with TypeLogger {
  /// Create primary form to enter all types of entries.
  const AddEntryForm({super.key,
    super.initialValue,
    this.meds = const [],
    this.bluetoothCubit,
    this.mockBleInput,
  });

  /// All medicines selectable.
  ///
  /// Hides med input when this is empty.
  final List<Medicine> meds;

  /// Function to customize [BluetoothCubit] creation.
  ///
  /// Works on [BluetoothInputMode.newBluetoothInputCrossPlatform].
  @visibleForTesting
  final BluetoothCubit Function()? bluetoothCubit;

  /// A builder for a widget that can act as a bluetooth input.
  @visibleForTesting
  final Widget Function(void Function(BloodPressureRecord data))? mockBleInput;

  @override
  FormStateBase createState() => AddEntryFormState();
}

/// State of primary form to enter all types of entries.
class AddEntryFormState extends FormStateBase<AddEntryFormValue, AddEntryForm>
    with TypeLogger {
  final _timeForm = GlobalKey<DateTimeFormState>();
  final _noteForm = GlobalKey<NoteFormState>();
  final _bpForm = GlobalKey<BloodPressureFormState>();
  final _weightForm = GlobalKey<WeightFormState>();
  final _intakeForm = GlobalKey<MedicineIntakeFormState>();

  final _controller = FormSwitcherController();

  // because these values are no necessarily in tree a copy is needed to get
  // overridden values.
  BloodPressureRecord? _lastSavedPressure;
  BodyweightRecord? _lastSavedWeight;
  MedicineIntake? _lastSavedIntake;

  @override
  void initState() {
    super.initState();
    logger.finer('Initializing with ${widget.initialValue}');
    if (widget.initialValue != null) {
      _lastSavedPressure = widget.initialValue?.record;
      _lastSavedWeight = widget.initialValue?.weight;
      _lastSavedIntake = widget.initialValue?.intake;
      if (widget.initialValue!.record == null
          && widget.initialValue!.intake == null
          && widget.initialValue!.weight != null) {
        _controller.animateTo(widget.meds.isEmpty ? 1 : 2);
      } else if (widget.initialValue!.record == null
          && widget.initialValue!.intake != null) {
        _controller.animateTo(1);
      }
      // In all other cases we are at the correct position (0)
      // or don't need to jump at all.
    }
    ServicesBinding.instance.keyboard.addHandler(_onKey);
  }

  @override
  void dispose() {
    ServicesBinding.instance.keyboard.removeHandler(_onKey);
    super.dispose();
  }

  bool _onKey(KeyEvent event) {
    if(event.logicalKey == LogicalKeyboardKey.backspace
      && ((_bpForm.currentState?.isEmptyInputFocused() ?? false)
          || (_noteForm.currentState?.isEmptyInputFocused() ?? false)
          || (_weightForm.currentState?.isEmptyInputFocused() ?? false)
          || (_intakeForm.currentState?.isEmptyInputFocused() ?? false))) {
      FocusScope.of(context).previousFocus();
    }
    return false;
  }

  @override
  bool validate() {
    final timeFormValidation = _timeForm.currentState?.validate();
    final noteFormValidation = _noteForm.currentState?.validate();
    final bpFormValidation = _bpForm.currentState?.validate();
    final weightFormValidation = _weightForm.currentState?.validate();
    final intakeFormValidation = _intakeForm.currentState?.validate();
    logger.fine('validating...');
    logger.finest('time: $timeFormValidation');
    logger.finest('note: $noteFormValidation');
    logger.finest('bp: $bpFormValidation');
    logger.finest('weight: $weightFormValidation');
    logger.finest('intake: $intakeFormValidation');
    return !context.read<Settings>().validateInputs
    || (timeFormValidation ?? false)
    && (noteFormValidation ?? false)
    // the following become null when unopened
    && (bpFormValidation ?? true)
    && (weightFormValidation ?? true)
    && (intakeFormValidation ?? true);
  }

  @override
  AddEntryFormValue? save() {
    logger.fine('Calling save');
    if (!validate()) return null;
    final time = _timeForm.currentState!.save()!;
    Note? note;
    BloodPressureRecord? record = _lastSavedPressure;
    BodyweightRecord? weight = _lastSavedWeight;
    MedicineIntake? intake = _lastSavedIntake;

    final noteFormValue = _noteForm.currentState?.save();
    if (noteFormValue != null) {
      note = Note(time: time, note: noteFormValue.$1, color: noteFormValue.$2?.toARGB32());
    }
    final recordFormValue = _bpForm.currentState?.save();
    if (recordFormValue != null) {
      final unit = context.read<Settings>().preferredPressureUnit;
      record = BloodPressureRecord(
        time: time,
        sys: recordFormValue.sys == null ? null : unit.wrap(recordFormValue.sys!),
        dia: recordFormValue.dia == null ? null : unit.wrap(recordFormValue.dia!),
        pul: recordFormValue.pul,
      );
    }
    final weightFormValue = _weightForm.currentState?.save();
    if (weightFormValue != null) {
      weight = BodyweightRecord(time: time, weight: weightFormValue);
    }
    final intakeFormValue = _intakeForm.currentState?.save();
    if (intakeFormValue != null) {
      intake = MedicineIntake(
        time: time,
        medicine: intakeFormValue.$1,
        dosis: intakeFormValue.$2,
      );
    }
    logger.finer('Saving values: $note, $record, $weight, $intake');

    if (note == null
      && record == null
      && weight == null
      && intake == null) {
      logger.fine('note, record, weight, and intake are null: returning null');
      return null;
    }
    return (
      timestamp: time,
      note: note,
      record: record,
      intake: intake,
      weight: weight,
    );
  }

  @override
  bool isEmptyInputFocused() => false; // doesn't contain text inputs

  @override
  void fillForm(AddEntryFormValue? value) {
    logger.finer('fillForm($value)');
    _lastSavedPressure = value?.record;
    _lastSavedWeight = value?.weight;
    _lastSavedIntake = value?.intake;
    if (value == null) {
      _timeForm.currentState?.fillForm(null);
      _noteForm.currentState?.fillForm(null);
      _bpForm.currentState?.fillForm(null);
      _weightForm.currentState?.fillForm(null);
      _intakeForm.currentState?.fillForm(null);
    } else {
      _timeForm.currentState?.fillForm(value.timestamp);
      if (value.note != null) {
        final c = value.note?.color == null ? null : Color(value.note!.color!);
        _noteForm.currentState?.fillForm((value.note!.note, c));
      }
      if (value.record != null) {
        _bpForm.currentState?.fillForm((
          sys: value.record?.sys?.mmHg,
          dia: value.record?.dia?.mmHg,
          pul: value.record?.pul,
        ));
      }
      if (value.weight != null) {
        _weightForm.currentState?.fillForm(value.weight!.weight);
      }
      if (value.intake != null) {
        _intakeForm.currentState?.fillForm((
          value.intake!.medicine,
          value.intake!.dosis,
        ));
      }
    }
  }

  /// Gets called on inputs from a bluetooth device or similar.
  void _onExternalMeasurement(BloodPressureRecord record) {
    final settings = context.read<Settings>();
    if (settings.trustBLETime
      // TODO: don't show hint too often
        && record.time.difference(DateTime.now()).inHours > 5) {
      // FIXME: this is completely untested
      unawaited(showDialog(context: context, builder: (context) => AlertDialog(
        content: Text(AppLocalizations.of(context)!.warnBLETimeSus(
          record.time.difference(DateTime.now()).inHours
        )),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.btnConfirm),
          ),
        ],
      )));
    }

    fillForm((
      timestamp: settings.trustBLETime
          ? record.time
          : _timeForm.currentState?.save() ?? DateTime.now(),
      note: null,
      record: record,
      intake: null,
      weight: null,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<Settings>();
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      children: [
        if (widget.mockBleInput != null)
          widget.mockBleInput!.call(_onExternalMeasurement),
        (() => switch (settings.bleInput) {
          BluetoothInputMode.disabled => SizedBox.shrink(),
          BluetoothInputMode.oldBluetoothInput => OldBluetoothInput(
            onMeasurement: _onExternalMeasurement,
          ),
          BluetoothInputMode.newBluetoothInputOldLib => BluetoothInput(
            manager: BluetoothManager.create(BluetoothBackend.flutterBluePlus),
            onMeasurement: _onExternalMeasurement,
          ),
          BluetoothInputMode.newBluetoothInputCrossPlatform => BluetoothInput(
            manager: BluetoothManager.create(BluetoothBackend.bluetoothLowEnergy),
            onMeasurement: _onExternalMeasurement,
          ),
        })(),
        if (settings.allowManualTimeInput)
          DateTimeForm(
            key: _timeForm,
            initialValue: widget.initialValue?.timestamp,
          ),
        SizedBox(height: 10),
        FormSwitcher(
          key: Key('AddEntryFormSwitcher'), // ensures widgets are in tree
          controller: _controller,
          subForms: [
            (Icon(Icons.monitor_heart_outlined), BloodPressureForm(
              key: _bpForm,
              initialValue: (
                sys: widget.initialValue?.record?.sys?.mmHg,
                dia: widget.initialValue?.record?.dia?.mmHg,
                pul: widget.initialValue?.record?.pul,
              ),
            )),
            if (widget.meds.isNotEmpty)
              (Icon(Icons.medication_outlined), MedicineIntakeForm(
                key: _intakeForm,
                meds: widget.meds,
                initialValue: widget.initialValue?.intake == null ? null : (
                  widget.initialValue!.intake!.medicine,
                  widget.initialValue!.intake!.dosis,
                ),
              )),
            if (settings.weightInput)
              (Icon(Icons.scale), WeightForm(
                key: _weightForm,
                initialValue: widget.initialValue?.weight?.weight,
              ),),
          ],
        ),
        NoteForm(
          key: _noteForm,
          initialValue: (){
            logger.fine('NoteForm.initialValue: ${widget.initialValue?.note}');
            if (widget.initialValue?.note == null) return null;
            final note = widget.initialValue!.note!;
            final color = note.color == null ? null : Color(note.color!);
            return (note.note, color);
          }(),
        ),
      ]
    );
  }
}

/// Types of entries supported by [AddEntryForm].
typedef AddEntryFormValue = ({
  DateTime timestamp,
  Note? note,
  BloodPressureRecord? record,
  MedicineIntake? intake,
  BodyweightRecord? weight,
});

/// Compatibility extension for simpler API surface.
extension AddEntryFormValueCompat on FullEntry {
  /// Utility converter for the differences in API.
  AddEntryFormValue get asAddEntry {
    assert(intakes.length <= 1);
    return (
      timestamp: time,
      note: (note == null && color == null) ? null : noteObj,
      record: (sys == null && dia == null && pul == null) ? null : recordObj,
      intake: intakes.firstOrNull,
      weight: null,
    );
  }
}
