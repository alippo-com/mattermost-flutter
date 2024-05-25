import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class JoinPublicChannelIllustration extends StatelessWidget {
  final ThemeData theme;

  JoinPublicChannelIllustration({required this.theme});

  @override
  Widget build(BuildContext context) {
    return SvgPicture.string(
      '''<svg width="200" height="201" fill="none" viewBox="0 0 210 170">
        <!-- SVG content extracted from original file -->
      </svg>''',
      fit: BoxFit.contain,
    );
  }
}
