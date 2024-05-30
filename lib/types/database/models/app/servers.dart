// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:watermelondb/watermelondb.dart'; // Assuming an equivalent WatermelonDB package for Dart
import 'package:mattermost_flutter/constants/database.dart';
// Adjust this import based on the actual structure

class ServersModel extends DatabaseModel implements ServersModelInterface {
  static const String tableName = MM_TABLES.APP.SERVERS;

  @Field('db_path')
  late final String dbPath;

  @Field('display_name')
  late final String displayName;

  @Field('url')
  late final String url;

  @Field('last_active_at')
  late final int lastActiveAt;

  @Field('identifier')
  late final String identifier;

  ServersModel({
    required this.dbPath,
    required this.displayName,
    required this.url,
    required this.lastActiveAt,
    required this.identifier,
  });

  @override
  String get table => tableName;
}
