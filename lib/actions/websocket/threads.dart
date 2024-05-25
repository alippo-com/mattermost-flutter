// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:mattermost_flutter/actions/local/thread.dart';
import 'package:mattermost_flutter/database/manager.dart';
import 'package:mattermost_flutter/queries/servers/system.dart';
import 'package:mattermost_flutter/store/ephemeral_store.dart';
import 'dart:convert';

Future<void> handleThreadUpdatedEvent(String serverUrl, WebSocketMessage msg) async {
  try {
    final database = DatabaseManager.getServerDatabaseAndOperator(serverUrl).database;

    final Thread thread = Thread.fromJson(jsonDecode(msg.data['thread']));
    String teamId = msg.broadcast['team_id'] ?? await getCurrentTeamId(database);

    // Mark it as following
    thread.isFollowing = true;
    processReceivedThreads(serverUrl, [thread], teamId);
  } catch (error) {
    // Do nothing
  }
}

Future<void> handleThreadReadChangedEvent(String serverUrl, WebSocketMessage<ThreadReadChangedData> msg) async {
  try {
    final threadId = msg.data['thread_id'];
    final timestamp = msg.data['timestamp'];
    final unreadMentions = msg.data['unread_mentions'];
    final unreadReplies = msg.data['unread_replies'];

    if (threadId != null) {
      final data = ThreadWithViewedAt(
        unreadMentions: unreadMentions,
        unreadReplies: unreadReplies,
        lastViewedAt: timestamp,
      );

      // Do not update viewing data if the user is currently in the same thread
      final isThreadVisible = EphemeralStore.getCurrentThreadId() == threadId;
      if (!isThreadVisible) {
        data.viewedAt = timestamp;
      }

      await updateThread(serverUrl, threadId, data);
    } else {
      await markTeamThreadsAsRead(serverUrl, msg.broadcast['team_id']);
    }
  } catch (error) {
    // Do nothing
  }
}

Future<void> handleThreadFollowChangedEvent(String serverUrl, WebSocketMessage msg) async {
  try {
    final replyCount = msg.data['reply_count'];
    final state = msg.data['state'];
    final threadId = msg.data['thread_id'];

    await updateThread(serverUrl, threadId, {
      'isFollowing': state,
      'replyCount': replyCount,
    });
  } catch (error) {
    // Do nothing
  }
}
