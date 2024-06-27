import 'package:blood_pressure_app/components/consistent_future_builder.dart';
import 'package:blood_pressure_app/components/dialoges/add_medication_dialoge.dart';
import 'package:blood_pressure_app/components/dialoges/confirm_deletion_dialoge.dart';
import 'package:blood_pressure_app/model/storage/settings_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:health_data_store/health_data_store.dart';

/// Screen to view and edit medications saved in [Settings].
///
/// This screen allows adding and removing medication but not modifying them in
/// order to keep the code simple and maintainable.
class MedicineManagerScreen extends StatelessWidget {
  /// Create a screen to manage medications in settings.
  const MedicineManagerScreen({super.key});

  Widget _buildMedicine(BuildContext context, Medicine med) => ListTile(
    leading: med.color == Colors.transparent.value
        || med.color == null
        ? null
        : Container(
      width: 40.0,
      height: 40.0,
      decoration: BoxDecoration(
        color: Color(med.color!),
        shape: BoxShape.circle,
      ),
    ),
    title: Text(med.designation),
    subtitle: med.dosis == null ? null
        : Text('${AppLocalizations.of(context)!.defaultDosis}: '
        '${med.dosis!.mg} mg'),
    trailing: IconButton(
      icon: const Icon(Icons.delete),
      onPressed: () async {
        if (await showConfirmDeletionDialoge(context)) {
          await RepositoryProvider.of<MedicineRepository>(context).remove(med);
        }
      },
    ),
  );

  Widget _buildAddMed(BuildContext context) => ListTile(
    leading: const Icon(Icons.add),
    title: Text(AppLocalizations.of(context)!.addMedication),
    onTap: () async {
      final medRepo = RepositoryProvider.of<MedicineRepository>(context);
      final medicine = await showAddMedicineDialoge(context);
      if (medicine != null) {
        await medRepo.add(medicine);
      }
    },
  );

 @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        forceMaterialTransparency: true,
      ),
      body: Center(
        child: StreamBuilder(
          stream: RepositoryProvider.of<MedicineRepository>(context).subscribe(),
          builder: (context, _) => ConsistentFutureBuilder(
            future: RepositoryProvider.of<MedicineRepository>(context).getAll(),
            onData: (context, medicines) => ListView.builder(
              itemCount: medicines.length + 1,
              itemBuilder: (context, i) {
                if (i == medicines.length) { // last row
                  return _buildAddMed(context);
                }
                return _buildMedicine(context, medicines[i]);
              },
            ),
          ),
        ),
      ),
    );
  }
}
