
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mattermost_flutter/types/theme.dart';

class ReviewAppIllustration extends StatelessWidget {
  final Theme theme;

  ReviewAppIllustration({required this.theme});

  @override
  Widget build(BuildContext context) {
    return SvgPicture.string(
      '''
      <svg width="222" height="205" viewBox="0 0 222 205" fill="none">
        <!-- SVG content copied from the TSX file -->
      </svg>
      ''',
      fit: BoxFit.contain,
    );
  }
}
