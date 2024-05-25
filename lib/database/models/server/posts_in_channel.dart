// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:watermelondb/watermelondb.dart';
import 'package:watermelondb/decorators.dart';
import 'package:mattermost_flutter/constants/database.dart';
import 'package:mattermost_flutter/types/database/models/servers/channel.dart';
import 'package:mattermost_flutter/types/database/models/servers/posts_in_channel.dart';

const CHANNEL = MM_TABLES.SERVER['CHANNEL'];
const POSTS_IN_CHANNEL = MM_TABLES.SERVER['POSTS_IN_CHANNEL'];

/**
 * PostsInChannel model helps us to combine adjacent posts together without leaving
 * gaps in between for an efficient user reading experience of posts.
 */
class PostsInChannelModel extends Model with PostsInChannelModelInterface {
  /** table (name) : PostsInChannel */
  static final String tableName = POSTS_IN_CHANNEL;

  /** associations : Describes every relationship to this table. */
  static final Map<String, Association> associations = {
    /** A CHANNEL can have multiple POSTS_IN_CHANNEL. (relationship is 1:N) */
    CHANNEL: Association(type: AssociationType.belongsTo, key: 'channel_id'),
  };

  /** channel_id: Associated channel identifier */
  @Field('channel_id')
  late String channelId;

  /** earliest : The earliest timestamp of the post in that channel  */
  @Field('earliest')
  late int earliest;

  /** latest : The latest timestamp of the post in that channel  */
  @Field('latest')
  late int latest;

  /** channel : The parent record of the channel for those posts */
  @ImmutableRelation(CHANNEL, 'channel_id')
  late Relation<ChannelModel> channel;
}
