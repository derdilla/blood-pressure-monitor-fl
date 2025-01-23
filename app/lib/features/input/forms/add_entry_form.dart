import 'package:blood_pressure_app/features/input/forms/blood_pressure_form.dart';
import 'package:blood_pressure_app/features/input/forms/date_time_form.dart';
import 'package:blood_pressure_app/features/input/forms/form_base.dart';
import 'package:blood_pressure_app/features/input/forms/form_switcher.dart';
import 'package:blood_pressure_app/features/input/forms/medicine_intake_form.dart';
import 'package:blood_pressure_app/features/input/forms/note_form.dart';
import 'package:blood_pressure_app/features/input/forms/weight_form.dart';
import 'package:blood_pressure_app/logging.dart';
import 'package:blood_pressure_app/model/storage/storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_data_store/health_data_store.dart';
import 'package:provider/provider.dart';

/// Primary form to enter all types of entries.
class AddEntryForm extends FormBase<AddEntryFormValue>
    with TypeLogger {
  /// Create primary form to enter all types of entries.
  const AddEntryForm({super.key,
    super.initialValue,
    required this.meds,
  });

  /// All medicines selectable.
  ///
  /// Hides med input when this is empty.
  final List<Medicine> meds;

  @override
  FormStateBase createState() => AddEntryFormState();
}

/// State of primary form to enter all types of entries.
class AddEntryFormState extends FormStateBase<AddEntryFormValue, AddEntryForm> {
  final _timeForm = GlobalKey<DateTimeFormState>();
  final _noteForm = GlobalKey<NoteFormState>();
  final _bpForm = GlobalKey<BloodPressureFormState>();
  final _weightForm = GlobalKey<WeightFormState>();
  final _intakeForm = GlobalKey<MedicineIntakeFormState>();

  @override
  bool validate() {
    log.info('_timeForm validation: ${_timeForm.currentState?.validate()}');
    log.info('_noteForm validation: ${_noteForm.currentState?.validate()}');
    log.info('_bpForm validation: ${_bpForm.currentState?.validate()}');
    log.info('_weightForm validation: ${_weightForm.currentState?.validate()}');
    log.info('_intakeForm validation: ${_intakeForm.currentState?.validate()}');
    return (_timeForm.currentState?.validate() ?? false)
    && (_noteForm.currentState?.validate() ?? false)
    && ((_bpForm.currentState?.validate() ?? false)
      || (_weightForm.currentState?.validate() ?? false)
      || (_intakeForm.currentState?.validate() ?? false));
  }

  @override
  AddEntryFormValue? save() {
    if (!validate()) return null;
    final time = _timeForm.currentState!.save()!;
    Note? note;
    BloodPressureRecord? record;
    BodyweightRecord? weight;
    MedicineIntake? intake;

    final noteFormValue = _noteForm.currentState?.save();
    if (noteFormValue != null) {
      note = Note(time: time, note: noteFormValue.$1, color: noteFormValue.$2?.value);
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
      // TODO
      // intake = MedicineIntake(time: time, medicine: null, dosis: null);
    }
    return (
      timestamp: time,
      note: note,
      record: record,
      intake: intake,
      weight: weight,
    );
  }

  // doesn't contain inputs
  @override
  bool isEmptyInputFocused() => false;

  @override
  Widget build(BuildContext context) { // TODO: initial values
    //log.fine('Opening AddEntryForm with: ${widget.initialValue}');
    final settings = context.watch<Settings>();
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      children: [
        DateTimeForm(
          key: _timeForm,
          initialValue: widget.initialValue?.timestamp,
        ),
        SizedBox(height: 10),
        FormSwitcher(
          subforms: [
            (Icon(Icons.monitor_heart_outlined), BloodPressureForm(
              key: _bpForm,
              initialValue: (
                // TODO: pressure units
                sys: widget.initialValue?.record?.sys?.mmHg,
                dia: widget.initialValue?.record?.dia?.mmHg,
                pul: widget.initialValue?.record?.pul,
              ),
            )),
            if (widget.meds.isNotEmpty)
              (Icon(Icons.medication_outlined), MedicineIntakeForm(
                key: _intakeForm,
                initialValue: widget.initialValue?.intake,
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
            if (widget.initialValue?.note?.note == null) return null;
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
      note: noteObj,
      record: recordObj,
      intake: intakes.firstOrNull,
      weight: null,
    );
  }
}
