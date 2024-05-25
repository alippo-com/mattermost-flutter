// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

/// Dart representation of WebsocketBroadcast used in Mattermost.
class WebsocketBroadcast {
  final Map<String, bool> omitUsers;
  final String userId;
  final String channelId;
  final String teamId;

  WebsocketBroadcast({
    required this.omitUsers,
    required this.userId,
    required this.channelId,
    required this.teamId,
  });
}

/// Dart representation of WebSocketMessage used in Mattermost.
class WebSocketMessage<T> {
  final String event;
  final T data;
  final WebsocketBroadcast broadcast;
  final int seq;

  WebSocketMessage({
    required this.event,
    required this.data,
    required this.broadcast,
    required this.seq,
  });
}

/// Dart representation of ThreadReadChangedData used in Mattermost.
class ThreadReadChangedData {
  final String threadId;
  final int timestamp;
  final int unreadMentions;
  final int unreadReplies;

  ThreadReadChangedData({
    required this.threadId,
    required this.timestamp,
    required this.unreadMentions,
    required this.unreadReplies,
  });
}
