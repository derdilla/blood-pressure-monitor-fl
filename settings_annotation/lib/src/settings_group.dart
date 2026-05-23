import 'package:flutter/cupertino.dart';

abstract class SettingsGroup implements ChangeNotifier {
  /// Serialize the object to a restoreable map.
  Map<String, dynamic> toMap();

  /// Serialize the object to a restoreable string.
  String toJson();

  /// Shallow copy all values from another instance.
  void copyFrom(covariant SettingsGroup other);

  /// Copies all value from serialized other instance.
  ///
  /// Returns false if the [other] isn't valid json.
  bool copyFromJson(String other);

  /// Reset all fields to their default values.
  void reset();
}
