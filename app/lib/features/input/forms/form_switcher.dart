import 'package:flutter/material.dart';

class FormSwitcher extends StatefulWidget {
  const FormSwitcher({super.key, required this.subforms});

  final List<(Widget, Widget)> subforms;

  @override
  State<FormSwitcher> createState() => _FormSwitcherState();
}

class _FormSwitcherState extends State<FormSwitcher>
    with TickerProviderStateMixin {
  late final TabController controller;


  @override
  void initState() {
    super.initState();

    controller = TabController(length: widget.subforms.length, vsync: this);
  }


  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    assert(widget.subforms.isNotEmpty);
    if (widget.subforms.length == 1) {
      return widget.subforms[0].$2;
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TabBar.secondary(
          controller: controller,
          tabs: [
            for (final f in widget.subforms)
              Padding(
                padding: EdgeInsets.all(8.0),
                child: f.$1,
              ),
          ],
        ),
        Expanded( // TODO: dynamically get size of child and animate height on switch
          child: TabBarView(
            controller: controller,
            children: [
              for (final f in widget.subforms)
                Align(alignment: Alignment.topCenter, child: f.$2),
            ],
          ),
        ),
      ],
    );
  }
}

