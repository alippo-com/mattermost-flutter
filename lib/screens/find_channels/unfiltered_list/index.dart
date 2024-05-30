// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:watermelondb/watermelondb.dart';
import 'package:mattermost_flutter/queries/servers/channel.dart';
import 'package:mattermost_flutter/screens/find_channels/utils.dart';
'unfiltered_list.dart';

const int MAX_CHANNELS = 20;

class EnhancedUnfilteredList extends StatelessWidget {
  final Database database;

  EnhancedUnfilteredList({required this.database});

  @override
  Widget build(BuildContext context) {
    final teamsCount = queryJoinedTeams(database).observeCount();
    final teamIds = queryJoinedTeams(database).observe().switchMap(
          (teams) => Stream.value(Set<String>.from(teams.map((t) => t.id))),
        );

    final recentChannels = queryMyRecentChannels(database, MAX_CHANNELS)
        .observeWithColumns(['last_viewed_at'])
        .switchMap((myChannels) => retrieveChannels(database, myChannels, true))
        .combineLatestWith(teamIds, (myChannels, tmIds) => removeChannelsFromArchivedTeams(myChannels, tmIds));

    return UnfilteredList(
      recentChannels: recentChannels,
      showTeamName: teamsCount.switchMap((count) => Stream.value(count > 1)),
    );
  }
}
