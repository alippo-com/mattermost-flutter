// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/material.dart';
import 'package:mattermost_flutter/database/database.dart'; // Assuming this is the correct import path
import 'package:mattermost_flutter/queries/servers/system.dart';
import 'package:mattermost_flutter/queries/servers/thread.dart';
import 'package:mattermost_flutter/components/threads_button.dart';

class EnhancedThreadsButton extends StatelessWidget {
  final Database database;

  EnhancedThreadsButton({required this.database});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<String>(
      stream: observeCurrentTeamId(database),
      builder: (context, teamSnapshot) {
        if (!teamSnapshot.hasData) {
          return CircularProgressIndicator();
        }

        final currentTeamId = teamSnapshot.data!;

        return StreamBuilder<String>(
          stream: observeCurrentChannelId(database),
          builder: (context, channelSnapshot) {
            if (!channelSnapshot.hasData) {
              return CircularProgressIndicator();
            }

            final currentChannelId = channelSnapshot.data!;

            return StreamBuilder<UnreadsAndMentions>(
              stream: observeUnreadsAndMentionsInTeam(database, currentTeamId),
              builder: (context, unreadsSnapshot) {
                if (!unreadsSnapshot.hasData) {
                  return CircularProgressIndicator();
                }

                final unreadsAndMentions = unreadsSnapshot.data!;

                return ThreadsButton(
                  currentChannelId: currentChannelId,
                  unreadsAndMentions: unreadsAndMentions,
                );
              },
            );
          },
        );
      },
    );
  }
}
