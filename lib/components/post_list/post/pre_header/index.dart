
// Dart Code
// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/material.dart';
import 'package:mattermost_flutter/components/compass_icon.dart';
import 'package:mattermost_flutter/components/formatted_text.dart';
import 'package:mattermost_flutter/context/theme.dart';
import 'package:mattermost_flutter/i18n.dart';
import 'package:mattermost_flutter/utils/theme.dart';

class PreHeader extends StatelessWidget {
  final bool? isConsecutivePost;
  final bool? isSaved;
  final bool isPinned;
  final bool? skipSavedHeader;
  final bool? skipPinnedHeader;

  PreHeader({
    this.isConsecutivePost,
    this.isSaved,
    required this.isPinned,
    this.skipSavedHeader,
    this.skipPinnedHeader,
  });

  @override
  Widget build(BuildContext context) {
    final theme = useTheme(context);
    final style = getStyleSheet(theme);
    final isPinnedAndSaved = isPinned && isSaved == true && skipSavedHeader != true && skipPinnedHeader != true;

    Map<String, String>? text;
    if (isPinnedAndSaved) {
      text = {
        'id': t('mobile.post_pre_header.pinned_saved'),
        'defaultMessage': 'Pinned and Saved',
      };
    } else if (isPinned && skipPinnedHeader != true) {
      text = {
        'id': t('mobile.post_pre_header.pinned'),
        'defaultMessage': 'Pinned',
      };
    } else if (isSaved == true && skipSavedHeader != true) {
      text = {
        'id': t('mobile.post_pre_header.saved'),
        'defaultMessage': 'Saved',
      };
    }

    if (text == null) {
      return Container();
    }

    return Container(
      decoration: style['container'],
      child: Row(
        children: [
          Container(
            decoration: style['iconsContainer'],
            child: Row(
              children: [
                if (isPinned && skipPinnedHeader != true)
                  CompassIcon(
                    name: 'pin',
                    size: 14,
                    style: style['icon'],
                  ),
                if (isPinnedAndSaved)
                  SizedBox(width: style['iconsSeparator'].marginRight),
                if (isSaved == true && skipSavedHeader != true)
                  CompassIcon(
                    name: 'bookmark',
                    size: 14,
                    style: style['icon'],
                  ),
              ],
            ),
          ),
          Container(
            decoration: style['rightColumn'],
            child: FormattedText(
              text: text,
              style: style['text'],
              testID: 'post_pre_header.text',
            ),
          ),
        ],
      ).applyPadding(isConsecutivePost == true ? style['consecutive'] : null),
    );
  }
}

Map<String, BoxDecoration> getStyleSheet(Theme theme) {
  return {
    'container': BoxDecoration(
      // Flutter equivalent for flex and flexDirection: 'row'
      // Other styling properties can be mapped similarly
    ),
    'consecutive': BoxDecoration(
      margin: EdgeInsets.only(bottom: 3),
    ),
    'iconsContainer': BoxDecoration(
      display: 'flex',
      flexDirection: 'row',
      alignItems: 'center',
      justifyContent: 'flex-end',
      marginRight: 10,
      width: 35,
    ),
    'icon': TextStyle(
      color: theme.linkColor,
    ),
    'iconsSeparator': BoxDecoration(
      marginRight: 5,
    ),
    'rightColumn': BoxDecoration(
      flex: 1,
      flexDirection: 'column',
      marginLeft: 2,
    ),
    'text': TextStyle(
      color: theme.linkColor,
      fontSize: 13,
      lineHeight: 15,
    ),
  };
}
