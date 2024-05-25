// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/material.dart';
import 'package:mattermost_flutter/components/emoji.dart';
import 'package:mattermost_flutter/types/typography.dart';

class EmojiPill extends StatelessWidget {
  final String name;
  final int count;
  final String? literal;

  EmojiPill({required this.name, required this.count, this.literal});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Color.fromRGBO(255, 255, 255, 0.16),
        borderRadius: BorderRadius.circular(20),
      ),
      padding: EdgeInsets.symmetric(horizontal: 16),
      margin: EdgeInsets.only(left: 6),
      height: 30,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Emoji(
            emojiName: name,
            literal: literal,
            size: 18,
          ),
          SizedBox(width: 8),
          Text(
            '$count',
            style: typography('Body', 75, 'SemiBold').copyWith(color: Colors.white),
          ),
        ],
      ),
    );
  }
}
