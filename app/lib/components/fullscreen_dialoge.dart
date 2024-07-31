import 'package:flutter/material.dart';

/// Base for fullscreen dialoges that allow value input.
class FullscreenDialoge extends StatelessWidget {
  /// Create a dialoge that has a icon- and a textbutton in the app bar.
  const FullscreenDialoge({super.key,
    this.body,
    required this.actionButtonText,
    this.onActionButtonPressed,
    required this.bottomAppBar,
    this.closeIcon = Icons.close,
    this.actions = const <Widget>[],
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
  /// Setting the text to null will hide the button entirely.
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

  /// Secondary actions to display on the app bar.
  ///
  /// Positioned somewhere between close and primary action button.
  ///
  /// Recommended to be used with [CheckboxMenuButton].
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) => Dialog.fullscreen(
    child: Scaffold(
      body: _buildBody(),
      appBar: bottomAppBar ? null : _buildAppBar(context),
      bottomNavigationBar: bottomAppBar ? BottomAppBar(
        color: Colors.transparent,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        child: _buildAppBar(context),
      ) : null,
    ),
  );

  PreferredSizeWidget _buildAppBar(BuildContext context) => AppBar(
    forceMaterialTransparency: true,
    leading: (closeIcon == null) ? null : IconButton(
      onPressed: () => Navigator.pop(context, null),
      icon: Icon(closeIcon),
    ),
    title: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: actions,
    ),
    actions: [
      if (actionButtonText != null)
        TextButton(
          onPressed: onActionButtonPressed,
          child:  Text(actionButtonText!),
        ),
    ],
  );

  Widget? _buildBody() {
    if (body == null) return null;
    if (!bottomAppBar) return body;
    return Padding(
      padding: const EdgeInsets.only(top: 4.0),
      child: body,
    );
  }

}
