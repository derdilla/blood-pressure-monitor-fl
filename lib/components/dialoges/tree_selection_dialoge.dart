
import 'package:blood_pressure_app/components/dialoges/fullscreen_dialoge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// Generic multilayered fullscreen dialoge for nesting string selections.
class TreeSelectionDialoge extends StatefulWidget {
  /// Create a multilayered string selection dialoge.
  const TreeSelectionDialoge({super.key,
    required this.buildTitle,
    required this.buildOptions,
    required this.bottomAppBars,
    this.validator,
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
  /// When this function returns a string saving is not possible and the string
  /// will be shown to the user. When this function returns null or is null the
  /// selections will be returned popped to the underlying scope.
  final String? Function(List<String> madeSelections)? validator;

  /// Whether to move the app bar for saving and loading to the bottom of the
  /// screen.
  final bool bottomAppBars;

  @override
  State<TreeSelectionDialoge> createState() => _TreeSelectionDialogeState();
}

class _TreeSelectionDialogeState extends State<TreeSelectionDialoge> {
  /// Selections the user already made.
  final _selections = <String>[];

  String? _error;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final items = widget.buildOptions(_selections);
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
          final selections = _selections.toList();
          _selections.clear();
          Navigator.pop(context, selections);
        },
        actionButtonText: localizations.btnSave,
        bottomAppBar: widget.bottomAppBars,
        body: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: items.length + 1,
                itemBuilder: (context, idx) => (idx == 0)
                    ? ListTile(
                      title: Text(widget.buildTitle(_selections)),
                      titleTextStyle: Theme.of(context).textTheme.headlineSmall,
                    )
                    : Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: ListTile(
                          title: Text(items[idx-1]),
                          onTap: () => setState(() {
                            _selections.add(items[idx-1]);
                          }),
                          tileColor: Theme.of(context).cardColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
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
          ],
        ),
      ),
    );
  }
}
