// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:watermelondb/watermelondb.dart';
import 'package:mattermost_flutter/types/database/models/servers/post.dart';
import 'package:mattermost_flutter/types/database/models/servers/thread_in_team.dart';
import 'package:mattermost_flutter/types/database/models/servers/thread_participant.dart';

/**
 * The Thread model contains thread information of a post.
 */
class ThreadModel extends Model {
  /** table (name) : Thread */
  static final String table = 'thread';

  /** associations : Describes every relationship to this table. */
  static final Associations associations = {
    'posts': Post(),
    'threadsInTeam': ThreadInTeam(),
    'participants': ThreadParticipant(),
  };

  /** lastReplyAt : The timestamp of when user last replied to the thread. */
  int lastReplyAt;

  /** lastFetchedAt : The timestamp when we successfully last fetched post on this channel */
  int lastFetchedAt;

  /** lastViewedAt : The timestamp of when user last viewed the thread. */
  int lastViewedAt;

  /** replyCount : The total replies to the thread by all the participants. */
  int replyCount;

  /** isFollowing: If user is following this thread or not */
  bool isFollowing;

  /** unreadReplies : The number of replies that are not read by the user. */
  int unreadReplies;

  /** unreadMentions : The number of mentions that are not read by the user. */
  int unreadMentions;

  /** viewedAt : The timestamp showing when the user's last opened this thread (this is used for the new line message indicator) */
  int viewedAt;

  /** participants: All the participants of the thread */
  Query<ThreadParticipantModel> participants;

  /** threadsInTeam : All the threadsInTeam associated with this Thread */
  Query<ThreadInTeamModel> threadsInTeam;

  /** post : Query returning the post data for the current thread */
  Relation<PostModel> post;

  ThreadModel({
    required this.lastReplyAt,
    required this.lastFetchedAt,
    required this.lastViewedAt,
    required this.replyCount,
    required this.isFollowing,
    required this.unreadReplies,
    required this.unreadMentions,
    required this.viewedAt,
    required this.participants,
    required this.threadsInTeam,
    required this.post,
  });
}
