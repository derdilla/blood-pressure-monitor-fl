import 'dart:convert';
import 'dart:ui';

import 'package:blood_pressure_app/model/blood_pressure/medicine/medicine_intake.dart';
import 'package:flutter/material.dart';

/// Description of a specific medicine.
@deprecated
class Medicine {
  /// Create a instance from a map created by [toMap].
  factory Medicine.fromMap(Map<String, dynamic> map) => Medicine(
    map['id'],
    designation: map['designation'],
    color: Color(map['color']),
    defaultDosis: map['defaultDosis'],
    hidden: map.containsKey('hidden') ? map['hidden'] : false,
  );

  /// Create a instance from a [String] created by [toJson].
  factory Medicine.fromJson(String json) => Medicine.fromMap(jsonDecode(json));

  /// Create a new medicine.
  Medicine(this.id, {
    required this.designation,
    required this.color,
    required this.defaultDosis,
    this.hidden = false,
  });

  /// Serialize the object to a restoreable map.
  Map<String, dynamic> toMap() => {
    'id': id,
    'designation': designation,
    'color': color.value,
    'defaultDosis': defaultDosis,
    'hidden': hidden,
  };

  /// Serialize the object to a restoreable string.
  String toJson() => jsonEncode(toMap());

  /// Unique id used to store the medicine in serialized objects.
  final int id;

  /// Name of the medicine.
  final String designation;

  /// Color used to display medicine intake
  final Color color;

  /// Default dosis used to autofill [MedicineIntake].
  final double? defaultDosis;

  /// Indicates that this medicine should not be shown in selection menus.
  ///
  /// This is usually set when the user deletes the medicine in order to avoid
  /// data inconsistencies with existing intakes that use this medicine.
  bool hidden;


  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Medicine &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          designation == other.designation &&
          color.value == other.color.value &&
          defaultDosis == other.defaultDosis &&
          hidden == other.hidden;

  @override
  int get hashCode => id.hashCode ^ designation.hashCode ^ color.hashCode
      ^ defaultDosis.hashCode ^ hidden.hashCode;

  @override
  String toString() => 'Medicine{id: $id, designation: $designation, '
      'color: $color, defaultDosis: $defaultDosis, hidden: $hidden}';
}
