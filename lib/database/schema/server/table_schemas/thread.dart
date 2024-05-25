// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:mattermost_flutter/types/table_schema.dart';
import 'package:mattermost_flutter/constants/database.dart';

const String THREAD = MM_TABLES.SERVER.THREAD;

final tableSchemaSpec = TableSchemaSpec(
  name: THREAD,
  columns: [
    Column(name: 'is_following', type: ColumnType.boolean),
    Column(name: 'last_reply_at', type: ColumnType.number),
    Column(name: 'last_viewed_at', type: ColumnType.number),
    Column(name: 'reply_count', type: ColumnType.number),
    Column(name: 'unread_mentions', type: ColumnType.number),
    Column(name: 'unread_replies', type: ColumnType.number),
    Column(name: 'viewed_at', type: ColumnType.number),
    Column(name: 'last_fetched_at', type: ColumnType.number, isIndexed: true),
  ],
);

final threadTableSchema = tableSchema(tableSchemaSpec);
