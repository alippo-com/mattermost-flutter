// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:watermelondb/watermelondb.dart';
import 'package:watermelondb/relations.dart';
import 'package:mattermost_flutter/types/post.dart';
import 'package:mattermost_flutter/types/user.dart';

/**
 * The Reaction Model is used to present the reactions a user had on a particular post
 */
class ReactionModel extends Model {
  /** table (name) : Reaction */
  static const String table = 'reactions';

  /** associations : Describes every relationship to this table. */
  static final Map<String, Associations> associations = {
    'posts': Associations.belongsTo('posts', 'post_id'),
    'users': Associations.belongsTo('users', 'user_id'),
  };

  /** create_at : Creation timestamp used for sorting reactions amongst users on a particular post */
  final int createAt;

  /** emoji_name : The emoticon used to express the reaction */
  final String emojiName;

  /** post_id : The related Post's foreign key on which this reaction was expressed */
  final String postId;

  /** user_id : The related User's foreign key by which this reaction was expressed */
  final String userId;

  /** user : The related record to the User model */
  Relation<UserModel> get user => relation('user_id');

  /** post : The related record to the Post model */
  Relation<PostModel> get post => relation('post_id');

  ReactionModel({
    required this.createAt,
    required this.emojiName,
    required this.postId,
    required this.userId,
  });
}
