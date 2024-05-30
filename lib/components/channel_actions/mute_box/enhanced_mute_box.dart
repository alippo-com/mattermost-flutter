// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/material.dart';
import 'package:mattermost_flutter/actions/remote/channel.dart';
import 'package:mattermost_flutter/components/channel_actions/mute_box/mute_box.dart';
import 'package:mattermost_flutter/constants/general.dart';
import 'package:mattermost_flutter/queries/servers/channel.dart';

class EnhancedMuteBox extends StatelessWidget {
  final String channelId;
  final Database database;

  EnhancedMuteBox({required this.channelId, required this.database});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: observeChannelSettings(database, channelId).switchMap(
        (settings) => Stream.value(settings?.notifyProps?.markUnread == General.MENTION),
      ),
      builder: (context, snapshot) {
        final isMuted = snapshot.data ?? false;
        return MuteBox(
          channelId: channelId,
          isMuted: isMuted,
        );
      },
    );
  }
}

EnhancedMuteBox withDatabase(Database database, String channelId) {
  return EnhancedMuteBox(channelId: channelId, database: database);
}
