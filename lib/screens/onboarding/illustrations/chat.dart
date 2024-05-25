
// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mattermost_flutter/types/theme.dart'; // Assuming a custom Theme class is defined here

class ChatSvg extends StatelessWidget {
  final Theme theme;
  final BoxDecoration styles;

  ChatSvg({required this.theme, required this.styles});

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      'assets/images/chat.svg',
      width: 263,
      height: 212,
      fit: BoxFit.none,
      color: theme.centerChannelBg,
    );
  }
}
