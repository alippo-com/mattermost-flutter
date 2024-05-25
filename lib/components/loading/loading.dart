// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/material.dart';
import 'package:mattermost_flutter/types/theme.dart';
import 'package:mattermost_flutter/context/theme.dart';

class Loading extends StatelessWidget {
  final BoxDecoration? containerStyle;
  final double? size;
  final Color? color;
  final String? themeColor;
  final String? footerText;
  final TextStyle? footerTextStyles;

  Loading({
    this.containerStyle,
    this.size,
    this.color,
    this.themeColor,
    this.footerText,
    this.footerTextStyles,
  });

  @override
  Widget build(BuildContext context) {
    final theme = useTheme(context);
    final indicatorColor = themeColor != null ? theme[themeColor] : color;

    return Container(
      decoration: containerStyle,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(indicatorColor!),
            strokeWidth: size ?? 4.0,
          ),
          if (footerText != null)
            Text(
              footerText!,
              style: footerTextStyles,
            ),
        ],
      ),
    );
  }
}
