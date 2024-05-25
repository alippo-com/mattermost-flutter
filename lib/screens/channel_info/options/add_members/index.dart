
import 'package:flutter/material.dart';
import 'package:mattermost_flutter/database/with_database.dart';
import 'package:mattermost_flutter/database/with_observables.dart';
import 'package:rxdart/rxdart.dart';

import 'package:mattermost_flutter/queries/servers/channel.dart';
import 'package:mattermost_flutter/screens/channel_info/options/add_members/add_members.dart';
import 'package:mattermost_flutter/types/database/database.dart';

class AddMembersContainer extends StatelessWidget {
  final String channelId;

  AddMembersContainer({required this.channelId});

  @override
  Widget build(BuildContext context) {
    return withDatabase(
      builder: (context, database) {
        final channel = observeChannel(database, channelId);
        final displayName = channel.switchMap((c) => Stream.value(c?.displayName));

        return StreamBuilder(
          stream: displayName,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return CircularProgressIndicator();
            }

            final displayName = snapshot.data;

            return AddMembers(
              displayName: displayName,
            );
          },
        );
      },
    );
  }
}
