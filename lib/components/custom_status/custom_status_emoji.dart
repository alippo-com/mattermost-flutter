
import 'package:flutter/material.dart';
import 'package:mattermost_flutter/components/emoji.dart';
import 'package:mattermost_flutter/types/components/emoji.dart';

class CustomStatusEmoji extends StatelessWidget {
  final UserCustomStatus customStatus;
  final double emojiSize;
  final EmojiCommonStyle style;

  CustomStatusEmoji({
    @required this.customStatus,
    this.emojiSize = 16.0,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    if (customStatus.emoji != null) {
      return Emoji(
        size: emojiSize,
        emojiName: customStatus.emoji,
        commonStyle: style,
      );
    }
    return Container();  // Equivalent to returning null in Flutter widgets
  }
}
