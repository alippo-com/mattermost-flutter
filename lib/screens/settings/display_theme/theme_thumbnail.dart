// Converted Dart code from React Native TypeScript
// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'types/theme.dart';
import 'package:mattermost_flutter/utils/theme.dart';

class ThemeThumbnail extends StatelessWidget {
  final String borderColorBase;
  final String borderColorMix;
  final Theme theme;
  final double width;

  const ThemeThumbnail({
    Key? key,
    required this.borderColorBase,
    required this.borderColorMix,
    required this.theme,
    required this.width,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // the original height of the thumbnail
    final baseWidth = 180.0;
    final baseHeight = 134.0;

    // calculate actual height proportionally to base size
    final height = (width * baseHeight / baseWidth).roundToDouble();

    // convenience values of various sub elements of the thumbnail
    final sidebarWidth = 80.0;
    final postsContainerWidth = 100.0;
    final spacing = 8.0;
    final rowHeight = 6.0;
    final rowRadius = rowHeight / 2;
    final postInputHeight = 10.0;
    final postWidth = postsContainerWidth - (spacing * 2);
    final channelNameWidth = sidebarWidth - (spacing * 3) - (rowHeight * 2);
    final buttonWidth = postsContainerWidth - (spacing * 8);

    return SvgPicture.string(
      '''
      <svg width="$width" height="$height" viewBox="-2 -2 ${baseWidth + 4} ${baseHeight + 4}" fill="none">
        <rect fill="${theme.centerChannelBg}" x="0" y="0" width="$baseWidth" height="$baseHeight" />
        <rect fill="${theme.newMessageSeparator}" x="$sidebarWidth" y="${(spacing * 4) + (rowHeight * 3)}" width="$postsContainerWidth" height="1" />
        <rect fill="${theme.buttonBg}" x="${sidebarWidth + (spacing * 4)}" y="${(spacing * 8) + (rowHeight * 6) + 1}" width="$buttonWidth" height="$rowHeight" rx="$rowRadius" />
        <rect fill="${changeOpacity(theme.centerChannelColor, 0.16)}" x="${sidebarWidth + spacing}" y="${(spacing * 9) + (rowHeight * 7) + 1}" width="$postWidth" height="$postInputHeight" rx="${postInputHeight / 2}" />
        <rect fill="${theme.centerChannelBg}" x="${sidebarWidth + spacing + 1}" y="${(spacing * 9) + (rowHeight * 7) + 2}" width="${postWidth - 2}" height="${postInputHeight - 2}" rx="${(postInputHeight - 2) / 2}" />
        <g fill="${changeOpacity(theme.centerChannelColor, 0.16)}">
          <rect x="${sidebarWidth + spacing}" y="$spacing" width="$postWidth" height="$rowHeight" rx="$rowRadius" />
          <rect x="${sidebarWidth + spacing}" y="${(spacing * 2) + rowHeight}" width="$postWidth" height="$rowHeight" rx="$rowRadius" />
          <rect x="${sidebarWidth + spacing}" y="${(spacing * 3) + (rowHeight * 2)}" width="$postWidth" height="$rowHeight" rx="$rowRadius" />
          <rect x="${sidebarWidth + spacing}" y="${(spacing * 5) + (rowHeight * 3) + 1}" width="$postWidth" height="$rowHeight" rx="$rowRadius" />
          <rect x="${sidebarWidth + spacing}" y="${(spacing * 6) + (rowHeight * 4) + 1}" width="$postWidth" height="$rowHeight" rx="$rowRadius" />
          <rect x="${sidebarWidth + spacing}" y="${(spacing * 7) + (rowHeight * 5) + 1}" width="$postWidth" height="$rowHeight" rx="$rowRadius" />
        </g>
        <g>
          <rect fill="${theme.sidebarBg}" x="0" y="0" width="$sidebarWidth" height="$baseHeight" />
          <g fill="${changeOpacity(theme.sidebarText, 0.48)}">
            <circle cx="${spacing + rowRadius}" cy="${spacing + rowRadius}" r="$rowRadius" />
            <circle cx="${spacing + rowRadius}" cy="${(spacing * 2) + rowHeight + rowRadius}" r="$rowRadius" />
            <circle cx="${spacing + rowRadius}" cy="${(spacing * 4) + (rowHeight * 3) + rowRadius}" r="$rowRadius" />
            <circle cx="${spacing + rowRadius}" cy="${(spacing * 5) + (rowHeight * 4) + rowRadius}" r="$rowRadius" />
            <circle cx="${spacing + rowRadius}" cy="${(spacing * 7) + (rowHeight * 6) + rowRadius}" r="$rowRadius" />
            <circle cx="${spacing + rowRadius}" cy="${(spacing * 8) + (rowHeight * 7) + rowRadius}" r="$rowRadius" />
            <rect x="${(spacing * 1.5) + rowHeight}" y="$spacing" width="$channelNameWidth" height="$rowHeight" rx="$rowRadius" />
            <rect x="${(spacing * 1.5) + rowHeight}" y="${(spacing * 2) + rowHeight}" width="$channelNameWidth" height="$rowHeight" rx="$rowRadius" />
            <rect x="${(spacing * 1.5) + rowHeight}" y="${(spacing * 4) + (rowHeight * 3)}" width="$channelNameWidth" height="$rowHeight" rx="$rowRadius" />
            <rect x="${(spacing * 1.5) + rowHeight}" y="${(spacing * 5) + (rowHeight * 4)}" width="$channelNameWidth" height="$rowHeight" rx="$rowRadius" />
            <rect x="${(spacing * 1.5) + rowHeight}" y="${(spacing * 6) + (rowHeight * 5)}" width="$channelNameWidth" height="$rowHeight" rx="$rowRadius" />
            <rect x="${(spacing * 1.5) + rowHeight}" y="${(spacing * 7) + (rowHeight * 6)}" width="$channelNameWidth" height="$rowHeight" rx="$rowRadius" />
            <rect x="${(spacing * 1.5) + rowHeight}" y="${(spacing * 8) + (rowHeight * 7)}" width="$channelNameWidth" height="$rowHeight" rx="$rowRadius" />
            <rect x="${(spacing * 1.5) + rowHeight}" y="${(spacing * 9) + (rowHeight * 8)}" width="$channelNameWidth" height="$rowHeight" rx="$rowRadius" />
          </g>
          <circle fill="${theme.onlineIndicator}" cx="${spacing + rowRadius}" cy="${(spacing * 3) + (rowHeight * 2) + rowRadius}" r="$rowRadius" />
          <circle fill="${theme.awayIndicator}" cx="${spacing + rowRadius}" cy="${(spacing * 6) + (rowHeight * 5) + rowRadius}" r="$rowRadius" />
          <circle fill="${theme.dndIndicator}" cx="${spacing + rowRadius}" cy="${(spacing * 9) + (rowHeight * 8) + rowRadius}" r="$rowRadius" />
          <g fill="${theme.sidebarUnreadText}">
            <circle cx="${(spacing * 2.5) + rowHeight + channelNameWidth}" cy="${(spacing * 3) + (rowHeight * 2) + rowRadius}" r="$rowRadius" />
            <rect x="${(spacing * 1.5) + rowHeight}" y="${(spacing * 3) + (rowHeight * 2)}" width="$channelNameWidth" height="$rowHeight" rx="$rowRadius" />
          </g>
        </g>
        <rect x="-1" y="-1" width="${baseWidth + 2}" height="${baseHeight + 2}" rx="4" stroke="$borderColorBase" strokeWidth="2" />
        <rect x="-1" y="-1" width="${baseWidth + 2}" height="${baseHeight + 2}" rx="4" stroke="$borderColorMix" strokeWidth="2" />
      </svg>
      ''',
      width: width,
      height: height,
    );
  }
}

String changeOpacity(String color, double opacity) {
  // Logic to change color opacity
  // Assuming color is in #RRGGBB format
  int r = int.parse(color.substring(1, 3), radix: 16);
  int g = int.parse(color.substring(3, 5), radix: 16);
  int b = int.parse(color.substring(5, 7), radix: 16);
  int a = (opacity * 255).round();

  return '#${a.toRadixString(16).padLeft(2, '0')}${r.toRadixString(16).padLeft(2, '0')}${g.toRadixString(16).padLeft(2, '0')}${b.toRadixString(16).padLeft(2, '0')}';
}
