import 'package:flutter/material.dart';
import 'package:mattermost_flutter/components/emoji.dart';
import 'package:mattermost_flutter/constants/emoji.dart';
import 'package:mattermost_flutter/utils/emoji/helpers.dart';

class ActionButtonText extends StatelessWidget {
  final String message;
  final TextStyle style;

  ActionButtonText({required this.message, required this.style});

  @override
  Widget build(BuildContext context) {
    List<Widget> components = [];
    String text = message;

    while (text.isNotEmpty) {
      RegExpMatch? match;

      // See if the text starts with an emoji
      if ((match = reEmoji.firstMatch(text)) != null) {
        components.add(
          Emoji(
            key: ValueKey(components.length),
            literal: match.group(0)!,
            emojiName: match.group(1)!,
            textStyle: style,
          ),
        );
        text = text.substring(match.group(0)!.length);
        continue;
      }

      // Or an emoticon
      if ((match = reEmoticon.firstMatch(text)) != null) {
        String emoticonName = getEmoticonName(match.group(0)!);
        if (emoticonName.isNotEmpty) {
          components.add(
            Emoji(
              key: ValueKey(components.length),
              literal: match.group(0)!,
              emojiName: emoticonName,
              textStyle: style,
            ),
          );
          text = text.substring(match.group(0)!.length);
          continue;
        }
      }

      // This is plain text, so capture as much text as possible until we hit the next possible emoji. Note that
      // reMain always captures at least one character, so text will always be getting shorter
      match = reMain.firstMatch(text);
      if (match == null) {
        continue;
      }

      components.add(
        Text(
          match.group(0)!,
          style: style,
        ),
      );
      text = text.substring(match.group(0)!.length);
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: components,
    );
  }
}
