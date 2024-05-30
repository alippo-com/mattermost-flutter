import 'package:flutter/material.dart';
import 'package:mattermost_flutter/database/with_database.dart';
import 'package:mattermost_flutter/database/with_observables.dart';
import 'package:rxdart/rxdart.dart';

import 'package:mattermost_flutter/queries/servers/channel.dart';

class MembersContainer extends StatelessWidget {
  final String channelId;

  MembersContainer({required this.channelId});

  @override
  Widget build(BuildContext context) {
    return withDatabase(
      builder: (context, database) {
        final info = observeChannelInfo(database, channelId);
        final displayNameStream = observeChannel(database, channelId).switchMap((c) => Stream.value(c?.displayName));
        final countStream = info.switchMap((i) => Stream.value(i?.memberCount ?? 0));

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

            return Members(
              displayName: displayName,
              count: count,
            );
          },
        );
      },
    );
  }
}
