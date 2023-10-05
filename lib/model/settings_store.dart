import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// TODO: remove file


enum _TimeStep {
  day,
  month,
  year,
  lifetime,
  week,
  last7Days,
  last30Days,
  custom;

  static const options = [_TimeStep.day, _TimeStep.week, _TimeStep.month, _TimeStep.year, _TimeStep.lifetime, _TimeStep.last7Days, _TimeStep.last30Days, _TimeStep.custom];

  static String getName(_TimeStep opt, BuildContext context) {
    switch (opt) {
      case _TimeStep.day:
        return AppLocalizations.of(context)!.day;
      case _TimeStep.month:
        return AppLocalizations.of(context)!.month;
      case _TimeStep.year:
        return AppLocalizations.of(context)!.year;
      case _TimeStep.lifetime:
        return AppLocalizations.of(context)!.lifetime;
      case _TimeStep.week:
        return AppLocalizations.of(context)!.week;
      case _TimeStep.last7Days:
        return AppLocalizations.of(context)!.last7Days;
      case _TimeStep.last30Days:
        return AppLocalizations.of(context)!.last30Days;
      case _TimeStep.custom:
        return AppLocalizations.of(context)!.custom;
    }
  }
}

MaterialColor createMaterialColor(int value) { // TODO: remove
  final color = Color(value);
  List strengths = <double>[.05];
  Map<int, Color> swatch = {};
  final int r = color.red, g = color.green, b = color.blue;

  for (int i = 1; i < 10; i++) {
    strengths.add(0.1 * i);
  }
  for (var strength in strengths) {
    final double ds = 0.5 - strength;
    swatch[(strength * 1000).round()] = Color.fromRGBO(
      r + ((ds < 0 ? r : (255 - r)) * ds).round(),
      g + ((ds < 0 ? g : (255 - g)) * ds).round(),
      b + ((ds < 0 ? b : (255 - b)) * ds).round(),
      1,
    );
  }
  return MaterialColor(value, swatch);
}
