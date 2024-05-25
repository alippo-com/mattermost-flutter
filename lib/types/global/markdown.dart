
// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:watermelondb/watermelondb.dart';
import '../../types/constants/database.dart';

final Map<String, String> MM_TABLES = {
  'INFO': 'info',
  'GLOBAL': 'global',
  'SERVERS': 'servers'
};

class AppSchema {
  final int version;
  final List<TableSchema> tables;

  AppSchema({required this.version, required this.tables});
}

class TableSchema {
  final String name;
  final List<ColumnSchema> columns;

  TableSchema({required this.name, required this.columns});
}

class ColumnSchema {
  final String name;
  final String type;
  final bool isIndexed;

  ColumnSchema({required this.name, required this.type, this.isIndexed = false});
}

final AppSchema schema = AppSchema(
  version: 1,
  tables: [
    TableSchema(
      name: MM_TABLES['INFO']!,
      columns: [
        ColumnSchema(name: 'build_number', type: 'string'),
        ColumnSchema(name: 'created_at', type: 'number'),
        ColumnSchema(name: 'version_number', type: 'string'),
      ],
    ),
    TableSchema(
      name: MM_TABLES['GLOBAL']!,
      columns: [
        ColumnSchema(name: 'value', type: 'string'),
      ],
    ),
    TableSchema(
      name: MM_TABLES['SERVERS']!,
      columns: [
        ColumnSchema(name: 'db_path', type: 'string'),
        ColumnSchema(name: 'display_name', type: 'string'),
        ColumnSchema(name: 'identifier', type: 'string', isIndexed: true),
        ColumnSchema(name: 'last_active_at', type: 'number', isIndexed: true),
        ColumnSchema(name: 'url', type: 'string', isIndexed: true),
      ],
    ),
  ],
);
