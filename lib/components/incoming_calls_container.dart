
// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/material.dart';
import 'package:mattermost_flutter/types/call_notification.dart';
import 'package:mattermost_flutter/components/call_notification.dart';
import 'package:mattermost_flutter/state/use_incoming_calls.dart';

class IncomingCallsContainer extends StatelessWidget {
  final String? channelId;

  IncomingCallsContainer({this.channelId});

  @override
  Widget build(BuildContext context) {
    final incomingCalls = useIncomingCalls().incomingCalls;

    // If we're in the channel for the incoming call, don't show the incoming call banner.
    final calls = incomingCalls.where((ic) => ic.channelID != channelId).toList();
    if (calls.isEmpty) {
      return SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(top: 8, bottom: 8),
      child: Column(
        children: calls.map((ic) => CallNotification(
          key: Key(ic.callID),
          incomingCall: ic,
        )).toList(),
      ),
    );
  }
}
