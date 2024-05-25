// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:watermelondb/watermelondb.dart';
import 'package:mattermost_flutter/types/constants.dart';

final String postsInChannel = MMTables.server.postsInChannel;

class PostsInChannelSchema extends TableSchema {
  @override
  String get name => postsInChannel;

  @override
  List<ColumnSchema> get columns => [
        ColumnSchema(name: 'channel_id', type: ColumnType.text, isIndexed: true),
        ColumnSchema(name: 'earliest', type: ColumnType.integer),
        ColumnSchema(name: 'latest', type: ColumnType.integer),
      ];
}