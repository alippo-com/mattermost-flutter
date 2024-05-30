import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:mattermost_flutter/database/database.dart';
import 'package:mattermost_flutter/queries/channel.dart';
import 'package:mattermost_flutter/queries/system.dart';
import 'package:mattermost_flutter/queries/team.dart';
import 'channel_mention.dart';

class ChannelMentions {
  final String? id;
  final String displayName;
  final String? name;
  final String teamName;

  ChannelMentions({
    this.id,
    required this.displayName,
    this.name,
    required this.teamName,
  });
}

class ChannelMentionProvider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final database = Provider.of<Database>(context);
    final currentTeamId = observeCurrentTeamId(database);
    final channels = currentTeamId.switchMap((id) {
      return queryAllChannelsForTeam(database, id).observeWithColumns(['display_name']);
    });
    final team = currentTeamId.switchMap((id) {
      return observeTeam(database, id);
    });

    return StreamProvider.value(
      value: channels,
      child: StreamProvider.value(
        value: currentTeamId,
        child: StreamProvider.value(
          value: team,
          child: ChannelMention(),
        ),
      ),
    );
  }
}
