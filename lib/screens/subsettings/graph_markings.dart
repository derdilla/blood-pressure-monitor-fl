import 'package:blood_pressure_app/components/input_dialoge.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../model/settings_store.dart';

class GraphMarkingsScreen extends StatelessWidget {
  const GraphMarkingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Center(child: Consumer<Settings>(
        builder: (context, settings, child) {
          final lines = settings.horizontalGraphLines.toList();
          return Container(
            padding: const EdgeInsets.all(20.0),
            child: ListView.builder(
              itemCount: lines.length+1,
              itemBuilder: (context, i) {
                if(i == 0) {
                  return Row(
                  children: [
                    Text('Horizontal Lines'), // TODO localize, implement
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => NumberInputDialoge(
                              hintText: 'hintText',
                              onParsableSubmit: (value) {
                                lines.add(value);
                                Navigator.of(context).pop();
                              }
                          ),
                        );
                      },
                    )
                  ],
                );
                }
                return Row(
                  children: [
                    Text(lines[i-1].toString()),
                    Spacer(),
                    Icon(Icons.delete)
                  ],
                );
              }
            )
          );
        }),
      ),
    );
  }
}
