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
  /// Guarantees that a [int] containing a [Color.value] is returned.
  ///
  /// Backwards compatability with [MeasurementNeedlePin] json is maintained.
  color;

  /// Selection of a displayable string from [localizations].
  String localize(AppLocalizations localizations) {
    switch(this) {
      case RowDataFieldType.timestamp:
        return localizations.timestamp;
      case RowDataFieldType.sys:
        return localizations.sysLong;
      case RowDataFieldType.dia:
        return localizations.diaLong;
      case pul:
        return localizations.pulLong;
      case RowDataFieldType.notes:
        return localizations.notes;
      case RowDataFieldType.color:
        return localizations.color;
    }
  }
}
