// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:mattermost_flutter/database/database.dart';
import 'package:mattermost_flutter/queries/channel.dart';
import 'package:mattermost_flutter/queries/system.dart';
import 'package:mattermost_flutter/queries/user.dart';
import 'package:mattermost_flutter/utils/user.dart';
import 'package:rxdart/rxdart.dart';

import 'direct_message.dart';

class DirectMessageContainer extends StatelessWidget {
  final String channelId;
  final Database database;

  DirectMessageContainer({required this.channelId, required this.database});

  @override
  Widget build(BuildContext context) {
    final currentUserId = observeCurrentUserId(database);
    final channel = observeChannel(database, channelId);
    final user = currentUserId.switchMap((uId) {
      return channel.switchMap((ch) {
        if (ch == null) {
          return Stream.value(null);
        }
        final otherUserId = getUserIdFromChannelName(uId, ch.name);
        return observeUser(database, otherUserId);
      });
    });

    final hideGuestTags = observeConfigBooleanValue(database, 'HideGuestTags');

    return DirectMessage(
      currentUserId: currentUserId,
      user: user,
      hideGuestTags: hideGuestTags,
    );
  }
}
