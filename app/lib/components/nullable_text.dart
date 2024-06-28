import 'package:flutter/material.dart';

/// A text widget that shows a placeholder('-') when no text is present.
class NullableText extends StatelessWidget {
  /// Show text or a placeholder
  const NullableText(this.text, {super.key});

  /// Text to display.
  final String? text;

  @override
  Widget build(BuildContext context) => Text(text ?? '-');
}
