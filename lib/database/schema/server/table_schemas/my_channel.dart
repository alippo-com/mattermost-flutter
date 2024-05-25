// Copyright (c) 2020-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

// Importing required libraries and files
import 'package:watermelondb/watermelondb.dart';
import 'constants.dart';

// Defining a class for the table schema
class MyChannel {
  static const String tableName = Constants.myChannel;

  static final Schema schema = Schema(
    tableName: tableName,
    columns: [
      SchemaColumn(name: 'is_unread', type: ColumnType.boolean),
      SchemaColumn(name: 'last_post_at', type: ColumnType.integer),
      SchemaColumn(name: 'last_viewed_at', type: ColumnType.integer),
      SchemaColumn(name: 'manually_unread', type: ColumnType.boolean),
      SchemaColumn(name: 'mentions_count', type: ColumnType.integer),
      SchemaColumn(name: 'message_count', type: ColumnType.integer),
      SchemaColumn(name: 'roles', type: ColumnType.text),
      SchemaColumn(name: 'viewed_at', type: ColumnType.integer),
      SchemaColumn(name: 'last_fetched_at', type: ColumnType.integer, isIndexed: true),
    ],
  );
}