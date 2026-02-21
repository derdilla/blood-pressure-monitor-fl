import 'dart:async';

import 'package:blood_pressure_app/features/settings/time_formats_reference_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:url_launcher/url_launcher.dart';

/// Screen to show long markdown text.
class InformationScreen extends StatelessWidget {
  /// Create a screen to display long markdown text.
  const InformationScreen({super.key, required this.text});

  /// text in markdown format
  final String text;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      forceMaterialTransparency: true,
    ),
    body: Container(
      padding: const EdgeInsets.all(10),
      child: Markdown(
        selectable: true,
        onTapLink: getLinkTapHandler(context),
        data: text,
      ),
    ),
  );
}

/// Definition of a function that resolves lik presses
typedef LinkTapHandler = FutureOr<void> Function(String text, String? destination, String title)?;

/// Constructs a function that handles link presses to urls and some screens.
///
/// Currently supported
/// - `http://*`
/// - `https://*`
/// - `screen://TimeFormattingHelp`
LinkTapHandler getLinkTapHandler(BuildContext context) => (String text, String? destination, String title) async {
  if (destination == null) {
    return;
  }
  if (destination.startsWith('http://') || destination.startsWith('https://')) {
    final url = Uri.tryParse(destination);
    if (url != null && await canLaunchUrl(url)) {
      await launchUrl(url);
      return;
    }
  } else if (destination.startsWith('screen://')) {
    switch (destination.split('//')[1]) {
      case 'TimeFormattingHelp':
        Navigator.push(context, MaterialPageRoute<void>(builder:
            (context) => const TimeFormattingReferenceScreen())).ignore();
        return;
    }
  }
  assert(false, 'Markdown contains invalid URL');
};
