
// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:mattermost_flutter/types/constants.dart';

class MyChannel {
  static const String tableName = MM_TABLES.SERVER.MY_CHANNEL;

  bool isUnread;
  int lastPostAt;
  int lastViewedAt;
  bool manuallyUnread;
  int mentionsCount;
  int messageCount;
  String roles;
  int viewedAt;
  int lastFetchedAt;

  MyChannel({
    this.isUnread,
    this.lastPostAt,
    this.lastViewedAt,
    this.manuallyUnread,
    this.mentionsCount,
    this.messageCount,
    this.roles,
    this.viewedAt,
    this.lastFetchedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'is_unread': isUnread,
      'last_post_at': lastPostAt,
      'last_viewed_at': lastViewedAt,
      'manually_unread': manuallyUnread,
      'mentions_count': mentionsCount,
      'message_count': messageCount,
      'roles': roles,
      'viewed_at': viewedAt,
      'last_fetched_at': lastFetchedAt,
    };
  }
}
