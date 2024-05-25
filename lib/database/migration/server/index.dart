// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

// NOTE: To implement migration, please follow this document
// https://nozbe.github.io/WatermelonDB/Advanced/Migrations.html

import 'package:mattermost_flutter/types/watermelondb/schema/migrations.dart';
import 'package:mattermost_flutter/database/constants.dart';

final Map<String, String> serverTables = Constants.MM_TABLES_SERVER;

class Migration {
  static final schemaMigrations = SchemaMigrations(migrations: [
    MigrationItem(
      toVersion: 3,
      steps: [
        AddColumns(
          table: serverTables['POST'],
          columns: [
            ColumnSchema(name: 'message_source', type: 'string'),
          ],
        ),
      ],
    ),
    MigrationItem(
      toVersion: 2,
      steps: [
        AddColumns(
          table: serverTables['CHANNEL_INFO'],
          columns: [
            ColumnSchema(name: 'files_count', type: 'int'),
          ],
        ),
        AddColumns(
          table: serverTables['DRAFT'],
          columns: [
            ColumnSchema(name: 'metadata', type: 'string', isOptional: true),
          ],
        ),
      ],
    ),
  ]);
}