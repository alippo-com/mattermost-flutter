// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:watermelondb/watermelondb.dart';
import 'package:flutter/foundation.dart';
import 'dart:io' show Platform;

import 'package:mattermost_flutter/constants/database.dart';
import 'package:mattermost_flutter/utils/mattermost_managed.dart';
import 'package:mattermost_flutter/database/manager/index.dart';

import 'package:mattermost_flutter/types/database/models/app/servers.dart';

Future<void> testManual() async {
  await DatabaseManager.init([]);

  // Test: It should return the iOS App-Group shared directory
  void testAppGroupDirectory() {
    if (Platform.isIOS) {
      getIOSAppGroupDetails();
    }
  }

  // Test: It should return the app database
  Database? testGetAppDatabase() {
    return DatabaseManager.appDatabase?.database;
  }

  // Test: It should creates a new server connection
  Future<void> testNewServerConnection() async {
    await DatabaseManager.createServerDatabase(
      config: {
        'dbName': 'community mattermost',
        'dbType': DatabaseType.SERVER,
        'serverUrl': 'https://comm4.mattermost.com',
        'identifier': 'test-server',
      },
    );
  }

  // Test: It should return the current active server database
  Future<Database?> testGetActiveServerConnection() async {
    return DatabaseManager.getActiveServerDatabase();
  }

  // Test: It should set the current active server database to the provided server url.
  Future<void> testSetActiveServerConnection() async {
    await DatabaseManager.setActiveServerDatabase('https://comm4.mattermost.com');
  }

  // Test: It should return database instance(s) if there are valid server urls in the provided list.
  Future<List<ServersModel>> testRetrieveAllDatabaseConnections() async {
    final database = DatabaseManager.appDatabase?.database;
    final servers = await database?.collections
        .get<ServersModel>(MM_TABLES.APP['SERVERS'])
        .query(Q.where(
          'url',
          Q.oneOf([
            'https://xunity2.mattermost.com',
            'https://comm5.mattermost.com',
            'https://comm4.mattermost.com',
          ]),
        ))
        .fetch();
    return servers ?? [];
  }

  // Test: It should delete the associated *.db file for this server url
  Future<void> testDeleteSQLFile() async {
    await DatabaseManager.deleteServerDatabase('https://comm4.mattermost.com');
  }

  // Test: It should wipe out the databases folder under the documents direction on Android and in the shared directory for the AppGroup on iOS
  Future<void> testFactoryReset() async {
    await DatabaseManager.factoryReset(true);
  }

  // NOTE: Comment and test the below functions one at a time. It starts with creating a default database and ends with a factory reset.
  testAppGroupDirectory();
  testGetAppDatabase();
  await testNewServerConnection();
  await testGetActiveServerConnection();
  await testSetActiveServerConnection();
  await testRetrieveAllDatabaseConnections();
  await testDeleteSQLFile();
  await testFactoryReset();
}
