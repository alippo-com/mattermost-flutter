
// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/material.dart';
import 'package:mattermost_flutter/components/channel_actions/copy_channel_link_option/copy_channel_link_option.dart';
import 'package:mattermost_flutter/queries/servers/channel.dart';
import 'package:mattermost_flutter/queries/servers/team.dart';
import 'package:mattermost_flutter/types/database/database.dart';
import 'package:rxdart/rxdart.dart';

class EnhancedCopyChannelLinkOption extends StatelessWidget {
  final String channelId;
  final Database database;

  EnhancedCopyChannelLinkOption({required this.channelId, required this.database});

  @override
  Widget build(BuildContext context) {
    final channel = observeChannel(database, channelId);
    final team = channel.switchMap((c) =>
        c?.teamId != null ? observeTeam(database, c.teamId!) : Stream.value(null));
    final teamName = team.switchMap((t) => Stream.value(t?.name));
    final channelName = channel.switchMap((c) => Stream.value(c?.name));

    return CopyChannelLinkOption(
      channelName: channelName,
      teamName: teamName,
    );
  }
}

EnhancedCopyChannelLinkOption withDatabase(Database database, String channelId) {
  return EnhancedCopyChannelLinkOption(channelId: channelId, database: database);
}
