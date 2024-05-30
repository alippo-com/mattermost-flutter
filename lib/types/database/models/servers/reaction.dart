// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:watermelondb/watermelondb.dart';
import 'package:watermelondb/decorators.dart';
import 'package:mattermost_flutter/types/database/models/servers/post.dart';

/**
 * The Reaction Model is used to present the reactions a user had on a particular post
 */
class ReactionModel extends Model {
  static String table = "reaction";

  static final Map<String, Association> associations = {
    'post': Association.belongsTo('posts', 'post_id'),
    'user': Association.belongsTo('users', 'user_id'),
  };

  @Field('create_at')
  int createAt;

  @Field('emoji_name')
  String emojiName;

  @Field('post_id')
  String postId;

  @Field('user_id')
  String userId;

  @immutableRelation('users', 'user_id')
  final user = HasOne<UserModel>();

  @immutableRelation('posts', 'post_id')
  final post = HasOne<PostModel>();
}
