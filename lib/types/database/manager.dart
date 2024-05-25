// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:mattermost_flutter/types/database/database.dart';

typedef Future<void> UpdateServerIdentifier(String serverUrl, String identifier, {String? displayName});
typedef Future<void> UpdateServerDisplayName(String serverUrl, String displayName);
typedef Future<bool> IsServerPresent(String serverUrl);
typedef Future<String?> GetActiveServerUrl();
typedef Future<String?> GetActiveServerDisplayName();
typedef Future<String?> GetServerUrlFromIdentifier(String identifier);
typedef Future<Database?> GetActiveServerDatabase();
typedef AppDatabase? GetAppDatabaseAndOperator();
typedef ServerDatabase? GetServerDatabaseAndOperator(String serverUrl);
typedef Future<void> SetActiveServerDatabase(String serverUrl);
typedef Future<void> DeleteServerDatabase(String serverUrl);
typedef Future<void> DestroyServerDatabase(String serverUrl);
typedef Future<void> DeleteServerDatabaseFiles(String serverUrl);
typedef Future<void> DeleteServerDatabaseFilesByName(String databaseName);
typedef Future<void> RenameDatabase(String databaseName, String newDBName);
typedef Future<bool> FactoryReset(bool shouldRemoveDirectory);
typedef String GetDatabaseFilePath(String dbName);
typedef String? SearchUrl(String toFind);

class DatabaseManager {
  final ServerDatabases serverDatabases;

  DatabaseManager({
    required this.serverDatabases,
    required this.updateServerIdentifier,
    required this.updateServerDisplayName,
    required this.isServerPresent,
    required this.getActiveServerUrl,
    required this.getActiveServerDisplayName,
    required this.getServerUrlFromIdentifier,
    required this.getActiveServerDatabase,
    required this.getAppDatabaseAndOperator,
    required this.getServerDatabaseAndOperator,
    required this.setActiveServerDatabase,
    required this.deleteServerDatabase,
    required this.destroyServerDatabase,
    required this.deleteServerDatabaseFiles,
    required this.deleteServerDatabaseFilesByName,
    required this.renameDatabase,
    required this.factoryReset,
    required this.getDatabaseFilePath,
    required this.searchUrl,
  });

  final UpdateServerIdentifier updateServerIdentifier;
  final UpdateServerDisplayName updateServerDisplayName;
  final IsServerPresent isServerPresent;
  final GetActiveServerUrl getActiveServerUrl;
  final GetActiveServerDisplayName getActiveServerDisplayName;
  final GetServerUrlFromIdentifier getServerUrlFromIdentifier;
  final GetActiveServerDatabase getActiveServerDatabase;
  final GetAppDatabaseAndOperator getAppDatabaseAndOperator;
  final GetServerDatabaseAndOperator getServerDatabaseAndOperator;
  final SetActiveServerDatabase setActiveServerDatabase;
  final DeleteServerDatabase deleteServerDatabase;
  final DestroyServerDatabase destroyServerDatabase;
  final DeleteServerDatabaseFiles deleteServerDatabaseFiles;
  final DeleteServerDatabaseFilesByName deleteServerDatabaseFilesByName;
  final RenameDatabase renameDatabase;
  final FactoryReset factoryReset;
  final GetDatabaseFilePath getDatabaseFilePath;
  final SearchUrl searchUrl;
}
