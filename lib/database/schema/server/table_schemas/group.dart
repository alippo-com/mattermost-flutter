// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:watermelondb/watermelondb.dart';
import 'package:mattermost_flutter/constants/database.dart';

final groupTableSchema = TableSchema(
  name: MM_TABLES.SERVER.GROUP,
  columns: [
    Column(name: 'display_name', type: ColumnType.string),
    Column(name: 'name', type: ColumnType.string, isIndexed: true),
    Column(name: 'description', type: ColumnType.string),
    Column(name: 'source', type: ColumnType.string),
    Column(name: 'remote_id', type: ColumnType.string, isIndexed: true),
    Column(name: 'created_at', type: ColumnType.number),
    Column(name: 'updated_at', type: ColumnType.number),
    Column(name: 'deleted_at', type: ColumnType.number),
    Column(name: 'member_count', type: ColumnType.number),
  ],
);