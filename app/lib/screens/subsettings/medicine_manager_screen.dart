import 'package:blood_pressure_app/components/dialoges/add_medication_dialoge.dart';
import 'package:blood_pressure_app/model/storage/settings_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:health_data_store/health_data_store.dart';
import 'package:provider/provider.dart';

/// Screen to view and edit medications saved in [Settings].
///
/// This screen allows adding and removing medication but not modifying them in
/// order to keep the code simple and maintainable.
class MedicineManagerScreen extends StatefulWidget {
  /// Create a screen to manage medications in settings.
  const MedicineManagerScreen({super.key});

  @override
  State<MedicineManagerScreen> createState() => _MedicineManagerScreenState();
}

class _MedicineManagerScreenState extends State<MedicineManagerScreen> {
  List<Medicine> medicines = [];

  @override
  void initState() {
    super.initState();
    RepositoryProvider.of<MedicineRepository>(context).getAll()
        .then((value) => setState(() => medicines.addAll(value)));
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        forceMaterialTransparency: true,
      ),
      body: Center(
        child: ListView.builder(
          itemCount: medicines.length + 1,
          itemBuilder: (context, i) {
            if (i == medicines.length) { // last row
              return ListTile(
                leading: const Icon(Icons.add),
                title: Text(localizations.addMedication),
                onTap: () async {
                  final medRepo = RepositoryProvider.of<MedicineRepository>(context);
                  final settings = Provider.of<Settings>(context, listen: false);
                  final medicine = await showAddMedicineDialoge(context, settings,);
                  if (medicine != null) {
                    setState(() {
                      medicines.add(medicine);
                      medRepo.add(medicine);
                    });
                  }
                },
              );
            }
            return ListTile(
              leading: medicines[i].color == Colors.transparent.value
                  || medicines[i].color == null
                ? null
                : Container(
                  width: 40.0,
                  height: 40.0,
                  decoration: BoxDecoration(
                    color: Color(medicines[i].color!),
                    shape: BoxShape.circle,
                  ),
                ),
              title: Text(medicines[i].designation),
              // TODO: make localization function
              subtitle: medicines[i].dosis == null ? null
                  : Text('${localizations.defaultDosis}: '
                         '${medicines[i].dosis!.mg} mg'),
              trailing: IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () async {
                  await RepositoryProvider.of<MedicineRepository>(context)
                    .remove(medicines[i]);
                  setState(() async {
                    medicines.removeAt(i);
                    // FIXME: somehow no feedback
                  });
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
