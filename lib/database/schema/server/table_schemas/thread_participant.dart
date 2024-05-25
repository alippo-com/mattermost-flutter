// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:mattermost_flutter/types/table_schema.dart';
import 'package:mattermost_flutter/constants/database.dart';

const String THREAD_PARTICIPANT = MM_TABLES.SERVER.THREAD_PARTICIPANT;

final tableSchemaSpec = TableSchemaSpec(
  name: THREAD_PARTICIPANT,
  columns: [
    Column(name: 'thread_id', type: ColumnType.string, isIndexed: true),
    Column(name: 'user_id', type: ColumnType.string, isIndexed: true),
  ],
);

final threadParticipantTableSchema = tableSchema(tableSchemaSpec);
