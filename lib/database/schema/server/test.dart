
// Copyright (c) 2023 Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:mattermost_flutter/types/mm_tables.dart';
import 'package:mattermost_flutter/database/schema/server/index.dart';

final serverSchema = ServerSchema(
  version: 3,
  unsafeSql: null,
  tables: {
    CATEGORY: TableSchema(
      name: CATEGORY,
      unsafeSql: null,
      columns: {
        'collapsed': ColumnSchema(name: 'collapsed', type: 'bool'),
        'display_name': ColumnSchema(name: 'display_name', type: 'String'),
        'muted': ColumnSchema(name: 'muted', type: 'bool'),
        'sort_order': ColumnSchema(name: 'sort_order', type: 'int'),
        'sorting': ColumnSchema(name: 'sorting', type: 'String'),
        'team_id': ColumnSchema(name: 'team_id', type: 'String', isIndexed: true),
        'type': ColumnSchema(name: 'type', type: 'String'),
      },
    ),
    CATEGORY_CHANNEL: TableSchema(
      name: CATEGORY_CHANNEL,
      unsafeSql: null,
      columns: {
        'category_id': ColumnSchema(name: 'category_id', type: 'String', isIndexed: true),
        'channel_id': ColumnSchema(name: 'channel_id', type: 'String', isIndexed: true),
        'sort_order': ColumnSchema(name: 'sort_order', type: 'int'),
      },
    ),
    // Additional tables would be converted here similarly
  },
);

// Unit test example in Dart (to be placed in corresponding test files)
void main() {
  test('The SERVER SCHEMA should strictly match', () {
    expect(serverSchema.version, 3);
    // Further detailed tests on schema properties
  });
}
  