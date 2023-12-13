import 'dart:async';

import 'package:blood_pressure_app/screens/subsettings/time_formats_explainer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';

class InformationScreen extends StatelessWidget {
  /// text in markdown format
  final String text;
  const InformationScreen({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).primaryColor,
        ),
        body: Container(
          padding: const EdgeInsets.all(10),
          child: Markdown(
            selectable: true,
            onTapLink: getLinkTapHandler(context),
            data: text
          ),
        )
    );
  }
}

typedef LinkTapHandler = FutureOr<void> Function(String, String?, String)?;

LinkTapHandler getLinkTapHandler(BuildContext context) => (String text, String? destination, String title) async {
  if (destination == null) {
    return;
  }
  if (destination.startsWith('http://') || destination.startsWith('https://')) {
    final url = Uri.tryParse(destination);
    if (url != null && await canLaunchUrl(url)) {
      launchUrl(url);
      return;
    }
  } else if (destination.startsWith('screen://')) {
    switch (destination.split('//')[1]) {
      case 'TimeFormattingHelp':
        Navigator.of(context).push(MaterialPageRoute(builder: (context) => const TimeFormattingHelp()));
        return;
    }
  }
  assert(false, 'Markdown contains invalid URL');
};