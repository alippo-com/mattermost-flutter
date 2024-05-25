// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:watermelondb/watermelondb.dart';
import 'package:watermelondb/Relation.dart';
import 'package:mattermost_flutter/types/database/models/servers/channel.dart';
import 'package:mattermost_flutter/types/database/models/servers/my_channel_settings.dart';

/**
 * PostsInChannel model helps us to combine adjacent posts together without leaving
 * gaps in between for an efficient user reading experience of posts.
 */
class PostsInChannelModel extends Model {
  static final String table = 'PostsInChannel';

  String channelId;
  int earliest;
  int latest;
  Relation<ChannelModel> channel;

  PostsInChannelModel({
    required this.channelId,
    required this.earliest,
    required this.latest,
    required this.channel,
  });

  static final Map<String, dynamic> associations = {
    // Define associations if needed
  };
}
