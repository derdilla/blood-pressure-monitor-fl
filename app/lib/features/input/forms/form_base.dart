import 'package:flutter/material.dart';

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
  /// Validates all form fields and shows errors on failing form fields.
  ///
  /// Returns whether the all fields validated without error.
  bool validate();

  /// Parses and returns the forms current value, if [validate] passes.
  T? save();
}


