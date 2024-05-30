// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/material.dart';
import 'package:mattermost_flutter/components/compass_icon.dart';
import 'package:mattermost_flutter/components/emoji.dart';
import 'package:mattermost_flutter/utils/theme.dart';

class CustomStatusEmoji extends StatelessWidget {
  final VoidCallback onPress;
  final bool isStatusSet;
  final String? emoji;
  final Theme theme;

  CustomStatusEmoji({
    required this.onPress,
    required this.isStatusSet,
    this.emoji,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final style = _getStyleSheet(theme);

    return GestureDetector(
      onTap: onPress,
      child: Container(
        margin: EdgeInsets.only(left: 14),
        child: isStatusSet
            ? Emoji(
                emojiName: emoji ?? 'speech_balloon',
                size: 20,
              )
            : CompassIcon(
                name: 'emoticon-happy-outline',
                size: 24,
                color: style['icon']!.color,
              ),
      ),
    );
  }

  Map<String, TextStyle> _getStyleSheet(Theme theme) {
    return {
      'iconContainer': TextStyle(
        margin: EdgeInsets.only(left: 14),
      ),
      'icon': TextStyle(
        color: changeOpacity(theme.centerChannelColor, 0.64),
      ),
      'emoji': TextStyle(
        color: theme.centerChannelColor,
      ),
    };
  }
}
