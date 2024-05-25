// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/material.dart';
import 'package:mattermost_flutter/types/emoji.dart';

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
      child: AnimatedOpacity(
        opacity: 1.0,
        duration: const Duration(milliseconds: 200),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            color: Colors.transparent,
          ),
          child: Emoji(
            emojiName: emojiName,
            size: 24,
          ),
        ),
      ),
    );
  }
}

class Emoji extends StatelessWidget {
  final String emojiName;
  final double size;

  const Emoji({
    required this.emojiName,
    required this.size,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      emojiName,
      style: TextStyle(fontSize: size),
    );
  }
}
