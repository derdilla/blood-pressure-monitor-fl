import 'package:blood_pressure_app/components/color_picker.dart';
import 'package:blood_pressure_app/components/dialoges/oldinput_dialoge.dart';
import 'package:blood_pressure_app/model/horizontal_graph_line.dart';
import 'package:blood_pressure_app/model/storage/settings_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

class GraphMarkingsScreen extends StatelessWidget {
  const GraphMarkingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
     // IMPORTANT: When adding more option, like vertical lines, add navigation bar
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.customGraphMarkings),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Center(child: Consumer<Settings>(
        builder: (context, settings, child) {
          final lines = settings.horizontalGraphLines.toList();
          return ListView.builder(
            itemCount: lines.length + 2, // support first and last row
            itemBuilder: (context, i) {
              if(i == 0) { // first row
                return Container(
                  padding: const EdgeInsets.all(10),
                  child: DefaultTextStyle.merge(
                    child: Text(localizations.horizontalLines),
                    style: Theme.of(context).textTheme.headlineLarge
                  ),
                );
              }
              if (i > lines.length) { // last row
                return ListTile(
                  leading: const Icon(Icons.add),
                  title: Text(localizations.addLine),
                  onTap: () async {
                    final color = await showColorPickerDialog(context);
                    if (!context.mounted) return;
                    final height = await showDialog<int>(context: context,
                        builder: (context) => NumberInputDialoge(
                            hintText: localizations.linePositionY,
                            onParsableSubmit: (value) {
                              Navigator.of(context).pop(value);
                            }
                        )
                    );

                    if (color == null || height == null) return;
                    lines.add(HorizontalGraphLine(color, height));
                    settings.horizontalGraphLines = lines;
                  },
                );
              }
              return ListTile(
                leading: Container(
                  width: 40.0,
                  height: 40.0,
                  decoration: BoxDecoration(
                    color: lines[i-1].color,
                    shape: BoxShape.circle,
                  ),
                ),
                title: Text(lines[i-1].height.toString()),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    lines.removeAt(i-1);
                    settings.horizontalGraphLines = lines;
                  },
                ),
              );
            }
          );
        }),
      ),
    );
  }
}
