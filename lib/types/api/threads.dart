// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/foundation.dart';
import 'package:mattermost_flutter/models/user_profile.dart';
import 'package:mattermost_flutter/models/post.dart';

class Thread {
  final String id;
  final int reply_count;
  final int last_reply_at;
  final int last_viewed_at;
  final List<UserProfile> participants;
  final Post post;
  final bool is_following;
  final int unread_replies;
  final int unread_mentions;
  final int delete_at;

  Thread(
      {required this.id,
      required this.reply_count,
      required this.last_reply_at,
      required this.last_viewed_at,
      required this.participants,
      this.post,
      required this.is_following,
      required this.unread_replies,
      required this.unread_mentions,
      required this.delete_at});
}

class ThreadWithLastFetchedAt extends Thread {
  final int lastFetchedAt;

  ThreadWithLastFetchedAt(
      {required String id,
      required int reply_count,
      required int last_reply_at,
      required int last_viewed_at,
      required List<UserProfile> participants,
      Post post,
      bool is_following,
      int unread_replies,
      int unread_mentions,
      int delete_at,
      this.lastFetchedAt})
      : super(
            id: id,
            reply_count: reply_count,
            last_reply_at: last_reply_at,
            last_viewed_at: last_viewed_at,
            participants: participants,
            post: post,
            is_following: is_following,
            unread_replies: unread_replies,
            unread_mentions: unread_mentions,
            delete_at: delete_at);
}

class ThreadWithViewedAt extends Thread {
  final int viewed_at;

  ThreadWithViewedAt(
      {String id,
      int reply_count,
      int last_reply_at,
      int last_viewed_at,
      List<UserProfile> participants,
      Post post,
      bool is_following,
      int unread_replies,
      int unread_mentions,
      int delete_at,
      this.viewed_at})
      : super(
            id: id,
            reply_count: reply_count,
            last_reply_at: last_reply_at,
            last_viewed_at: last_viewed_at,
            participants: participants,
            post: post,
            is_following: is_following,
            unread_replies: unread_replies,
            unread_mentions: unread_mentions,
            delete_at: delete_at);
}

class ThreadParticipant {
  final String id;
  final String thread_id;

  ThreadParticipant({this.id, this.thread_id});
}

class GetUserThreadsResponse {
  final List<Thread> threads;
  final int total;
  final int total_unread_mentions;
  final int total_unread_threads;

  GetUserThreadsResponse(
      {this.threads,
      this.total,
      this.total_unread_mentions,
      this.total_unread_threads});
}
