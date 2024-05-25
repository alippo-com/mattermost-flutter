// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:mattermost_flutter/types/table_schema.dart';
import 'package:mattermost_flutter/constants/database.dart';

const String THREADS_IN_TEAM = MM_TABLES.SERVER.THREADS_IN_TEAM;

final tableSchemaSpec = TableSchemaSpec(
  name: THREADS_IN_TEAM,
  columns: [
    Column(name: 'team_id', type: ColumnType.string, isIndexed: true),
    Column(name: 'thread_id', type: ColumnType.string, isIndexed: true),
  ],
);

final threadInTeamTableSchema = tableSchema(tableSchemaSpec);
