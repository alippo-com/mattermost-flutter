import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:mattermost_flutter/types/types.dart'; // Adjust this import based on actual types location

class Thumbnail extends StatelessWidget {
  final VoidCallback onError;
  final Animation<double>? opacity;
  final ImageProvider? source;
  final BoxDecoration? style;
  final Color? tintColor;

  const Thumbnail({
    required this.onError,
    this.opacity,
    this.source,
    this.style,
    this.tintColor,
  });

  @override
  Widget build(BuildContext context) {
    if (source != null) {
      return Image(
        image: source!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => onError(),
        decoration: style,
      );
    }

    return Opacity(
      opacity: opacity?.value ?? 1.0,
      child: Image.asset(
        'assets/images/thumb.png',
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => onError(),
        color: tintColor,
      ),
    );
  }
}
