// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/animation.dart';
import 'package:provider/provider.dart';
import 'package:mattermost_flutter/utils/theme.dart';
import 'package:mattermost_flutter/types/typography.dart';

class NavigationHeaderLargeTitle extends StatelessWidget {
  final double heightOffset;
  final bool hasSearch;
  final String? subtitle;
  final Theme theme;
  final String title;
  final Animation<double> translateY;

  const NavigationHeaderLargeTitle({
    Key? key,
    required this.heightOffset,
    required this.hasSearch,
    this.subtitle,
    required this.theme,
    required this.title,
    required this.translateY,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final styles = getStyleSheet(theme);

    return AnimatedBuilder(
      animation: translateY,
      builder: (context, child) {
        final transform = Matrix4.translationValues(0, translateY.value, 0);
        return Container(
          height: heightOffset,
          padding: EdgeInsets.symmetric(horizontal: 20),
          color: theme.sidebarBg,
          child: Transform(
            transform: transform,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: styles['heading'],
                  overflow: TextOverflow.ellipsis,
                ),
                if (!hasSearch && subtitle != null)
                  Text(
                    subtitle!,
                    style: styles['subHeading'],
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Map<String, TextStyle> getStyleSheet(Theme theme) {
    return {
      'heading': typography(
        'Heading',
        800,
        color: theme.sidebarHeaderTextColor,
      ),
      'subHeading': typography(
        'Heading',
        200,
        color: changeOpacity(theme.sidebarHeaderTextColor, 0.8),
      ),
    };
  }

  Color changeOpacity(Color color, double opacity) {
    return color.withOpacity(opacity);
  }
}
