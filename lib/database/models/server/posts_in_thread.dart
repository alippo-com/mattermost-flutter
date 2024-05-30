// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:watermelondb/watermelondb.dart';
import 'package:watermelondb/decorators.dart';
import 'package:mattermost_flutter/constants/database.dart';
import 'package:mattermost_flutter/types/database/models/servers/post.dart';

const POST = MM_TABLES.SERVER['POST'];
const POSTS_IN_THREAD = MM_TABLES.SERVER['POSTS_IN_THREAD'];

/**
 * PostsInThread model helps us to combine adjacent threads together without leaving
 * gaps in between for an efficient user reading experience for threads.
 */
class PostsInThreadModel extends Model with PostsInThreadModelInterface {
  /** table (name) : PostsInThread */
  static final String tableName = POSTS_IN_THREAD;

  /** associations : Describes every relationship to this table. */
  static final Map<String, Association> associations = {
    POST: Association(type: AssociationType.belongsTo, key: 'root_id'),
  };

  /** root_id: Associated root post identifier */
  @Field('root_id')
  late String rootId;

  /** earliest : Lower bound of a timestamp range */
  @Field('earliest')
  late int earliest;

  /** latest : Upper bound of a timestamp range */
  @Field('latest')
  late int latest;

  /** post : The related record to the parent Post model */
  @ImmutableRelation(POST, 'root_id')
  late Relation<PostModel> post;
}
