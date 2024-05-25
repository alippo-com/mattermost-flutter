// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mattermost_flutter/types/theme.dart'; // Assuming a custom Theme class is defined here

class IntegrationsSvg extends StatelessWidget {
  final Theme theme;
  final BoxDecoration styles;

  IntegrationsSvg({required this.theme, required this.styles});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: styles,
      child: SvgPicture.asset(
        'assets/images/integrations.svg',
        width: 246,
        height: 235,
        fit: BoxFit.none,
        color: theme.centerChannelBg,
      ),
    );
  }
}
