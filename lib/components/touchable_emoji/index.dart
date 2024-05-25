// Copyright (c) 2015-present Mattermost, Inc.
// All Rights Reserved. See LICENSE.txt for license information.

import 'package:flutter/material.dart';
import 'package:mattermost_flutter/components/emoji.dart';
import 'package:mattermost_flutter/components/touchable_with_feedback.dart';
import 'package:mattermost_flutter/utils/tap.dart';
import 'package:mattermost_flutter/components/skinned_emoji.dart';

class TouchableEmoji extends StatelessWidget {
  final String? category;
  final String name;
  final Function(String) onEmojiPress;
  final double size;
  final TextStyle? style;

  static const List<String> CATEGORIES_WITH_SKINS = ['people-body'];

  static const EdgeInsets hitSlop = EdgeInsets.all(10);

  TouchableEmoji({
    this.category,
    required this.name,
    required this.onEmojiPress,
    this.size = 30.0,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    void onPress() {
      preventDoubleTap(() => onEmojiPress(name));
    }

    if (category != null && CATEGORIES_WITH_SKINS.contains(category)) {
      return SkinnedEmoji(
        name: name,
        onEmojiPress: onEmojiPress,
        size: size,
        style: style,
      );
    }

    return Container(
      decoration: BoxDecoration(style: style),
      child: TouchableWithFeedback(
        hitSlop: hitSlop,
        onPress: onPress,
        style: style,
        type: 'opacity',
        child: Emoji(
          emojiName: name,
          size: size,
        ),
      ),
    );
  }
}
