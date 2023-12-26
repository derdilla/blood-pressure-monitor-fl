import 'package:flutter/material.dart';

/// Base for fullscreen dialoges that allow value input.
class FullscreenDialoge extends StatelessWidget {
  /// Create a dialoge that has a icon- and a textbutton in the app bar.
  const FullscreenDialoge({super.key,
    this.body,
    required this.actionButtonText,
    this.onActionButtonPressed,
    this.bottomAppBar = false,
    this.closeIcon = Icons.close,
  });

  /// The primary content of the dialoge.
  final Widget? body;

  /// Icon of button leading in the app bar.
  ///
  /// When pressing on the icon button the context gets popped.
  ///
  /// Setting this icon to null will hide the button entirely.
  final IconData? closeIcon;

  /// Primary content of the text button at the right end of the app bar.
  ///
  /// Usually `localizations.btnSave`
  ///
  /// Setting the text to null will remove the button.
  final String? actionButtonText;

  /// Action on press of the button.
  ///
  /// Setting this to null will disable the button. To hide it refer to
  /// [actionButtonText].
  final void Function()? onActionButtonPressed;

  /// Whether to move the app bar to the bottom of the screen.
  ///
  /// Setting this to false will let the app bar stay at the top.
  final bool bottomAppBar;

  @override
  Widget build(BuildContext context) => Scaffold(
    body: body,
    appBar: bottomAppBar ? null : _buildAppBar(context),
    bottomNavigationBar: bottomAppBar ? BottomAppBar(
      color: Colors.transparent,
      shadowColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      child: _buildAppBar(context)
    ) : null,
  );

  PreferredSizeWidget _buildAppBar(BuildContext context) => AppBar(
    forceMaterialTransparency: true,
    leading: (closeIcon == null) ? null : IconButton(
      onPressed: () => Navigator.of(context).pop(null),
      icon: Icon(closeIcon),
    ),
    actions: [
      if (actionButtonText != null)
        TextButton(
          onPressed: onActionButtonPressed,
          child:  Text(actionButtonText!)
        )
    ]
  );

}