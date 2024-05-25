
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mattermost_flutter/types/theme.dart';

class CallsSvg extends StatelessWidget {
  final Theme theme;
  final TextStyle style;

  CallsSvg({required this.theme, required this.style});

  @override
  Widget build(BuildContext context) {
    return SvgPicture.string(
      '''
      <svg width="284" height="191" viewBox="0 0 284 191" fill="none" xmlns="http://www.w3.org/2000/svg" style="${style}">
        <!-- SVG content here -->
      </svg>
      ''',
      width: 284,
      height: 191,
    );
  }
}
