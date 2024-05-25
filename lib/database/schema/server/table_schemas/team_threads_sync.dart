
// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:watermelondb/watermelondb.dart';
import 'package:mattermost_flutter/constants/database.dart';

const String TEAM_THREADS_SYNC = MM_TABLES.SERVER['TEAM_THREADS_SYNC'];

final TableSchema tableSchemaSpec = TableSchema(
  name: TEAM_THREADS_SYNC,
  columns: [
    Column(name: 'earliest', type: ColumnType.number),
    Column(name: 'latest', type: ColumnType.number),
  ],
);

final TableSchema tableSchema = tableSchemaSpec;
