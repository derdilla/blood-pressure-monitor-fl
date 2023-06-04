import 'package:blood_pressure_app/model/settings_store.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:blood_pressure_app/screens/subsettings/time_formats_explainer.dart';


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
              padding: const EdgeInsets.all(90.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('A formatter String consists of a mixture of predefined ICU/Skeleton Strings and any other text you want to include.'),
                  InkWell(
                    onTap: () async {
                      Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const TimeFormattingHelp())
                      );
                    },
                    child: const SizedBox(
                      height: 48,
                      child: Center(
                        child: Text(
                          'For a full list of valid formats please look here.',
                          style: TextStyle(color: Colors.blue),
                        ),
                      ),
                    ),
                  ),
                  const Text('Please note that having longer/shorter format Strings wont magically change the width of the table columns, so it might come to awkward line breaks.'),
                  const SizedBox(height: 7,),
                  const Text('default: "yy-MM-dd H:mm"'),

                  const SizedBox(height: 10,),
                  Consumer<Settings>(
                      builder: (context, settings, child) {
                        _newVal = settings.dateFormatString;
                        return TextFormField(
                          initialValue: _newVal,
                          decoration: const InputDecoration(
                              hintText: 'format string'
                          ),
                          validator: (String? value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a value';
                            } else {
                              _newVal = value;
                            }
                            return null;
                          },
                        );
                      }
                  ),
                  const SizedBox(height: 25,),
                  Row(
                    children: [
                      ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).unselectedWidgetColor
                          ),
                          child: const Text('CANCEL')),
                      const Spacer(),
                      ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              Provider.of<Settings>(context, listen: false).dateFormatString = _newVal;
                              Navigator.of(context).pop();
                            }
                          },
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).primaryColor
                          ),
                          child: const Text('SAVE'))
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