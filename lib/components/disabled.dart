
import 'package:flutter/material.dart';

/// A widget that visually indicates that it's subtree is disabled and blocks all interaction with it.
class Disabled extends StatelessWidget {
  /// Create a widget that visually indicates that it's subtree is disabled and blocks interaction with it.
  ///
  /// If [disabled] is true the [child]s opacity gets reduced and interaction gets disabled. This widget has no effect
  /// when [disabled] is false.
  const Disabled({required this.child, this.disabled = true, this.ignoring = true, super.key});

  final Widget child;
  /// Whether this widget has an effect.
  final bool disabled;
  /// Whether interaction is blocked.
  final bool ignoring;

  @override
  Widget build(BuildContext context) {
    if (disabled) {
      return Opacity(
        opacity: 0.7,
        child: IgnorePointer(
          ignoring: ignoring,
          child: child,
        ),
      );
    }
    return child;
  }

}