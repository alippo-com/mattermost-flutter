// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/material.dart';
import 'package:mattermost_flutter/utils/emoji/helpers.dart';
import 'package:mattermost_flutter/utils/theme.dart';
import 'package:mattermost_flutter/utils/typography.dart';
import 'package:mattermost_flutter/context/theme.dart';

class EmojiAliases extends StatelessWidget {
  final String emoji;

  EmojiAliases({required this.emoji});

  @override
  Widget build(BuildContext context) {
    final theme = useTheme(context);
    final style = getStyleSheet(theme);
    final aliases = getEmojiByName(emoji, [])
            ?.shortNames
            ?.map((n) => ":$n:")
            .join('  ') ??
        ":$emoji:";

    return Container(
      margin: EdgeInsets.only(bottom: 16),
      child: Text(
        aliases,
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
        style: style.title,
      ),
    );
  }

  TextStyle getStyleSheet(ThemeData theme) {
    return TextStyle(
      color: theme.primaryColor,
      fontSize: 75,
      fontWeight: FontWeight.w600, // SemiBold
    );
  }
}
