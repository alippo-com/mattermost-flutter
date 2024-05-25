// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/material.dart';
import 'package:mattermost_flutter/components/emoji.dart';
import 'package:mattermost_flutter/context/theme.dart';
import 'package:mattermost_flutter/utils/theme.dart';

class EmojiTouchable extends StatelessWidget {
  final String name;
  final Function(String) onEmojiPress;

  EmojiTouchable({required this.name, required this.onEmojiPress});

  @override
  Widget build(BuildContext context) {
    final theme = useTheme(context);
    final style = getStyleSheetFromTheme(theme);

    return GestureDetector(
      onTap: () => onEmojiPress(name),
      child: Container(
        height: 40,
        padding: EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: changeOpacity(theme.centerChannelColor, 0.2),
            ),
          ),
        ),
        child: Row(
          children: [
            Container(
              margin: EdgeInsets.only(right: 5),
              child: Emoji(
                emojiName: name,
                textStyle: TextStyle(color: Colors.black),
                size: 20,
              ),
            ),
            Text(
              ':$name:',
              style: TextStyle(
                fontSize: 13,
                color: theme.centerChannelColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Map<String, dynamic> getStyleSheetFromTheme(ThemeData theme) {
  return {
    'container': BoxDecoration(
      border: Border(
        bottom: BorderSide(
          color: changeOpacity(theme.centerChannelColor, 0.2),
        ),
      ),
    ),
    'emojiContainer': EdgeInsets.only(right: 5),
    'emoji': TextStyle(color: Colors.black),
    'emojiText': TextStyle(
      fontSize: 13,
      color: theme.centerChannelColor,
    ),
  };
}
