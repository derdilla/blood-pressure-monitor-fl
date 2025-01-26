import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:inline_tab_view/inline_tab_view.dart';

/// A resizing view that associates a tab-bar and child widgets.
class FormSwitcher extends StatefulWidget {
  /// Create a resizing view that associates a tab-bar and child widgets-
  const FormSwitcher({super.key,
    required this.subForms,
    this.controller,
  });

  /// List of (tab title, tab content) pairs.
  final List<(Widget, Widget)> subForms;
  
  /// Controller to use to control the switcher from code. 
  final FormSwitcherController? controller;

  @override
  State<FormSwitcher> createState() => _FormSwitcherState();
}

class _FormSwitcherState extends State<FormSwitcher>
    with TickerProviderStateMixin {
  late final TabController controller;

  @override
  void initState() {
    super.initState();
    controller = TabController(length: widget.subForms.length, vsync: this);
    widget.controller?._initialize(controller);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    assert(widget.subForms.isNotEmpty);
    if (widget.subForms.length == 1) {
      return widget.subForms[0].$2;
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TabBar.secondary(
          controller: controller,
          tabs: [
            for (final f in widget.subForms)
              Padding(
                padding: EdgeInsets.all(8.0),
                child: f.$1,
              ),
          ],
        ),
        InlineTabView(
          controller: controller,
          children: [
            for (final f in widget.subForms)
              Padding(
                padding: EdgeInsets.only(top: 8.0),
                child: f.$2,
              ),
          ],
        ),
      ],
    );
  }
}

/// Allows controlling a [FormSwitcher] from code.
class FormSwitcherController {
  final Queue<Function> _pendingActions = Queue();

  TabController? _controller;

  /// Add a reference to a TabController to control.
  /// 
  /// This does not mean this object is responsible for destroying it.
  void _initialize(TabController controller) {
    assert(_controller == null, 'FormSwitcherController was initialized twice');
    _controller = controller;
    while (_pendingActions.isNotEmpty) {
      _pendingActions.removeFirst().call();
    }
  }

  /// Animates to viewing the page at the specified index as soon as possible.
  void animateTo(int index) {
    if (_controller == null) {
      _pendingActions.add(() => animateTo(index));
    } else {
      _controller!.animateTo(index);
    }
  }
}
