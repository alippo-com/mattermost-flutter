// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:mattermost_flutter/mattermost_flutter.dart';

const String postsInThread = MM_TABLES.SERVER.POSTS_IN_THREAD;

class PostsInThreadSchema extends TableSchema {
  @override
  String get name => postsInThread;

  @override
  List<ColumnSchema> get columns => [
        ColumnSchema(name: 'earliest', type: ColumnType.number),
        ColumnSchema(name: 'latest', type: ColumnType.number),
        ColumnSchema(name: 'root_id', type: ColumnType.string, isIndexed: true),
      ];
}