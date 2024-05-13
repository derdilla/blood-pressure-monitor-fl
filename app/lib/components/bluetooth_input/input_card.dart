import 'package:flutter/material.dart';

/// Card to place a complex opened input on.
class InputCard extends StatelessWidget {
  /// Create a card to host a complex input.
  const InputCard({super.key,
    required this.child,
    this.title,
    this.onClosed
  });

  /// Main content of the card
  final Widget child;

  /// Description of the card or the state of the card.
  final Widget? title;

  /// When provided a close icon at the top left corner is shown.
  final void Function()? onClosed;

  Widget _buildCloseIcon() => Align(
    alignment: Alignment.topRight,
    child: IconButton(
      icon: const Icon(Icons.close),
      onPressed: onClosed!,
    ),
  );

  Widget _buildTitle(BuildContext context) => Align(
    alignment: Alignment.topLeft,
    child: Padding(
      padding: const EdgeInsets.only(
        top: 8.0,
        left: 16.0,
      ),
      child: DefaultTextStyle(
        style: Theme.of(context).textTheme.titleLarge ?? const TextStyle(),
        child: title!,
      ),
    ),
  );

  Widget _buildBody() => Padding( // content
    padding: const EdgeInsets.only(
      top: 42,
      bottom: 20,
      left: 20,
      right: 20,
    ),
    child: Center(
      child: child,
    ),
  );

  @override
  Widget build(BuildContext context) => Card(
    color: Theme.of(context).cardColor,
    margin: const EdgeInsets.all(8),
    child: Stack(
      children: [
        _buildBody(),
        if (title != null)
          _buildTitle(context),
        if (onClosed != null)
          _buildCloseIcon(),
      ],
    ),
  );

}
