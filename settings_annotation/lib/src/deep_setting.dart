import 'package:flutter/widgets.dart';
import 'package:settings_annotation/src/setting.dart';

/// [Setting] with interior mutability.
class DeepSetting<T extends ChangeNotifier> extends Setting<T> {
  DeepSetting({
    required super.initialValue,
    super.name,
    super.titleBuilder,
    super.descriptionBuilder,
    super.iconBuilder,
  }) {
    value.addListener(notifyListeners);
  }

  @override
  void dispose() {
    value.dispose();
    super.dispose();
  }

  @override
  set value(T newValue) {
    super.value.dispose();
    newValue.addListener(notifyListeners);
    super.value = newValue;
  }

}
