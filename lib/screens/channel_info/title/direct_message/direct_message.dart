// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/material.dart';
import 'package:mattermost_flutter/components/profile_picture.dart';
import 'package:mattermost_flutter/components/tag.dart';
import 'package:mattermost_flutter/utils/theme.dart';
import 'package:mattermost_flutter/utils/typography.dart';

class DirectMessage extends StatelessWidget {
  final String? displayName;
  final UserModel? user;
  final bool hideGuestTags;

  DirectMessage({
    this.displayName,
    this.user,
    required this.hideGuestTags,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final styles = _getStyleSheet(theme);
    final directMessageUserTestId = 'channel_info.title.direct_message.\${user?.id}';

    return Container(
      key: Key(directMessageUserTestId),
      decoration: styles['container'],
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          ProfilePicture(
            author: user,
            size: 64,
            iconSize: 64,
            showStatus: true,
            statusSize: 24,
            testID: '\$directMessageUserTestId.profile_picture',
          ),
          Container(
            margin: EdgeInsets.only(left: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        displayName ?? '',
                        overflow: TextOverflow.ellipsis,
                        style: styles['title'],
                        key: Key('\$directMessageUserTestId.display_name'),
                      ),
                    ),
                    if (user?.isGuest == true && !hideGuestTags)
                      GuestTag(
                        textStyle: styles['tag'],
                        style: styles['tagContainer'],
                        key: Key('\$directMessageUserTestId.guest.tag'),
                      ),
                    if (user?.isBot == true)
                      BotTag(
                        textStyle: styles['tag'],
                        style: styles['tagContainer'],
                        key: Key('\$directMessageUserTestId.bot.tag'),
                      ),
                  ],
                ),
                if (user?.position?.isNotEmpty == true)
                  Text(
                    user?.position ?? '',
                    style: styles['position'],
                    key: Key('\$directMessageUserTestId.position'),
                  ),
                if (user?.isBot == true && user?.props?.bot_description?.isNotEmpty == true)
                  Text(
                    user?.props?.bot_description ?? '',
                    style: styles['position'],
                    key: Key('\$directMessageUserTestId.bot_description'),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Map<String, TextStyle> _getStyleSheet(ThemeData theme) {
    return {
      'container': BoxDecoration(
        color: theme.colorScheme.surface,
      ),
      'displayName': TextStyle(
        color: theme.textTheme.bodyLarge?.color,
      ),
      'position': TextStyle(
        color: changeOpacity(theme.primaryColor, 0.72),
        fontSize: 14,
        fontWeight: FontWeight.w400,
      ),
      'tagContainer': TextStyle(
        color: theme.primaryColor,
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
      'tag': TextStyle(
        color: theme.primaryColor,
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
      'title': TextStyle(
        color: theme.primaryColor,
        fontSize: 18,
        fontWeight: FontWeight.w700,
      ),
    };
  }
}
