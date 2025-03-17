import 'package:blood_pressure_app/model/blood_pressure/needle_pin.dart';
import 'package:blood_pressure_app/model/export_import/record_formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


/// Type a [Formatter] can uses to indicate the kind of data returned.
enum RowDataFieldType {
  /// Guarantees [DateTime] is returned.
  timestamp,
  /// Guarantees [int] is returned.
  sys,
  /// Guarantees [int] is returned.
  dia,
  /// Guarantees [int] is returned.
  pul,
  /// Guarantees [String] is returned.
  notes,
  /// Guarantees that a [int] containing a [Color.toARGB32()] is returned.
  ///
  /// Backwards compatability with [MeasurementNeedlePin] json is maintained.
  color,
  /// Guarantees [List<(String medicineDesignation, double dosisMg)>] is returned.
  intakes,
  /// Guarantees a [double] is parsed.
  weightKg;

  /// Select the matching string from [localizations].
  String localize(AppLocalizations localizations) => switch(this) {
    timestamp => localizations.timestamp,
    sys => localizations.sysLong,
    dia => localizations.diaLong,
    pul => localizations.pulLong,
    notes => localizations.notes,
    color => localizations.color,
    intakes => localizations.intakes,
    weightKg => localizations.weight,
  };
}
