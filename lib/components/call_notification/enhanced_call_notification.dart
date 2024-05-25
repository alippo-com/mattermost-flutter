// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

import 'package:mattermost_flutter/queries/app/servers.dart';
import 'package:mattermost_flutter/calls/components/call_notification/call_notification.dart';
import 'package:mattermost_flutter/database/manager.dart';
import 'package:mattermost_flutter/queries/servers/channel.dart';
import 'package:mattermost_flutter/queries/servers/system.dart';
import 'package:mattermost_flutter/queries/servers/user.dart';
import 'package:mattermost_flutter/types/calls.dart';

class EnhancedCallNotification extends StatelessWidget {
  final IncomingCallNotification incomingCall;

  EnhancedCallNotification({required this.incomingCall});

  @override
  Widget build(BuildContext context) {
    final database = BehaviorSubject<Database?>.seeded(DatabaseManager.serverDatabases[incomingCall.serverUrl]?.database);
    final currentUserId = database.switchMap((db) => db != null ? observeCurrentUserId(db) : Stream.value('')).distinct();
    final teammateNameDisplay = database.switchMap((db) => db != null ? observeTeammateNameDisplay(db) : Stream.value('')).distinct();
    final members = database.switchMap((db) => db != null ? observeChannelMembers(db, incomingCall.channelID) : Stream.value([])).distinct();

    return StreamBuilder(
      stream: Rx.combineLatest4(
        observeAllActiveServers(),
        currentUserId,
        teammateNameDisplay,
        members,
        (servers, currentUserId, teammateNameDisplay, members) => {
          'servers': servers,
          'currentUserId': currentUserId,
          'teammateNameDisplay': teammateNameDisplay,
          'members': members,
        },
      ),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return CircularProgressIndicator();
        }

        final data = snapshot.data as Map<String, dynamic>;

        return CallNotification(
          servers: data['servers'],
          currentUserId: data['currentUserId'],
          teammateNameDisplay: data['teammateNameDisplay'],
          members: data['members'],
        );
      },
    );
  }
}
