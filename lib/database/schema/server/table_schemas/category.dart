// Copyright (c) Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:mattermost_flutter/types/table_schema.dart';
import 'package:mattermost_flutter/constants/database.dart';

const CATEGORY = MM_TABLES.SERVER.CATEGORY;

class CategorySchema extends TableSchema {
  final String name = CATEGORY;
  final List<ColumnSchema> columns = [
    ColumnSchema(name: 'collapsed', type: 'bool'),
    ColumnSchema(name: 'display_name', type: 'String'),
    ColumnSchema(name: 'muted', type: 'bool'),
    ColumnSchema(name: 'sort_order', type: 'int'),
    ColumnSchema(name: 'sorting', type: 'String'),
    ColumnSchema(name: 'team_id', type: 'String', isIndexed: true),
    ColumnSchema(name: 'type', type: 'String'),
  ];
}
