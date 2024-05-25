// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:mattermost_flutter/types/constants.dart';
import 'package:watermelondb/watermelondb.dart';

final String tableName = MM_TABLES.SERVER.GROUP_MEMBERSHIP;

class GroupMembershipSchema extends TableSchema {
  @override
  String get name => tableName;

  @override
  List<ColumnSchema> get columns => [
        ColumnSchema(name: 'group_id', type: ColumnType.text, isIndexed: true),
        ColumnSchema(name: 'user_id', type: ColumnType.text, isIndexed: true),
        ColumnSchema(name: 'created_at', type: ColumnType.integer),
        ColumnSchema(name: 'updated_at', type: ColumnType.integer),
        ColumnSchema(name: 'deleted_at', type: ColumnType.integer),
      ];
}