// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/material.dart';
import 'package:mattermost_flutter/components/emoji.dart';
import 'package:mattermost_flutter/constants/emoji.dart';
import 'package:mattermost_flutter/utils/emoji/helpers.dart';

class ButtonBindingText extends StatelessWidget {
  final String message;
  final TextStyle style;

  ButtonBindingText({required this.message, required this.style});

  @override
  Widget build(BuildContext context) {
    List<Widget> components = [];

    String text = message;
    RegExpMatch? match;

    while (text.isNotEmpty) {
      // See if the text starts with an emoji
      match = reEmoji.firstMatch(text);
      if (match != null) {
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
      match = reEmoticon.firstMatch(text);
      if (match != null) {
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

      // This is plain text, so capture as much text as possible until we hit the next possible emoji.
      match = reMain.firstMatch(text);
      if (match != null) {
        components.add(
          Text(
            match.group(0)!,
            key: ValueKey(components.length),
            style: style,
          ),
        );
        text = text.substring(match.group(0)!.length);
      }
    }

    return Wrap(
      alignment: WrapAlignment.start,
      children: components,
    );
  }
}
