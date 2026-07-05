// lib/features/suggestion/widgets/streaming_text_widget.dart
import 'package:flutter/material.dart';

class StreamingTextWidget extends StatelessWidget {
  const StreamingTextWidget({super.key, required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.headlineMedium,
      textAlign: TextAlign.center,
    );
  }
}
