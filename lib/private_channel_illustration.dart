
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mattermost_flutter/types.dart'; // Assuming types are correctly defined in this import

class PrivateChannelIllustration extends StatelessWidget {
  final Theme theme;

  const PrivateChannelIllustration({Key? key, required this.theme}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SvgPicture.string('''
      <svg width="152" height="149" viewBox="0 0 152 149">
        <!-- SVG content extracted and modified from the original TSX file -->
      </svg>
    ''', fit: BoxFit.scaleDown);
  }
}
