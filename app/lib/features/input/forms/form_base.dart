import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Base for a generic form with return value [T].
abstract class FormBase<T> extends StatefulWidget {
  /// Create a form with generic return value.
  const FormBase({super.key, this.initialValue});

  /// Initial value to prefill the form with.
  final T? initialValue;

  @override
  FormStateBase createState();
}

/// State of a form allowing validation and result gathering using [GlobalKey].
///
/// ### Sample usage
/// ```dart
/// class SomeWidgetState extends State<SomeWidget> {
///   final key = GlobalKey<FormStateBase>();
///   ...
///   FormBase(key: key),
///   ...
///   TextButton(
///     child: Text('save'),
///     onPressed: () => if (_timeFormState.currentState?.validate() ?? false) {
///       Navigator.pop(context, _timeFormState.currentState!.save());
///     },
///   )
/// ```
abstract class FormStateBase<T, G extends FormBase> extends State<G> {
  @override
  void initState() {
    super.initState();
    ServicesBinding.instance.keyboard.addHandler(_onKey);
  }

  @override
  void dispose() {
    ServicesBinding.instance.keyboard.removeHandler(_onKey);
    super.dispose();
  }

  bool _onKey(KeyEvent event) {
    if (event is KeyDownEvent
        && event.logicalKey == LogicalKeyboardKey.backspace
        && isEmptyInputFocused()
        && !FocusScope.of(context).isFirstFocus) {
      FocusScope.of(context).previousFocus();
      return true;
    }
    return false;
  }

  /// Validates all form fields and shows errors on failing form fields.
  ///
  /// Returns whether the all fields validated without error.
  bool validate();

  /// Parses and returns the forms current value, if [validate] passes.
  T? save();

  /// Whether an empty input field is focused.
  ///
  /// Used to automatically focus the last input field on back key.
  @protected
  bool isEmptyInputFocused();

  /// Set the input fields with the [value].
  ///
  /// If [value} is null clear the form. If value contains attributes that
  /// correspond to different fields, only the non null attributes change field
  /// contents.
  void fillForm(T? value);
}


