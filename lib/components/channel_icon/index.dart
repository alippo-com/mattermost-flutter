// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mattermost_flutter/queries/servers/user.dart';
import 'dm_avatar.dart';

class ChannelIcon extends StatelessWidget {
  final String channelName;

  ChannelIcon({required this.channelName});

  @override
  Widget build(BuildContext context) {
    final database = Provider.of<Database>(context);

    final currentUserId = observeCurrentUserId(database);

    final authorId = currentUserId.flatMap((userId) => 
      Observable.just(getUserIdFromChannelName(userId, channelName))
    );

    final author = authorId.flatMap((id) => observeUser(database, id));

    return StreamBuilder(
      stream: author,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return DmAvatar(user: snapshot.data);
        } else {
          return CircularProgressIndicator();
        }
      },
    );
  }
}
