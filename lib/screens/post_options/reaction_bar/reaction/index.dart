// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/material.dart';
import 'package:mattermost_flutter/components/emoji.dart';
import 'package:mattermost_flutter/context/theme.dart';
import 'package:mattermost_flutter/utils/theme.dart';

class Reaction extends StatelessWidget {
  final void Function(String) onPressReaction;
  final String emoji;
  final double iconSize;
  final double containerSize;
  final String? testID;

  Reaction({
    required this.onPressReaction,
    required this.emoji,
    required this.iconSize,
    required this.containerSize,
    this.testID,
  });

  @override
  Widget build(BuildContext context) {
    final theme = useTheme(context);
    final styles = getStyleSheet(theme);

    return GestureDetector(
      onTap: () => onPressReaction(emoji),
      child: Container(
        key: Key(emoji),
        decoration: styles['reactionContainer'],
        width: containerSize,
        height: containerSize,
        child: Center(
          child: Emoji(
            emojiName: emoji,
            textStyle: styles['emoji'],
            size: iconSize,
          ),
        ),
      ),
    );
  }

  Map<String, dynamic> getStyleSheet(ThemeData theme) {
    return {
      'emoji': TextStyle(
        color: Colors.black,
        fontWeight: FontWeight.bold,
      ),
      'highlight': BoxDecoration(
        color: changeOpacity(theme.buttonColor, 0.08),
        borderRadius: BorderRadius.circular(4),
      ),
      'reactionContainer': BoxDecoration(
        color: changeOpacity(theme.primaryColor, 0.04),
        borderRadius: BorderRadius.circular(4),
      ),
    };
  }

  Color changeOpacity(Color color, double opacity) {
    return color.withOpacity(opacity);
  }
}
