// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:moment/moment.dart';

import 'package:mattermost_flutter/components/join_call_banner/join_call_banner.dart';
import 'package:mattermost_flutter/observers/calls.dart';
import 'package:mattermost_flutter/state/calls.dart';
import 'package:mattermost_flutter/utils/calls.dart';
import 'package:mattermost_flutter/queries/servers/user.dart';
import 'package:mattermost_flutter/types/database/database.dart';

class EnhancedJoinCallBanner extends StatelessWidget {
  final String serverUrl;
  final String channelId;

  const EnhancedJoinCallBanner({
    required this.serverUrl,
    required this.channelId,
  });

  @override
  Widget build(BuildContext context) {
    final database = BehaviorSubject<Database?>.seeded(DatabaseManager.serverDatabases[serverUrl]?.database);

    final callsState = observeCallsState(serverUrl).switchMap((state) => Stream.value(state.calls[channelId]));
    final userModels = callsState
        .distinctUntilChanged((prev, curr) => prev?.sessions == curr?.sessions)
        .switchMap((call) => call != null ? Stream.value(userIds(call.sessions.values.toList())) : Stream.value([]))
        .distinctUntilChanged((prev, curr) => idsAreEqual(prev, curr))
        .switchMap((ids) => ids.isNotEmpty ? queryUsersById(database, ids).observeWithColumns(['last_picture_update']) : Stream.value([]));
    
    final channelCallStartTime = callsState
        .switchMap((state) => Stream.value(state != null && state.startTime != null ? state.startTime : Moment.now()))
        .distinctUntilChanged();

    final callId = callsState.switchMap((state) => Stream.value(state?.id ?? ''));

    final limitRestrictedInfo = observeIsCallLimitRestricted(database, serverUrl, channelId);

    return StreamBuilder(
      stream: Rx.combineLatest4(
        callId,
        userModels,
        channelCallStartTime,
        limitRestrictedInfo,
        (callId, userModels, channelCallStartTime, limitRestrictedInfo) => {
          'callId': callId,
          'userModels': userModels,
          'channelCallStartTime': channelCallStartTime,
          'limitRestrictedInfo': limitRestrictedInfo,
        },
      ),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return CircularProgressIndicator();
        }

        final data = snapshot.data as Map<String, dynamic>;

        return JoinCallBanner(
          callId: data['callId'],
          userModels: data['userModels'],
          channelCallStartTime: data['channelCallStartTime'],
          limitRestrictedInfo: data['limitRestrictedInfo'],
        );
      },
    );
  }
}
