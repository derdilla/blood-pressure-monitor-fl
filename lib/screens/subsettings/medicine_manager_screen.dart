import 'package:blood_pressure_app/model/storage/settings_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

class MedicineManagerScreen extends StatelessWidget {
  const MedicineManagerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        forceMaterialTransparency: true,
      ),
      body: Center(child: Consumer<Settings>(
          builder: (context, settings, child) {
            final medications = settings.medications;
            return ListView.builder(
                itemCount: medications.length + 2,
                itemBuilder: (context, i) {
                  if(i == 0) { // first row
                    return Container(
                      padding: const EdgeInsets.all(10),
                      child: DefaultTextStyle.merge(
                        child: Text(localizations.medications),
                        style: Theme.of(context).textTheme.headlineLarge
                      ),
                    );
                  }
                  if (i > medications.length) { // last row
                    return ListTile(
                      leading: const Icon(Icons.add),
                      title: Text(localizations.addMedication),
                      onTap: () async {
                        // TODO
                      },
                    );
                  }
                  return ListTile(
                    leading: Container(
                      width: 40.0,
                      height: 40.0,
                      decoration: BoxDecoration(
                        color: medications[i-1].color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    title: Text(medications[i-1].designation),
                    subtitle: Text(medications[i-1].defaultDosis.toString()),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        settings.removeMedicationAt(i - 1);
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