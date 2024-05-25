// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

// Assuming DatabaseType and DatabaseManager are properly converted and placed in Dart equivalents.
import 'package:mattermost_flutter/constants/database.dart';
import 'package:mattermost_flutter/database/manager.dart';

Future<Database?> createTestConnection({String databaseName = 'db_name', bool setActive = false}) async {
  final String serverUrl = 'https://appv2.mattermost.com';
  await DatabaseManager.init([]);
  Database? server = await DatabaseManager.createServerDatabase(
    config: DatabaseConfig(
      dbName: databaseName,
      dbType: DatabaseType.server,
      serverUrl: serverUrl,
    ),
  );

  if (setActive && server != null) {
    await DatabaseManager.setActiveServerDatabase(serverUrl);
  }

  return server?.database;
}