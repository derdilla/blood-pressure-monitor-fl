import 'dart:math';

import 'package:blood_pressure_app/components/fullscreen_dialoge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// Generic multilayered fullscreen dialoge for nesting string selections.
///
/// Unlike other dialoges this doesn't drop the scope by default and needs users
/// to implement it in the [onSaved] attribute.
// TODO: consider making this a abstract class and require implementation.
class TreeSelectionDialoge extends StatefulWidget {
  /// Create a multilayered string selection dialoge.
  const TreeSelectionDialoge({super.key,
    required this.buildTitle,
    required this.buildOptions,
    required this.bottomAppBars,
    this.validator,
    required this.onSaved,
  });

  /// Builder for currently visible options.
  ///
  /// Should return currently visible options or close the dialoge. The
  /// `madeSelections` parameter contains all selections the user already made
  /// in the order in which they were made.
  ///
  /// **Tip:** use `madeSelections.length` to obtain the current depth.
  ///
  /// Guaranteed to be called after every selection.
  final List<String> Function(List<String> madeSelections) buildOptions;

  /// Builds a title that tells users what to this selection is about.
  ///
  /// Behaves like [buildOptions].
  final String Function(List<String> madeSelections) buildTitle;

  /// Validates selections and returns errors.
  ///
  /// Invoked manually by the user.
  ///
  /// When this function returns a string saving is not possible and the string
  /// will be shown to the user. When this function returns null or is null the
  /// the [onSaved] callback will be called.
  final String? Function(List<String> madeSelections)? validator;

  /// Stores form state after [validator] pass.
  ///
  /// This function is responsible to prepare the form response for further use
  /// and to pop the scope.
  final void Function(List<String> madeSelections) onSaved;

  // TODO: check mutability of passed arguments

  /// Whether to move the app bar for saving and loading to the bottom of the
  /// screen.
  final bool bottomAppBars;

  @override
  State<TreeSelectionDialoge> createState() => _TreeSelectionDialogeState();
}

class _TreeSelectionDialogeState extends State<TreeSelectionDialoge>
    with TickerProviderStateMixin {
  /// Selections the user already made.
  final _selections = <String>[];

  /// Error to display.
  String? _error;

  /// Visible elements from last build.
  List<String>? _lastItems;
  
  /// Index of the last selected item
  int? _lastSelectedIdx;

  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
  }


  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final items = widget.buildOptions(_selections);
    _controller.reset();
    _controller.forward();
    return PopScope(
      canPop: _selections.isEmpty,
      onPopInvoked: (didPop) {
        if (!didPop) {
          setState(_selections.removeLast);
        }
      },
      child: FullscreenDialoge(
        onActionButtonPressed: () {
          setState(() {
            _error = widget.validator?.call(_selections);
          });
          if (_error != null) {
            return;
          }
          widget.onSaved(_selections);
        },
        actionButtonText: localizations.btnSave,
        bottomAppBar: widget.bottomAppBars,
        body: _buildOptions(items),
      ),
    );
  }
  
  Widget _buildOptions(List<String> items) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Expanded(
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: max(_lastItems?.length ?? 0, items.length) + 1,
          itemBuilder: (context, idx) => (idx == 0)
              ? ListTile(
                title: Text(widget.buildTitle(_selections)),
                titleTextStyle: Theme.of(context).textTheme.headlineSmall,
              )
              : UnconstrainedBox(
                clipBehavior: Clip.hardEdge,
                child: TweenAnimationBuilder(
                  key: UniqueKey(),
                  duration: Duration(milliseconds: 400 + 100 * idx), // interacts with LineChart duration property
                  tween: Tween<double>(begin: -0.25, end: 0.25),
                  curve: Curves.easeInOutCirc,
                  builder: (BuildContext context, double value, child) {
                    Material.of(context).markNeedsPaint();
                    return FractionalTranslation(
                      translation: Offset(value, 0.0),
                      child: Container(
                        width: MediaQuery.of(context).size.width * 2,
                        padding: const EdgeInsets.only(top: 10),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // New tiles replace old ones:
                            SizedBox(
                              width: MediaQuery.of(context).size.width,
                              child: (idx-1 < items.length)
                                ? ListTile(
                                  title: Text(items[idx-1]),
                                  onTap: () => setState(() {
                                    _lastItems = items;
                                    _selections.add(items[idx-1]);
                                  }),
                                  tileColor: Theme.of(context).cardColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                )
                                : null,
                            ),
                            // Old tiles get moved away:
                            if (value < 0.25 // remove after animation finished
                                && _lastItems != null
                                && _lastItems!.length > idx-1) // element available
                              SizedBox(
                                width: MediaQuery.of(context).size.width - 10,
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 10),
                                  child: ListTile(
                                    title: Text(_lastItems![idx-1]),
                                    tileColor: Theme.of(context).cardColor,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
        ),
      ),
      if (_error != null)
        ListTile(
          title: Text(_error!,),
          textColor: Theme.of(context).colorScheme.error,
          titleTextStyle: Theme.of(context).textTheme.labelLarge,
        ),

      // TODO: don't rebuild when validation error
      // TODO: backwards navigation
    ],
  );
}
