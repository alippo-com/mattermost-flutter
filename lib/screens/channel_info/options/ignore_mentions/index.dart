// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/material.dart';
import 'package:mattermost_flutter/constants.dart';
import 'package:mattermost_flutter/queries/servers/channel.dart';
import 'package:mattermost_flutter/queries/servers/user.dart';
import 'package:mattermost_flutter/screens/channel_info/options/ignore_mentions/ignore_mentions.dart';
import 'package:mattermost_flutter/types/theme.dart';
import 'package:mattermost_flutter/types/system.dart';
import 'package:rxdart/rxdart.dart';
import 'package:watermelondb/watermelondb.dart';

class IgnoreMentionsContainer extends StatelessWidget {
  final String channelId;
  final Database database;

  IgnoreMentionsContainer({required this.channelId, required this.database});

  bool isChannelMentionsIgnored(PartialChannelNotifyProps? channelNotifyProps, UserNotifyProps? userNotifyProps) {
    var ignoreChannelMentionsDefault = Channel.IGNORE_CHANNEL_MENTIONS_OFF;

    if (userNotifyProps?.channel == 'false') {
      ignoreChannelMentionsDefault = Channel.IGNORE_CHANNEL_MENTIONS_ON;
    }

    var ignoreChannelMentions = channelNotifyProps?.ignore_channel_mentions;
    if (ignoreChannelMentions == null || ignoreChannelMentions == Channel.IGNORE_CHANNEL_MENTIONS_DEFAULT) {
      ignoreChannelMentions = ignoreChannelMentionsDefault;
    }

    return ignoreChannelMentions != Channel.IGNORE_CHANNEL_MENTIONS_OFF;
  }

  @override
  Widget build(BuildContext context) {
    final channel = observeChannel(database, channelId);
    final currentUser = observeCurrentUser(database);
    final settings = observeChannelSettings(database, channelId);

    final ignoring = Rx.combineLatest2(
      currentUser,
      settings,
      (u, s) => isChannelMentionsIgnored(s?.notifyProps, u?.notifyProps),
    );

    return StreamBuilder(
      stream: ignoring,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return IgnoreMentions(
            ignoring: snapshot.data,
            displayName: channel.map((c) => c?.displayName),
          );
        } else {
          return Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}
