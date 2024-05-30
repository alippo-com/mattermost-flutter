// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:mattermost_flutter/queries/servers/channel.dart';
import 'package:mattermost_flutter/queries/servers/user.dart';
import 'package:mattermost_flutter/types/database/models/servers/post.dart';

class EnhancedAddMembers extends StatelessWidget {
  final PostModel post;

  const EnhancedAddMembers({Key? key, required this.post}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final database = Provider.of<Database>(context, listen: false);

    return StreamBuilder<Map<String, dynamic>>(
      stream: _enhanceStream(database, post),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return CircularProgressIndicator();
        }

        final data = snapshot.data!;
        return AddMembers(
          currentUser: data['currentUser'],
          channelType: data['channelType'],
        );
      },
    );
  }

  Stream<Map<String, dynamic>> _enhanceStream(Database database, PostModel post) {
    final currentUserStream = observeCurrentUser(database);
    final channelTypeStream = observeChannel(database, post.channelId).switchMap(
      (channel) => channel != null ? Stream.value(channel.type) : Stream.value(null),
    );

    return Rx.combineLatest2(
      currentUserStream,
      channelTypeStream,
      (currentUser, channelType) => {
        'currentUser': currentUser,
        'channelType': channelType,
      },
    );
  }
}
