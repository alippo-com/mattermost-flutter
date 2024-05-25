
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class PublicChannelIllustration extends StatelessWidget {
  final ThemeData theme;

  const PublicChannelIllustration({Key? key, required this.theme}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SvgPicture.string(
      '''
      <svg width="152" height="149" viewBox="0 0 152 149">
        <!-- SVG content omitted for brevity, include all SVG data here -->
      </svg>
      ''',
      fit: BoxFit.contain,
    );
  }
}
