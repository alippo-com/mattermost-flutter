// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:watermelondb/watermelondb.dart';
import 'package:watermelondb/decorators.dart';
import 'package:mattermost_flutter/constants/database.dart';
import 'package:mattermost_flutter/types/post_model.dart';
import 'package:mattermost_flutter/types/thread_model_interface.dart';
import 'package:mattermost_flutter/types/thread_in_team_model.dart';
import 'package:mattermost_flutter/types/thread_participant_model.dart';

/**
 * The Thread model contains thread information of a post.
 */
class ThreadModel extends Model implements ThreadModelInterface {
  /** table (name) : Thread */
  static const tableName = MM_TABLES_SERVER.THREAD;

  /** associations : Describes every relationship to this table. */
  static final associations = {
    /** A THREAD is associated to one POST (relationship is 1:1) */
    MM_TABLES_SERVER.POST: WatermelonDBAssociation(
      type: WatermelonDBAssociationType.belongsTo,
      foreignKey: 'id',
    ),

    /** A THREAD can have multiple THREAD_PARTICIPANT. (relationship is 1:N) */
    MM_TABLES_SERVER.THREAD_PARTICIPANT: WatermelonDBAssociation(
      type: WatermelonDBAssociationType.hasMany,
      foreignKey: 'thread_id',
    ),

    /** A THREAD can have multiple THREADS_IN_TEAM. (relationship is 1:N) */
    MM_TABLES_SERVER.THREADS_IN_TEAM: WatermelonDBAssociation(
      type: WatermelonDBAssociationType.hasMany,
      foreignKey: 'thread_id',
    ),
  };

  /** last_reply_at : The timestamp of when user last replied to the thread. */
  @Field('last_reply_at')
  late final int lastReplyAt;

  /** last_fetched_at : The timestamp when we successfully last fetched post on this thread */
  @Field('last_fetched_at')
  late final int lastFetchedAt;

  /** last_viewed_at : The timestamp of when user last viewed the thread. */
  @Field('last_viewed_at')
  late final int lastViewedAt;

  /** reply_count : The total replies to the thread by all the participants. */
  @Field('reply_count')
  late final int replyCount;

  /** is_following: If user is following the thread or not */
  @Field('is_following')
  late final bool isFollowing;

  /** unread_replies : The number of replies that have not been read by the user. */
  @Field('unread_replies')
  late final int unreadReplies;

  /** unread_mentions : The number of mentions that have not been read by the user. */
  @Field('unread_mentions')
  late final int unreadMentions;

  /** viewed_at : The timestamp showing when the user's last opened this thread (this is used for the new line message indicator) */
  @Field('viewed_at')
  late final int viewedAt;

  /** participants : All the participants associated with this Thread */
  @Children('THREAD_PARTICIPANT')
  late final Future<List<ThreadParticipantModel>> participants;

  /** threadsInTeam : All the threadsInTeam associated with this Thread */
  @Children('THREADS_IN_TEAM')
  late final Future<List<ThreadInTeamModel>> threadsInTeam;

  /** post : The root post of this thread */
  @ImmutableRelation('POST', 'id')
  late final Future<PostModel> post;
}
