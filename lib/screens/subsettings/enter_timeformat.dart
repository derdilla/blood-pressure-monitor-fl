import 'package:blood_pressure_app/model/settings_store.dart';
import 'package:blood_pressure_app/model/storage/settings_store.dart';
import 'package:blood_pressure_app/screens/subsettings/time_formats_explainer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

class EnterTimeFormatScreen extends StatefulWidget {
  const EnterTimeFormatScreen({super.key});

  @override
  State<EnterTimeFormatScreen> createState() => _EnterTimeFormatScreenState();
}

class _EnterTimeFormatScreenState extends State<EnterTimeFormatScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final _firstNode = FocusNode();
  late String _newVal;

  @override
  Widget build(BuildContext context) {
    _firstNode.requestFocus();
    return Scaffold(
      body: Center(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.all(60.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(AppLocalizations.of(context)!.enterTimeFormatTxt1),
                  InkWell(
                    onTap: () async {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  const TimeFormattingHelp()));
                    },
                    child: SizedBox(
                      height: 65,
                      child: Center(
                        child: Text(
                          AppLocalizations.of(context)!.enterTimeFormatTxt2,
                          style: const TextStyle(color: Colors.blue),
                        ),
                      ),
                    ),
                  ),
                  Text(AppLocalizations.of(context)!.enterTimeFormatTxt3),
                  const SizedBox(
                    height: 7,
                  ),
                  Text(AppLocalizations.of(context)!.enterTimeFormatTxt4),
                  const SizedBox(
                    height: 10,
                  ),
                  Consumer<Settings>(builder: (context, settings, child) {
                    _newVal = settings.dateFormatString;
                    return TextFormField(
                      initialValue: _newVal,
                      decoration: InputDecoration(
                          hintText: AppLocalizations.of(context)!
                              .enterTimeFormatString),
                      validator: (String? value) {
                        if (value == null || value.isEmpty) {
                          return AppLocalizations.of(context)!.errNoValue;
                        } else {
                          _newVal = value;
                        }
                        return null;
                      },
                    );
                  }),
                  const SizedBox(
                    height: 25,
                  ),
                  Row(
                    children: [
                      TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text(AppLocalizations.of(context)!.btnCancel)),
                      const Spacer(),
                      FilledButton.icon(
                          key: const Key('btnSave'),
                          icon: const Icon(Icons.save),
                          label: Text(AppLocalizations.of(context)!.btnSave),
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              Provider.of<Settings>(context, listen: false)
                                  .dateFormatString = _newVal;
                              Navigator.of(context).pop();
                            }
                          },
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
