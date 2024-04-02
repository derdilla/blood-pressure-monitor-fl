import 'package:blood_pressure_app/components/dialoges/fullscreen_dialoge.dart';
import 'package:blood_pressure_app/components/settings/color_picker_list_tile.dart';
import 'package:blood_pressure_app/model/storage/settings_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:health_data_store/health_data_store.dart';

/// Dialoge to enter values for a [Medicine].
class AddMedicationDialoge extends StatefulWidget {
  /// Create a dialoge to enter values for a [Medicine].
  const AddMedicationDialoge({super.key,
    required this.settings,
  });

  /// Settings that determine general behavior.
  final Settings settings;

  @override
  State<AddMedicationDialoge> createState() => _AddMedicationDialogeState();
}

class _AddMedicationDialogeState extends State<AddMedicationDialoge> {
  final formKey = GlobalKey<FormState>();
  final nameFocusNode = FocusNode();

  Color _color = Colors.transparent;
  String? _designation;
  double? _defaultDosis;


  @override
  void initState() {
    super.initState();
    nameFocusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return FullscreenDialoge(
      actionButtonText: localizations.btnSave,
      onActionButtonPressed: () {
        formKey.currentState?.save();
        Navigator.pop(context, Medicine(
          designation: _designation ?? '',
          color: _color.value,
          dosis: _defaultDosis == null ? null : Weight.mg(_defaultDosis!),
        ),);
      },
      bottomAppBar: widget.settings.bottomAppBars,
      body: Form(
        key: formKey,
        child: ListView(
          children: [
            TextFormField(
              focusNode: nameFocusNode,
              decoration: _getInputDecoration(context, localizations.name),
              onSaved: (value) => _designation = value,
            ),
            const SizedBox(height: 8,),
            ColorSelectionListTile(
              title: Text(localizations.color),
              onMainColorChanged: (value) => setState(() {
                _color = value;
              }),
              initialColor: _color,
              shape: _getBorder(),
            ),
            const SizedBox(height: 8,),
            TextFormField(
              keyboardType: TextInputType.number,
              decoration: _getInputDecoration(context, localizations.defaultDosis),
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'([0-9]+(\.([0-9]*))?)')),],
              onSaved: (value) => _defaultDosis = double.tryParse(value ?? '')
                  ?? int.tryParse(value ?? '')?.toDouble(),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _getInputDecoration(BuildContext context, String? labelText) => InputDecoration(
      hintText: labelText,
      labelText: labelText,
      errorMaxLines: 5,
      border: _getBorder(),
      enabledBorder: _getBorder(),
    );

  OutlineInputBorder _getBorder() => OutlineInputBorder(
      borderSide: BorderSide(
        width: 3,
        color: Theme.of(context).primaryColor,
      ),
      borderRadius: BorderRadius.circular(20),
  );
}

/// Shows a full screen dialoge to input a medicine.
///
/// The created medicine gets an index that was never in settings.
Future<Medicine?> showAddMedicineDialoge(BuildContext context, Settings settings) =>
  showDialog<Medicine?>(context: context, builder: (context) => Dialog.fullscreen(
    child: AddMedicationDialoge(settings: settings),
  ),);
