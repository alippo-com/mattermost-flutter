// Copyright (c) 1995-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:sqflite/sqflite.dart';
import 'package:mattermost_flutter/types/table_constants.dart';

final String tableCustomEmoji = MM_TABLES['SERVER']['CUSTOM_EMOJI'];

class CustomEmoji {
  static final String tableName = tableCustomEmoji;
  static final String columnName = 'name';
  static final String columnType = 'TEXT';

  static void createTable(Database db) {
    db.execute(
      'CREATE TABLE IF NOT EXISTS $tableName ('\n      '$columnName $columnType PRIMARY KEY)'
    );
  }
}