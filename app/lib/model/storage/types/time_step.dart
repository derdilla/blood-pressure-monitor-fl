import 'package:blood_pressure_app/l10n/app_localizations.dart';
import 'package:blood_pressure_app/model/storage/convert_util.dart';

/// Different range types supported by the interval switcher.
enum TimeStep {
  day,
  month,
  year,
  lifetime,
  week,
  last7Days,
  last30Days,
  custom;

  /// Recreate a TimeStep from a number created with [TimeStep.serialize].
  factory TimeStep.deserialize(Object? value) {
    final int? intValue = ConvertUtil.parseInt(value);
    assert(intValue == null || intValue >= 0 && intValue <= 7);
    return switch (intValue) {
      null => TimeStep.last7Days,
      0 => TimeStep.day,
      1 => TimeStep.month,
      2 => TimeStep.year,
      3 => TimeStep.lifetime,
      4 => TimeStep.week,
      5 => TimeStep.last7Days,
      6 => TimeStep.last30Days,
      7 => TimeStep.custom,
      _ => TimeStep.last7Days,
    };
  }

  /// Select a displayable string from [localizations].
  String localize(AppLocalizations localizations) => switch (this) {
    TimeStep.day => localizations.day,
    TimeStep.month => localizations.month,
    TimeStep.year => localizations.year,
    TimeStep.lifetime => localizations.lifetime,
    TimeStep.week => localizations.week,
    TimeStep.last7Days => localizations.last7Days,
    TimeStep.last30Days => localizations.last30Days,
    TimeStep.custom =>  localizations.custom,
  };

  int serialize() =>switch (this) {
    TimeStep.day => 0,
    TimeStep.month => 1,
    TimeStep.year => 2,
    TimeStep.lifetime => 3,
    TimeStep.week => 4,
    TimeStep.last7Days => 5,
    TimeStep.last30Days => 6,
    TimeStep.custom => 7,
  };
}
