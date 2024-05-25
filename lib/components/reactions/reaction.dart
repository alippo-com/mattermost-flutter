
// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mattermost_flutter/utils/theme.dart';
import 'package:mattermost_flutter/components/animated_numbers.dart';
import 'package:mattermost_flutter/components/emoji.dart';
import 'package:mattermost_flutter/types/theme.dart';

class Reaction extends StatelessWidget {
  final int count;
  final String emojiName;
  final bool highlight;
  final void Function(String, bool) onPress;
  final void Function(String) onLongPress;
  final Theme theme;

  const Reaction({
    required this.count,
    required this.emojiName,
    required this.highlight,
    required this.onPress,
    required this.onLongPress,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final styles = _getStyleSheet(theme);
    final digits = count.toString().length;
    final minWidth = 50 + (digits * 5);
    final containerStyle = [
      styles['reaction'],
      if (highlight) styles['highlight'],
      {'minWidth': minWidth.toDouble()}
    ];

    return GestureDetector(
      onLongPress: () => onLongPress(emojiName),
      onTap: () => onPress(emojiName, highlight),
      child: Container(
        margin: EdgeInsets.only(bottom: 12, right: 8),
        decoration: BoxDecoration(
          color: highlight
              ? theme.buttonBg.withOpacity(0.08)
              : theme.centerChannelColor.withOpacity(0.08),
          borderRadius: BorderRadius.circular(4),
          border: highlight
              ? Border.all(color: theme.buttonBg, width: 1)
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              margin: EdgeInsets.symmetric(horizontal: 5),
              child: Emoji(
                emojiName: emojiName,
                size: 20,
                textStyle: TextStyle(color: Colors.black),
                testID: 'reaction.emoji.$emojiName',
              ),
            ),
            Container(
              margin: EdgeInsets.only(right: 8),
              child: AnimatedNumbers(
                fontStyle: TextStyle(
                  color: highlight
                      ? theme.buttonBg
                      : theme.centerChannelColor.withOpacity(0.56),
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                ),
                animateToNumber: count,
                animationDuration: Duration(milliseconds: 450),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Map<String, dynamic> _getStyleSheet(Theme theme) {
    return {
      'count': TextStyle(
        color: theme.centerChannelColor.withOpacity(0.56),
        fontWeight: FontWeight.w600,
        fontSize: 18,
      ),
      'countHighlight': TextStyle(
        color: theme.buttonBg,
      ),
      'customEmojiStyle': TextStyle(color: Colors.black),
      'emoji': {
        'marginHorizontal': 5,
      },
      'highlight': BoxDecoration(
        color: theme.buttonBg.withOpacity(0.08),
        border: Border.all(color: theme.buttonBg, width: 1),
      ),
      'reaction': BoxDecoration(
        color: theme.centerChannelColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: theme.buttonBg.withOpacity(0.08), width: 1),
      ),
    };
  }
}
