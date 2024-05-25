import 'package:flutter/material.dart';
import 'package:mattermost_flutter/components/channel_add_members.dart';
import 'package:mattermost_flutter/constants.dart';
import 'package:mattermost_flutter/database/observables.dart';
import 'package:mattermost_flutter/queries/app/global.dart';
import 'package:mattermost_flutter/queries/servers/channel.dart';
import 'package:mattermost_flutter/queries/servers/user.dart';
import 'package:mattermost_flutter/types.dart';

class ChannelAddMembersScreen extends StatefulWidget {
  final String channelId;

  ChannelAddMembersScreen({required this.channelId});

  @override
  _ChannelAddMembersScreenState createState() => _ChannelAddMembersScreenState();
}

class _ChannelAddMembersScreenState extends State<ChannelAddMembersScreen> {
  late final Stream<ChannelModel> channelStream;
  late final Stream<String> teammateNameDisplayStream;
  late final Stream<bool> tutorialWatchedStream;

  @override
  void initState() {
    super.initState();
    final database = DatabaseProvider.of(context).database;
    channelStream = observeChannel(database, widget.channelId);
    teammateNameDisplayStream = observeTeammateNameDisplay(database);
    tutorialWatchedStream = observeTutorialWatched(Tutorial.PROFILE_LONG_PRESS);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<ChannelModel>(
      stream: channelStream,
      builder: (context, channelSnapshot) {
        if (!channelSnapshot.hasData) {
          return CircularProgressIndicator();
        }
        final channel = channelSnapshot.data!;

        return StreamBuilder<String>(
          stream: teammateNameDisplayStream,
          builder: (context, teammateNameDisplaySnapshot) {
            if (!teammateNameDisplaySnapshot.hasData) {
              return CircularProgressIndicator();
            }
            final teammateNameDisplay = teammateNameDisplaySnapshot.data!;

            return StreamBuilder<bool>(
              stream: tutorialWatchedStream,
              builder: (context, tutorialWatchedSnapshot) {
                if (!tutorialWatchedSnapshot.hasData) {
                  return CircularProgressIndicator();
                }
                final tutorialWatched = tutorialWatchedSnapshot.data!;

                return ChannelAddMembers(
                  channel: channel,
                  teammateNameDisplay: teammateNameDisplay,
                  tutorialWatched: tutorialWatched,
                );
              },
            );
          },
        );
      },
    );
  }
}
