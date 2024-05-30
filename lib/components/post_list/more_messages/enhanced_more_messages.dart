// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:mattermost_flutter/queries/servers/channel.dart';

class EnhancedMoreMessages extends StatelessWidget {
  final String channelId;
  final bool? isCRTEnabled;
  final String? rootId;

  const EnhancedMoreMessages({
    Key? key,
    required this.channelId,
    this.isCRTEnabled,
    this.rootId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final database = Provider.of<Database>(context, listen: false);

    return StreamBuilder<Map<String, dynamic>>(
      stream: _enhanceStream(database),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return CircularProgressIndicator();
        }

        final data = snapshot.data!;
        return MoreMessages(
          isManualUnread: data['isManualUnread'],
          unreadCount: data['unreadCount'],
        );
      },
    );
  }

  Stream<Map<String, dynamic>> _enhanceStream(Database database) {
    if (isCRTEnabled == true && rootId != null) {
      final threadStream = observeThreadById(database, rootId!);

      final unreadCountStream = threadStream.switchMap(
        (thread) => Stream.value(thread?.unreadReplies),
      );

      return unreadCountStream.map((unreadCount) => {
            'unreadCount': unreadCount,
          });
    }

    final myChannelStream = observeMyChannel(database, channelId);

    final isManualUnreadStream = myChannelStream.switchMap(
      (channel) => Stream.value(channel?.manuallyUnread),
    ).distinct();

    final unreadCountStream = myChannelStream.switchMap(
      (channel) => Stream.value(channel?.messageCount),
    ).distinct();

    return Rx.combineLatest2(
      isManualUnreadStream,
      unreadCountStream,
      (isManualUnread, unreadCount) => {
        'isManualUnread': isManualUnread,
        'unreadCount': unreadCount,
      },
    );
  }
}
