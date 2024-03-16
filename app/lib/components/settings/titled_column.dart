import 'package:flutter/material.dart';

/// A [Column] with a leading title.
class TitledColumn extends StatelessWidget {
  /// Create a [Column] with a leading title.
  ///
  /// Useful for labeling lists and singular widgets.
  ///
  /// Internally this is a column with a title list tile before the children
  const TitledColumn({super.key,
    required this.title,
    required this.children,
  });

  /// Title to display above the [children].
  ///
  /// Usually a [Text] widget.
  final Widget title;

  /// Items that get listed.
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final List<Widget> items = [
      ListTile(
        title: DefaultTextStyle(
          style: Theme.of(context).textTheme.titleLarge!,
          child: title,
        ),
      ),
    ];
    items.addAll(children);
    return Column(
      children: items,
    );
  }
}
