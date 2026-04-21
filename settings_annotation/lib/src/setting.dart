import 'package:flutter/widgets.dart';

class Setting<T> {
  Setting({
    /// Initial value.
    required T initialValue,
    this.name,
    this.titleBuilder,
    this.descriptionBuilder,
    this.iconBuilder,
  }) : value = initialValue;

  /// For serialization
  final String? name;

  Object? toMapValue() => value;

  void fromMapValue(Object? value) => value = value;

  /// Current data
  T value;

  final String? Function(BuildContext context)? titleBuilder;

  final String? Function(BuildContext context)? descriptionBuilder;

  final Widget? Function(BuildContext context)? iconBuilder;
}

extension BoolToSetting on bool {
  Setting<bool> toSetting() => Setting(initialValue: this);
}

extension BoolOptToSetting on bool? {
  Setting<bool?> toSetting() => Setting(initialValue: this);
}
