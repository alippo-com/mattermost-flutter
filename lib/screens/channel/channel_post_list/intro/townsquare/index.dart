// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/material.dart';
import 'package:mattermost_flutter/components/formatted_text.dart';
import 'package:mattermost_flutter/constants/permissions.dart';
import 'package:mattermost_flutter/utils/role.dart';
import 'package:mattermost_flutter/utils/theme.dart';
import 'package:mattermost_flutter/utils/typography.dart';
import 'package:mattermost_flutter/screens/channel/channel_post_list/intro/townsquare/illustration/town_square.dart';
import 'package:mattermost_flutter/screens/channel/channel_post_list/intro/townsquare/options.dart';
import 'package:mattermost_flutter/types/role_model.dart';

class TownSquare extends StatelessWidget {
  final String channelId;
  final String displayName;
  final List<RoleModel> roles;
  final Theme theme;

  TownSquare({
    required this.channelId,
    required this.displayName,
    required this.roles,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final styles = _getStyleSheet(theme);
    return Container(
      alignment: Alignment.center,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          TownSquareIllustration(theme: theme),
          Text(
            displayName,
            style: styles['title'],
            key: Key('channel_post_list.intro.display_name'),
          ),
          FormattedText(
            defaultMessage: 'Welcome to {name}. Everyone automatically becomes a member of this channel when they join the team.',
            id: 'intro.townsquare',
            style: styles['message'],
            values: {'name': displayName},
          ),
          IntroOptions(
            channelId: channelId,
            header: hasPermission(roles, Permissions.MANAGE_PUBLIC_CHANNEL_PROPERTIES),
            canAddMembers: false,
          ),
        ],
      ),
    );
  }

  Map<String, TextStyle> _getStyleSheet(Theme theme) {
    return {
      'container': TextStyle(
        alignment: Alignment.center,
        margin: const EdgeInsets.symmetric(horizontal: 20),
      ),
      'message': TextStyle(
        color: theme.centerChannelColor,
        marginTop: 16,
        textAlign: TextAlign.center,
        ...typography('Body', 200, 'Regular'),
        width: double.infinity,
      ),
      'title': TextStyle(
        color: theme.centerChannelColor,
        marginTop: 16,
        ...typography('Heading', 700, 'SemiBold'),
      ),
    };
  }
}