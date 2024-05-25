// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/material.dart';
import 'package:mattermost_flutter/components/badge.dart';
import 'package:mattermost_flutter/components/channel_item.dart';
import 'package:mattermost_flutter/components/compass_icon.dart';
import 'package:mattermost_flutter/components/formatted_text.dart';
import 'package:mattermost_flutter/constants/view.dart';
import 'package:mattermost_flutter/context/server.dart';
import 'package:mattermost_flutter/context/theme.dart';
import 'package:mattermost_flutter/hooks/device.dart';
import 'package:mattermost_flutter/utils/tap.dart';
import 'package:mattermost_flutter/utils/theme.dart';

class ThreadsButton extends StatelessWidget {
  final String currentChannelId;
  final bool? onCenterBg;
  final VoidCallback? onPress;
  final bool shouldHighlighActive;
  final bool isOnHome;
  final UnreadsAndMentions unreadsAndMentions;

  const ThreadsButton({
    Key? key,
    required this.currentChannelId,
    this.onCenterBg,
    this.onPress,
    required this.unreadsAndMentions,
    this.shouldHighlighActive = false,
    this.isOnHome = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isTablet = useIsTablet();
    final serverUrl = useServerUrl();

    final theme = useTheme();
    final styles = getChannelItemStyleSheet(theme);
    final customStyles = getStyleSheet(theme);

    final handlePress = preventDoubleTap(() {
      if (onPress != null) {
        onPress!();
      } else {
        switchToGlobalThreads(serverUrl);
      }
    });

    final unreads = unreadsAndMentions.unreads;
    final mentions = unreadsAndMentions.mentions;
    final isActive = isTablet && shouldHighlighActive && currentChannelId.isEmpty;

    final containerStyle = [
      styles.container,
      if (isOnHome) HOME_PADDING,
      if (isActive) styles.activeItem,
      if (isActive && isOnHome)
        Padding(
          padding: EdgeInsets.only(left: HOME_PADDING.left - styles.activeItem.border.left.width),
        ),
      const BoxConstraints(minHeight: ROW_HEIGHT),
    ];

    final iconStyle = [
      customStyles.icon,
      if (isActive || unreads) customStyles.iconActive,
      if (onCenterBg ?? false) customStyles.iconInfo,
    ];

    final textStyle = [
      customStyles.text,
      unreads ? channelItemTextStyle.bold : channelItemTextStyle.regular,
      styles.text,
      if (unreads) styles.highlight,
      if (isActive) styles.textActive,
      if (onCenterBg ?? false) styles.textOnCenterBg,
    ];

    final badgeStyle = [
      styles.badge,
      if (onCenterBg ?? false) styles.badgeOnCenterBg,
    ];

    return GestureDetector(
      onTap: handlePress,
      child: Container(
        key: const Key('channel_list.threads.button'),
        child: Row(
          children: [
            CompassIcon(
              name: 'message-text-outline',
              style: iconStyle,
            ),
            FormattedText(
              id: 'threads',
              defaultMessage: 'Threads',
              style: textStyle,
            ),
            Badge(
              value: mentions,
              style: badgeStyle,
              visible: mentions > 0,
            ),
          ],
        ),
      ),
    );
  }

  static TextStyle getChannelItemTextStyle(BuildContext context) {
    final theme = useTheme();
    return TextStyle(
      color: changeOpacity(theme.sidebarText, 0.5),
      fontSize: 24,
      marginRight: 12,
    );
  }

  static TextStyle get activeItem => TextStyle(
        color: useTheme().sidebarText,
      );

  static TextStyle get iconInfo => TextStyle(
        color: changeOpacity(useTheme().centerChannelColor, 0.72),
      );

  static TextStyle get text => TextStyle(
        flex: 1,
      );
}

class UnreadsAndMentions {
  final bool unreads;
  final int mentions;

  UnreadsAndMentions({required this.unreads, required this.mentions});
}
