// Converted Dart code from React Native TypeScript
// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../types/theme.dart';

class Background extends StatelessWidget {
  final Theme theme;

  const Background({Key? key, required this.theme}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.shortestSide >= 600;

    return SvgPicture.string(
      _svgData,
      allowDrawingOutsideViewBox: true,
      fit: BoxFit.cover,
      color: theme.centerChannelColor.withOpacity(0.06),
    );
  }

  static const String _svgData = '''
  <svg viewBox="0 0 414 896">
    <g>
      <path d="M476.396 575.017l.118-.395a1.278 1.278 0 00-.473-.869 1.454 1.454 0 00-1.529-.181 1.315 1.315 0 00-.724 1.287l.751.751.395.119.652-.652.81-.06z" fill="#000000" fill-opacity="0.08"/>
      <path d="M423.733 576.163l-.751-.75-.395-.119a1.682 1.682 0 00-.474.118l-.77.771-.099.375c.034.353.204.679.474.909a1.22 1.22 0 00.948.276 1.393 1.393 0 001.067-1.58z" fill="#000000" fill-opacity="0.08"/>
      <!-- Add more SVG paths as appropriate -->
    </g>
    ${isTablet ? '''
    <g>
      <path d="M-31.58 253.269l-.118.395a1.285 1.285 0 00.474.869 1.45 1.45 0 001.529.181 1.32 1.32 0 00.664-.771c.054-.167.074-.342.06-.516l-.752-.751-.395-.118-.652.652-.81.059z" fill="#000000" fill-opacity="0.08"/>
      <path d="M21.084 252.123l.75.751.395.118c.163-.016.323-.056.475-.118l.77-.77.099-.376a1.367 1.367 0 00-.474-.908 1.222 1.222 0 00-.948-.277 1.393 1.393 0 00-1.067 1.58z" fill="#000000" fill-opacity="0.08"/>
      <!-- Add more SVG paths as appropriate -->
    </g>''' : ''}
    <defs>
      <linearGradient id="paint0_linear_2472_110589" x1="159.724" y1="53.9386" x2="625.156" y2="514.648" gradientUnits="userSpaceOnUse">
        <stop stop-color="${theme.centerChannelBg}"/>
        <stop offset="1" stop-color="${theme.centerChannelBg}" stop-opacity="0"/>
      </linearGradient>
      <linearGradient id="paint1_linear_2472_110589" x1="285.092" y1="774.348" x2="-180.339" y2="313.638" gradientUnits="userSpaceOnUse">
        <stop stop-color="${theme.centerChannelBg}"/>
        <stop offset="1" stop-color="${theme.centerChannelBg}" stop-opacity="0"/>
      </linearGradient>
    </defs>
  </svg>
  ''';
}
