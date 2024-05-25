
// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/material.dart';
import 'package:mattermost_flutter/database/database.dart';
import 'package:mattermost_flutter/models/team_item.dart';
import 'package:rxdart/rxdart.dart';

class TeamItemWrapper extends StatelessWidget {
  final MyTeamModel myTeam;
  final Database database;

  TeamItemWrapper({required this.myTeam, required this.database});

  @override
  Widget build(BuildContext context) {
    // Observables and Streams
    final myChannels = queryMyChannelsByTeam(database, myTeam.id)
        .observeWithColumns(['mentions_count', 'is_unread']);
    final notifyProps = observeAllMyChannelNotifyProps(database);

    final hasUnreads = myChannels.combineLatest(notifyProps, (mycs, notify) {
      return mycs.any((v) {
        final isMuted = notify[v.id]?.markUnread == 'mention';
        return v.isUnread && !isMuted;
      });
    });

    final selected = observeCurrentTeamId(database).switchMap((ctid) {
      return Stream.value(ctid == myTeam.id);
    }).distinct();

    return StreamBuilder<bool>(
      stream: selected,
      builder: (context, selectedSnapshot) {
        return StreamBuilder<bool>(
          stream: hasUnreads,
          builder: (context, hasUnreadsSnapshot) {
            return TeamItem(
              team: observeTeam(database, myTeam.id),
              mentionCount: observeMentionCount(database, myTeam.id, false),
              hasUnreads: hasUnreadsSnapshot.data ?? false,
              selected: selectedSnapshot.data ?? false,
            );
          },
        );
      },
    );
  }
}
