import 'package:blood_pressure_app/components/nullable_text.dart';
import 'package:blood_pressure_app/model/blood_pressure/pressure_unit.dart';
import 'package:blood_pressure_app/model/storage/settings_store.dart';
import 'package:flutter/material.dart';
import 'package:health_data_store/health_data_store.dart';
import 'package:provider/provider.dart';

/// A display [pressure] in the correct [Settings.preferredPressureUnit].
class PressureText extends StatelessWidget {
  /// Display a [pressure] in the correct [Settings.preferredPressureUnit].
  const PressureText(this.pressure, {super.key});

  /// Pressure to display.
  ///
  /// When this is null a placeholder '-' is displayed.
  final Pressure? pressure;

  @override
  Widget build(BuildContext context) => NullableText(
    switch (context.watch<Settings>().preferredPressureUnit) {
      PressureUnit.mmHg => pressure?.mmHg,
      PressureUnit.kPa => pressure?.kPa,
    }.toString(),
  );
}
