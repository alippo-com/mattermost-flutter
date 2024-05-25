// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:watermelondb/watermelondb.dart';
import 'constants.dart';

final String postsInThread = MMTables.server['POSTS_IN_THREAD'];

class PostsInThreadSchema extends TableSchema {
  @override
  String get name => postsInThread;

  @override
  List<ColumnSchema> get columns => [
        ColumnSchema(name: 'earliest', type: ColumnType.integer),
        ColumnSchema(name: 'latest', type: ColumnType.integer),
        ColumnSchema(name: 'root_id', type: ColumnType.text, isIndexed: true),
      ];
}