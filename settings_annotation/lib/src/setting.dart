import 'package:flutter/widgets.dart';

class Setting<T> with ChangeNotifier {
  Setting({
    required T initialValue,
    this.name,
    this.titleBuilder,
    this.descriptionBuilder,
    this.iconBuilder,
  }) : _value = initialValue;

  /// For serialization
  final String? name;

  Object? toMapValue() => value;

  void fromMapValue(Object? value) {
    if (value == null) return;
    this.value = value as T;
  }

  T _value;

  /// Current value.
  T get value => _value;
  set value(T newValue) {
    _value = newValue;
    notifyListeners();
  }

  final String? Function(BuildContext context)? titleBuilder;

  final String? Function(BuildContext context)? descriptionBuilder;

  final Widget? Function(BuildContext context)? iconBuilder;
}
