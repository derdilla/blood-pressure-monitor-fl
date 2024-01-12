import 'package:blood_pressure_app/components/dialoges/add_medication_dialoge.dart';
import 'package:blood_pressure_app/model/storage/settings_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

/// Screen to view and edit medications saved in [Settings].
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
                itemCount: medications.length + 1,
                itemBuilder: (context, i) {
                  if (i == medications.length) { // last row
                    return ListTile(
                      leading: const Icon(Icons.add),
                      title: Text(localizations.addMedication),
                      onTap: () async {
                        final medicine = await showAddMedicineDialoge(context, settings);
                        if (medicine != null) settings.addMedication(medicine);
                      },
                    );
                  }
                  return ListTile(
                    leading: medications[i].color == Colors.transparent ? null : Container(
                      width: 40.0,
                      height: 40.0,
                      decoration: BoxDecoration(
                        color: medications[i].color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    title: Text(medications[i].designation),
                    subtitle: Text('${localizations.defaultDosis}: '
                        '${medications[i].defaultDosis}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        settings.removeMedicationAt(i);
                      },
                    ),
                  );
                },
            );
          },),
      ),
    );
  }

}