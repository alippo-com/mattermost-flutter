// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:watermelondb/watermelondb.dart';
import '../../../../../constants.dart'; // Assuming constants.dart contains the MM_TABLES definition

final groupTeam = MM_TABLES['SERVER']['GROUP_TEAM'];

class GroupTeamSchema extends TableSchema {
  @override
  String get name => groupTeam;

  @override
  List<ColumnSchema> get columns => [
        ColumnSchema(
            name: 'group_id', type: ColumnType.string, isIndexed: true),
        ColumnSchema(name: 'team_id', type: ColumnType.string, isIndexed: true),
        ColumnSchema(name: 'created_at', type: ColumnType.integer),
        ColumnSchema(name: 'updated_at', type: ColumnType.integer),
        ColumnSchema(name: 'deleted_at', type: ColumnType.integer),
      ];
}
