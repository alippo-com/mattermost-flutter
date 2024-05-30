// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/services.dart';
import 'package:rxdart/rxdart.dart';

import 'package:mattermost_flutter/constants/events.dart';
import 'package:mattermost_flutter/utils/datetime.dart';

const int TIME_TO_CLEAR_WEBSOCKET_ACTIONS = toMilliseconds(Duration(seconds: 30));

class EphemeralStore {
  Theme? theme;
  bool creatingChannel = false;
  List<String> creatingDMorGMTeammates = [];

  Set<String> noticeShown = Set<String>();

  Map<String, String?> pushProxyVerification = {};
  Map<String, BehaviorSubject<bool>> canJoinOtherTeams = {};

  Map<String, Set<String>> loadingMessagesForChannel = {};

  Map<String, Map<String, _WebsocketPost?>> websocketEditingPost = {};
  Map<String, Set<String>> websocketRemovingPost = {};

  Set<String> addingTeam = Set<String>();
  Set<String> joiningChannels = Set<String>();
  Set<String> leavingChannels = Set<String>();
  Set<String> archivingChannels = Set<String>();
  Set<String> convertingChannels = Set<String>();
  Set<String> switchingToChannel = Set<String>();
  Set<String> acknowledgingPost = Set<String>();
  Set<String> unacknowledgingPost = Set<String>();
  String currentThreadId = '';
  bool notificationTapped = false;
  bool enablingCRT = false;

  String processingNotification = '';

  void setProcessingNotification(String v) {
    processingNotification = v;
  }

  String getProcessingNotification() {
    return processingNotification;
  }

  void addLoadingMessagesForChannel(String serverUrl, String channelId) {
    loadingMessagesForChannel.putIfAbsent(serverUrl, () => Set<String>());
    EventChannel(Events.LOADING_CHANNEL_POSTS).send({
      'serverUrl': serverUrl,
      'channelId': channelId,
      'value': true
    });
    loadingMessagesForChannel[serverUrl]!.add(channelId);
  }

  void stopLoadingMessagesForChannel(String serverUrl, String channelId) {
    EventChannel(Events.LOADING_CHANNEL_POSTS).send({
      'serverUrl': serverUrl,
      'channelId': channelId,
      'value': false
    });
    loadingMessagesForChannel[serverUrl]?.remove(channelId);
  }

  bool isLoadingMessagesForChannel(String serverUrl, String channelId) {
    return loadingMessagesForChannel[serverUrl]?.contains(channelId) ?? false;
  }

  void addEditingPost(String serverUrl, Post post) {
    if (websocketRemovingPost[serverUrl]?.contains(post.id) ?? false) {
      return;
    }

    var lastEdit = websocketEditingPost[serverUrl]?[post.id];
    if (lastEdit != null && post.editAt < lastEdit.post.updateAt) {
      return;
    }

    websocketEditingPost.putIfAbsent(serverUrl, () => {});
    var serverEditing = websocketEditingPost[serverUrl]!;

    lastEdit?.timeout.cancel();

    final timeout = Future.delayed(Duration(milliseconds: TIME_TO_CLEAR_WEBSOCKET_ACTIONS), () {
      serverEditing.remove(post.id);
    });

    serverEditing[post.id] = _WebsocketPost(post, timeout);
  }

  void addRemovingPost(String serverUrl, String postId) {
    if (websocketRemovingPost[serverUrl]?.contains(postId) ?? false) {
      return;
    }

    if (websocketEditingPost[serverUrl]?[postId] != null) {
      websocketEditingPost[serverUrl]![postId]!.timeout.cancel();
      websocketEditingPost[serverUrl]!.remove(postId);
    }

    websocketRemovingPost.putIfAbsent(serverUrl, () => Set<String>());
    websocketRemovingPost[serverUrl]!.add(postId);

    Future.delayed(Duration(milliseconds: TIME_TO_CLEAR_WEBSOCKET_ACTIONS), () {
      websocketRemovingPost[serverUrl]?.remove(postId);
    });
  }

  WebsocketPost? getLastPostWebsocketEvent(String serverUrl, String postId) {
    if (websocketRemovingPost[serverUrl]?.contains(postId) ?? false) {
      return WebsocketPost(deleted: true, post: null);
    }

    if (websocketEditingPost[serverUrl]?[postId] != null) {
      return WebsocketPost(deleted: false, post: websocketEditingPost[serverUrl]![postId]!.post);
    }

    return null;
  }

  void addArchivingChannel(String channelId) {
    archivingChannels.add(channelId);
  }

  bool isArchivingChannel(String channelId) {
    return archivingChannels.contains(channelId);
  }

  void removeArchivingChannel(String channelId) {
    archivingChannels.remove(channelId);
  }

  // Similar methods for converting, leaving, joining, addingToTeam, pushProxy, etc. ...

  BehaviorSubject<bool> _getCanJoinOtherTeamsSubject(String serverUrl) {
    canJoinOtherTeams.putIfAbsent(serverUrl, () => BehaviorSubject<bool>.seeded(false));
    return canJoinOtherTeams[serverUrl]!;
  }

  Stream<bool> observeCanJoinOtherTeams(String serverUrl) {
    return _getCanJoinOtherTeamsSubject(serverUrl).stream;
  }

  void setCanJoinOtherTeams(String serverUrl, bool value) {
    _getCanJoinOtherTeamsSubject(serverUrl).add(value);
  }

  void setNotificationTapped(bool value) {
    notificationTapped = value;
  }

  bool wasNotificationTapped() {
    return notificationTapped;
  }

  void setAcknowledgingPost(String postId) {
    acknowledgingPost.add(postId);
  }

  void unsetAcknowledgingPost(String postId) {
    acknowledgingPost.remove(postId);
  }

  bool isAcknowledgingPost(String postId) {
    return acknowledgingPost.contains(postId);
  }

  void setUnacknowledgingPost(String postId) {
    unacknowledgingPost.add(postId);
  }

  void unsetUnacknowledgingPost(String postId) {
    unacknowledgingPost.remove(postId);
  }

  bool isUnacknowledgingPost(String postId) {
    return unacknowledgingPost.contains(postId);
  }
}

class _WebsocketPost {
  final Post post;
  final Future timeout;

  _WebsocketPost(this.post, this.timeout);
}

class WebsocketPost {
  final bool deleted;
  final Post? post;

  WebsocketPost({required this.deleted, this.post});
}

class Theme {}
class Post {
  late String id;
  late int editAt;
  late int updateAt;
}
