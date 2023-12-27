import 'dart:convert';
import 'dart:ui';

import 'package:blood_pressure_app/model/blood_pressure/medicine/medicine_intake.dart';
import 'package:flutter/material.dart';

/// Description of a specific medicine.
class Medicine {
  /// Create a new medicine.
  const Medicine(this.id, {
    required this.designation,
    required this.color,
    required this.defaultDosis
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'designation': designation,
    'color': color.value,
    'defaultDosis': defaultDosis
  };

  String toJson() => jsonEncode(toMap());

  factory Medicine.fromMap(Map<String, dynamic> map) => Medicine(
    map['id'],
    designation: map['designation'],
    color: Color(map['color']),
    defaultDosis: map['defaultDosis']
  );

  factory Medicine.fromJson(String json) => Medicine.fromMap(jsonDecode(json));

  /// Unique id used to store the medicine in serialized objects.
  final int id;

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
          id == other.id &&
          designation == other.designation &&
          color.value == other.color.value &&
          defaultDosis == other.defaultDosis;

  @override
  int get hashCode => id.hashCode ^ designation.hashCode ^ color.hashCode ^ defaultDosis.hashCode;

  @override
  String toString() {
    return 'Medicine{id: $id, designation: $designation, color: $color, defaultDosis: $defaultDosis}';
  }
}
