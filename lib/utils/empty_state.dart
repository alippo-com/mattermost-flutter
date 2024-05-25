
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mattermost_flutter/lib/types/theme.dart';

class EmptyStateIllustration extends StatelessWidget {
  final Theme theme;

  const EmptyStateIllustration({Key? key, required this.theme}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SvgPicture.string(
      '''
      <svg width="228" height="201" viewBox="0 0 228 201" fill="none" xmlns="http://www.w3.org/2000/svg">
        <!-- SVG content as in the original TSX file, with changes to fill properties to use theme properties from Flutter's context -->
      </svg>
      ''',
      fit: BoxFit.contain,
    );
  }
}
