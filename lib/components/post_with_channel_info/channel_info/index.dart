// Dart Code
// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:watermelon_db/watermelon_db.dart';
import 'package:rxdart/rxdart.dart';
import 'package:flutter/widgets.dart';

import 'package:mattermost_flutter/queries/servers/channel.dart';
import 'package:mattermost_flutter/queries/servers/team.dart';
import 'package:mattermost_flutter/components/post_with_channel_info/channel_info/channel_info.dart';

import 'package:mattermost_flutter/types/database/database.dart';
import 'package:mattermost_flutter/types/database/models/servers/post.dart';

class ChannelInfoContainer extends StatelessWidget {
  final PostModel post;
  final Database database;

  ChannelInfoContainer({required this.post, required this.database});

  @override
  Widget build(BuildContext context) {
    final channel = observeChannel(database, post.channelId);

    final channelId = channel.switchMap((chan) => chan != null ? Observable.just(chan.id) : Observable.just(''));
    final channelName = channel.switchMap((chan) => chan != null ? Observable.just(chan.displayName) : Observable.just(''));
    final teamName = channel.switchMap((chan) => chan != null && chan.teamId != null
        ? observeTeam(database, chan.teamId).switchMap((team) => Observable.just(team?.displayName ?? null))
        : Observable.just(null));

    return ChannelInfo(
      channelId: channelId,
      channelName: channelName,
      teamName: teamName,
    );
  }
}
