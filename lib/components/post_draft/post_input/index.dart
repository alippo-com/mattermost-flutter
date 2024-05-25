
import 'package:flutter/material.dart';
import 'package:mattermost_flutter/database/database.dart';
import 'package:mattermost_flutter/queries/channel.dart';
import 'package:mattermost_flutter/queries/system.dart';
import 'package:mattermost_flutter/components/post_input.dart';

class PostInputContainer extends StatefulWidget {
  final String channelId;

  PostInputContainer({required this.channelId});

  @override
  _PostInputContainerState createState() => _PostInputContainerState();
}

class _PostInputContainerState extends State<PostInputContainer> {
  late Stream<int> timeBetweenUserTypingUpdatesMilliseconds;
  late Stream<bool> enableUserTypingMessage;
  late Stream<int> maxNotificationsPerChannel;
  late Stream<String?> channelDisplayName;
  late Stream<int> membersInChannel;

  @override
  void initState() {
    super.initState();
    final database = DatabaseProvider.of(context);

    timeBetweenUserTypingUpdatesMilliseconds = observeConfigIntValue(database, 'TimeBetweenUserTypingUpdatesMilliseconds');
    enableUserTypingMessage = observeConfigBooleanValue(database, 'EnableUserTypingMessages');
    maxNotificationsPerChannel = observeConfigIntValue(database, 'MaxNotificationsPerChannel');

    final channel = observeChannel(database, widget.channelId);

    channelDisplayName = channel.switchMap((c) => Stream.value(c?.displayName));
    membersInChannel = channel.switchMap((c) =>
      c != null
        ? observeChannelInfo(database, c.id).map((info) => info.memberCount)
        : Stream.value(0)
    ).distinct();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: StreamZip([
        timeBetweenUserTypingUpdatesMilliseconds,
        enableUserTypingMessage,
        maxNotificationsPerChannel,
        channelDisplayName,
        membersInChannel,
      ]),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return CircularProgressIndicator();
        }

        final data = snapshot.data as List;
        return PostInput(
          timeBetweenUserTypingUpdatesMilliseconds: data[0],
          enableUserTypingMessage: data[1],
          maxNotificationsPerChannel: data[2],
          channelDisplayName: data[3],
          membersInChannel: data[4],
        );
      },
    );
  }
}
