import 'package:flutter/material.dart';

/// A floating banner to display information and perform actions.
///
/// This custom banner is needed to allow for rounded app bar corners, which
/// would conflict with the material design banner.
///
/// Example usage:
/// ```dart
/// CustomBanner(
///   content: Text(localizations.warnNeedsRestartForUsingApp),
///   action: TextButton(
///     onPressed: () => Restart.restartApp(),
///     child: Text(localizations.restartNow),
///   )
/// )
/// ```
class CustomBanner extends StatelessWidget {
  /// Create a banner that displays information and an action.
  const CustomBanner({super.key, required this.content, this.action});

  /// The main content of the banner.
  ///
  /// Gets displayed on the left side.
  final Widget content;

  /// Primary action of the banner.
  ///
  /// Usually a [TextButton].
  ///
  /// When this is larger than the screen width, overflow occurs.
  final Widget? action;

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
    padding: const EdgeInsets.all(15),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(20),
      color: Theme.of(context).cardColor,
    ),
    child: Row(
      children: [
        Expanded(child: content),
        if (action != null)
          action!,
      ],
    ),
  );

}