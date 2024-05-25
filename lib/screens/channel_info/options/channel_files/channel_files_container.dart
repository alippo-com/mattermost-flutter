import 'package:flutter/material.dart';
import 'package:mattermost_flutter/database/with_database.dart';
import 'package:mattermost_flutter/database/with_observables.dart';
import 'package:rxdart/rxdart.dart';

import 'package:mattermost_flutter/queries/servers/channel.dart';
import 'package:mattermost_flutter/screens/channel_info/options/channel_files/channel_files.dart';
import 'package:mattermost_flutter/types/database/database.dart';

class ChannelFilesContainer extends StatelessWidget {
  final String channelId;

  ChannelFilesContainer({required this.channelId});

  @override
  Widget build(BuildContext context) {
    return withDatabase(
      builder: (context, database) {
        final channel = observeChannel(database, channelId);
        final info = observeChannelInfo(database, channelId);
        final countStream = info.switchMap((i) => Stream.value(i?.filesCount ?? 0));
        final displayNameStream = channel.switchMap((c) => Stream.value(c?.displayName));

        return StreamBuilder(
          stream: Rx.combineLatest2(displayNameStream, countStream, (displayName, count) => {
            'displayName': displayName,
            'count': count,
          }),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return CircularProgressIndicator();
            }

            final data = snapshot.data as Map<String, dynamic>;
            final displayName = data['displayName'];
            final count = data['count'];

            return ChannelFiles(
              displayName: displayName,
              count: count,
            );
          },
        );
      },
    );
  }
}
