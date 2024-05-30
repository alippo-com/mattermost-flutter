import 'package:flutter/material.dart';
import 'package:mattermost_flutter/database/with_database.dart';
import 'package:mattermost_flutter/database/with_observables.dart';
import 'package:rxdart/rxdart.dart';

import 'package:mattermost_flutter/queries/servers/channel.dart';
import 'package:mattermost_flutter/screens/channel_info/options/pinned_messages/pinned_messages.dart';

class PinnedMessagesContainer extends StatelessWidget {
  final String channelId;

  PinnedMessagesContainer({required this.channelId});

  @override
  Widget build(BuildContext context) {
    return withDatabase(
      builder: (context, database) {
        final channel = observeChannel(database, channelId);
        final info = observeChannelInfo(database, channelId);
        final count = info.switchMap((i) => Stream.value(i?.pinnedPostCount ?? 0));
        final displayName = channel.switchMap((c) => Stream.value(c?.displayName));

        return StreamBuilder(
          stream: Rx.combineLatest2(count, displayName, (count, displayName) {
            return {'count': count, 'displayName': displayName};
          }),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return CircularProgressIndicator();
            }

            final data = snapshot.data as Map;
            final count = data['count'];
            final displayName = data['displayName'];

            return PinnedMessages(
              count: count,
              displayName: displayName,
            );
          },
        );
      },
    );
  }
}
