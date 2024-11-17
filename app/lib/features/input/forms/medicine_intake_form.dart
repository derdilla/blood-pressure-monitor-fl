import 'package:blood_pressure_app/features/input/forms/form_base.dart';
import 'package:flutter/material.dart';
import 'package:health_data_store/health_data_store.dart';

/// Form to enter medicine intakes.
class MedicineIntakeForm extends FormBase<MedicineIntake> {
  /// Create form to enter medicine intakes.
  const MedicineIntakeForm({super.key});

  @override
  FormStateBase<MedicineIntake, MedicineIntakeForm> createState() =>
    MedicineIntakeFormState();
}

/// State of form to enter medicine intakes.
class MedicineIntakeFormState extends FormStateBase<MedicineIntake, MedicineIntakeForm> {
  @override
  bool validate() {
    // TODO: implement validate
    return false;
  }

  @override
  MedicineIntake? save() {
    // TODO: implement save
    return null;
  }

  @override
  Widget build(BuildContext context) {
    // TODO
    return const Placeholder();
  }

  @override
  bool isEmptyInputFocused() {
    // TODO: implement isEmptyInputFocused
    return false;
  }
}
