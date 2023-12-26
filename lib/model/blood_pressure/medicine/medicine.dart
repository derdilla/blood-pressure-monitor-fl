import 'dart:ui';

import 'package:blood_pressure_app/model/blood_pressure/medicine/medicine_intake.dart';
import 'package:flutter/material.dart';

/// Description of a specific medicine.
class Medicine {
  /// Create a new medicine.
  const Medicine({
    required this.designation,
    required this.color,
    required this.defaultDosis
  });

  /// Name of the medicine.
  final String designation;

  /// Color used to display medicine intake
  final Color color;

  /// Default dosis used to autofill [MedicineIntake].
  final double? defaultDosis;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Medicine &&
          runtimeType == other.runtimeType &&
          designation == other.designation &&
          color == other.color &&
          defaultDosis == other.defaultDosis;

  @override
  int get hashCode => designation.hashCode ^ color.hashCode ^ defaultDosis.hashCode;
}
