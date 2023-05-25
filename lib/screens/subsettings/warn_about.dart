
import 'package:blood_pressure_app/model/blood_pressure.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutWarnValuesScreen extends StatelessWidget {
  const AboutWarnValuesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Warn values'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(90.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('The warn values are a pure suggestions and no medical advice.'),
              const SizedBox(height: 5,),
              InkWell(
                onTap: () async {
                  final url = Uri.parse(BloodPressureWarnValues.source);
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url, mode: LaunchMode.externalApplication);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Can\'t open URL:\n${BloodPressureWarnValues.source}')));
                  }
                },
                child: const SizedBox(
                  height: 48,
                  child: Center(
                    child: Text(
                      "The default age dependent values come from this source.",
                      style: TextStyle(color: Colors.blue),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 5,),
              const Text('Feel free to change the values to suit your needs and follow the recommendations of your doctor.'),
            ],
          ),
        ),
      ),
    );
  }

}