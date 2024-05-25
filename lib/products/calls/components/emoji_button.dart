// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/material.dart';
import 'package:mattermost_flutter/components/emoji.dart';

class EmojiButton extends StatelessWidget {
  final String emojiName;
  final VoidCallback onPress;
  final TextStyle? style;

  const EmojiButton({
    required this.emojiName,
    required this.onPress,
    this.style,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPress,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Emoji(
          emojiName: emojiName,
          size: 24,
          style: style,
        ),
      ),
    );
  }
}
