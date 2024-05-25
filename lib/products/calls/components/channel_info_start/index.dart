// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:watermelondb/watermelondb.dart';
import 'package:rxdart/rxdart.dart';
import 'package:flutter/material.dart';
import 'package:mattermost_flutter/calls/components/channel_info_start/channel_info_start_button.dart';
import 'package:mattermost_flutter/calls/observers.dart';
import 'package:mattermost_flutter/calls/state.dart';
import 'package:mattermost_flutter/types/database/database.dart';

class ChannelInfoStart extends StatelessWidget {
  final String serverUrl;
  final String channelId;
  final Database database;

  ChannelInfoStart({
    required this.serverUrl,
    required this.channelId,
    required this.database,
  });

  @override
  Widget build(BuildContext context) {
    final isACallInCurrentChannel = observeChannelsWithCalls(serverUrl)
        .switchMap((calls) => Observable.just(calls.containsKey(channelId)))
        .distinct()
        .asBroadcastStream();

    final ccChannelId = observeCurrentCall()
        .switchMap((call) => Observable.just(call?.channelId))
        .distinct()
        .asBroadcastStream();

    final confirmToJoin = ccChannelId.switchMap((ccId) => Observable.just(ccId != null && ccId != channelId)).asBroadcastStream();
    final alreadyInCall = ccChannelId.switchMap((ccId) => Observable.just(ccId != null && ccId == channelId)).asBroadcastStream();

    final limitRestrictedInfo = observeIsCallLimitRestricted(database, serverUrl, channelId).asBroadcastStream();

    return StreamBuilder(
      stream: CombineLatestStream.list([isACallInCurrentChannel, confirmToJoin, alreadyInCall, limitRestrictedInfo]),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return CircularProgressIndicator();
        }

        final data = snapshot.data as List;
        return ChannelInfoStartButton(
          isACallInCurrentChannel: data[0],
          confirmToJoin: data[1],
          alreadyInCall: data[2],
          limitRestrictedInfo: data[3],
        );
      },
    );
  }
}
