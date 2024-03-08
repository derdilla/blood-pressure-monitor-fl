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
class CustomBanner extends MaterialBanner {
  /// Create a banner that displays information and an action.
  CustomBanner({super.key, required super.content, this.action}) : super(
    actions: [const SizedBox.shrink()],
  );

  /// Primary action of the banner.
  ///
  /// Usually a [TextButton].
  ///
  /// When this is larger than the screen width, overflow occurs.
  final Widget? action;


  @override
  MaterialBanner withAnimation(Animation<double> newAnimation, {Key? fallbackKey})
    => CustomBanner(content: content, action: action, key: key ?? fallbackKey,);
  // TODO: animate

  @override
  State<CustomBanner> createState() => _CustomBannerState();
}

class _CustomBannerState extends State<CustomBanner> {
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
        Expanded(child: widget.content),
        if (widget.action != null)
          widget.action!,
      ],
    ),
  );
}
