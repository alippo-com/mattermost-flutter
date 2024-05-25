
import 'package:flutter/material.dart';
import 'package:mattermost_flutter/components/group_message.dart';
import 'package:mattermost_flutter/database/observables.dart';
import 'package:mattermost_flutter/queries/channel.dart';
import 'package:mattermost_flutter/queries/system.dart';
import 'package:mattermost_flutter/types.dart';

class GroupMessageScreen extends StatefulWidget {
  final String channelId;

  GroupMessageScreen({required this.channelId});

  @override
  _GroupMessageScreenState createState() => _GroupMessageScreenState();
}

class _GroupMessageScreenState extends State<GroupMessageScreen> {
  late final Stream<String> currentUserIdStream;
  late final Stream<List<ChannelMembershipModel>> membersStream;

  @override
  void initState() {
    super.initState();
    final database = DatabaseProvider.of(context).database;
    currentUserIdStream = observeCurrentUserId(database);
    final channelStream = observeChannel(database, widget.channelId);
    membersStream = channelStream.switchMap((channel) {
      return channel != null
          ? observeChannelMembers(database, widget.channelId)
          : Stream.value([]);
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<String>(
      stream: currentUserIdStream,
      builder: (context, currentUserIdSnapshot) {
        if (!currentUserIdSnapshot.hasData) {
          return CircularProgressIndicator();
        }
        final currentUserId = currentUserIdSnapshot.data!;

        return StreamBuilder<List<ChannelMembershipModel>>(
          stream: membersStream,
          builder: (context, membersSnapshot) {
            if (!membersSnapshot.hasData) {
              return CircularProgressIndicator();
            }
            final members = membersSnapshot.data!;

            return GroupMessage(
              currentUserId: currentUserId,
              members: members,
            );
          },
        );
      },
    );
  }
}
