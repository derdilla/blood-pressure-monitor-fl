import 'package:blood_pressure_app/model/settings_store.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class IntervalPicker extends StatelessWidget {
  const IntervalPicker({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<Settings>(builder: (context, settings, child) {
      return Row(children: [
        Expanded(
          flex: 30,
          child: MaterialButton(
            onPressed: () {
              settings.moveDisplayDataByStep(-1);
            },
            child: const Icon(
              Icons.chevron_left,
              size: 48,
            ),
          ),
        ),
        Expanded(
          flex: 40,
          child: DropdownButton<int>(
            value: settings.graphStepSize,
            isExpanded: true,
            onChanged: (int? value) {
              if (value != null) {
                settings.changeStepSize(value);
              }
            },
            items: TimeStep.options.map<DropdownMenuItem<int>>((v) {
              return DropdownMenuItem(value: v, child: Text(TimeStep.getName(v)));
            }).toList(),
          ),
        ),
        Expanded(
          flex: 30,
          child: MaterialButton(
            onPressed: () {
              settings.moveDisplayDataByStep(1);
            },
            child: const Icon(
              Icons.chevron_right,
              size: 48,
            ),
          ),
        ),
      ]);
    });
  }
}
