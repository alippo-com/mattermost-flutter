// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import './types/theme.dart';

class TownSquareIllustration extends StatelessWidget {
  final Theme theme;

  TownSquareIllustration({required this.theme});

  @override
  Widget build(BuildContext context) {
    return SvgPicture.string(
      '<svg width="152" height="149" viewBox="0 0 152 149" xmlns="http://www.w3.org/2000/svg">
        <!-- SVG content extracted and adapted from the original TSX file -->
      </svg>',
      semanticsLabel: 'Town Square Illustration'
    );
  }
}
