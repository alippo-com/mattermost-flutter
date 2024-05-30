// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter/material.dart';

import 'app_database_migrations.dart';
import 'server_database_migrations.dart';
import 'app_models.dart';
import 'server_models.dart';
import 'constants.dart';
import 'database_operator.dart';
import 'url_utils.dart';
import 'mattermost_managed.dart';
import 'security_utils.dart';

class DatabaseManager {
  AppDatabase? appDatabase;
  Map<String, ServerDatabase> serverDatabases = {};
  final List<Type> appModels = [InfoModel, GlobalModel, ServersModel];
  final List<Type> serverModels = [
    CategoryModel, CategoryChannelModel, ChannelModel, ChannelInfoModel, ChannelMembershipModel, ConfigModel, CustomEmojiModel, DraftModel, FileModel,
    GroupModel, GroupChannelModel, GroupTeamModel, GroupMembershipModel, MyChannelModel, MyChannelSettingsModel, MyTeamModel,
    PostModel, PostsInChannelModel, PostsInThreadModel, PreferenceModel, ReactionModel, RoleModel,
    SystemModel, TeamModel, TeamChannelHistoryModel, TeamMembershipModel, TeamSearchHistoryModel,
    ThreadModel, ThreadParticipantModel, ThreadInTeamModel, TeamThreadsSyncModel, UserModel,
  ];

  DatabaseManager();

  Future<void> init(List<String> serverUrls) async {
    await createAppDatabase();
    for (final serverUrl in serverUrls) {
      await initServerDatabase(serverUrl);
    }
    appDatabase?.operator.handleInfo({
      'info': [
        {
          'build_number': '123',
          'created_at': DateTime.now().millisecondsSinceEpoch,
          'version_number': '2.0.0',
        }
      ],
      'prepareRecordsOnly': false,
    });
  }

  Future<AppDatabase?> createAppDatabase() async {
    try {
      final databasePath = await getDatabasesPath();
      final path = join(databasePath, APP_DATABASE);

      final database = await openDatabase(
        path,
        version: 1,
        onCreate: (db, version) async {
          await db.execute(appSchema);
        },
        onUpgrade: (db, oldVersion, newVersion) async {
          await db.execute(AppDatabaseMigrations.migrationQuery);
        },
      );

      final operator = AppDataOperator(database);

      appDatabase = AppDatabase(database: database, operator: operator);
      return appDatabase;
    } catch (e) {
      // do nothing
    }
    return null;
  }

  Future<ServerDatabase?> createServerDatabase(CreateServerDatabaseArgs args) async {
    final config = args.config;
    final dbName = config.dbName;
    final displayName = config.displayName ?? dbName;
    final identifier = config.identifier;
    final serverUrl = config.serverUrl;

    if (serverUrl != null) {
      try {
        final databaseFilePath = getDatabaseFilePath(dbName);
        final database = await openDatabase(
          databaseFilePath,
          version: 1,
          onCreate: (db, version) async {
            await db.execute(serverSchema);
          },
          onUpgrade: (db, oldVersion, newVersion) async {
            await db.execute(ServerDatabaseMigrations.migrationQuery);
          },
        );

        await addServerToAppDatabase(
          databaseFilePath: databaseFilePath,
          displayName: displayName,
          identifier: identifier,
          serverUrl: serverUrl,
        );

        final operator = ServerDataOperator(database);
        final serverDatabase = ServerDatabase(database: database, operator: operator);

        serverDatabases[serverUrl] = serverDatabase;
        return serverDatabase;
      } catch (e) {
        // do nothing
      }
    }

    return null;
  }

  Future<void> initServerDatabase(String serverUrl) async {
    await createServerDatabase(CreateServerDatabaseArgs(
      config: ServerDatabaseConfig(
        dbName: urlSafeBase64Encode(serverUrl),
        dbType: DatabaseType.SERVER,
        serverUrl: serverUrl,
      ),
    ));
  }

  Future<void> addServerToAppDatabase({
    required String databaseFilePath,
    required String displayName,
    String identifier = '',
    required String serverUrl,
  }) async {
    try {
      final appDatabase = this.appDatabase?.database;
      if (appDatabase != null) {
        final isServerPresent = await isServerPresent(serverUrl);
        if (!isServerPresent) {
          await appDatabase.transaction((txn) async {
            await txn.insert(SERVERS, {
              'dbPath': databaseFilePath,
              'displayName': displayName,
              'url': serverUrl,
              'identifier': identifier,
              'lastActiveAt': 0,
            });
          });
        } else if (identifier.isNotEmpty) {
          await updateServerIdentifier(serverUrl, identifier);
        }
      }
    } catch (e) {
      // do nothing
    }
  }

  Future<void> updateServerIdentifier(String serverUrl, String identifier) async {
    final appDatabase = this.appDatabase?.database;
    if (appDatabase != null) {
      final server = await getServer(serverUrl);
      await appDatabase.transaction((txn) async {
        await txn.update(SERVERS, {'identifier': identifier}, where: 'url = ?', whereArgs: [serverUrl]);
      });
    }
  }

  Future<void> updateServerDisplayName(String serverUrl, String displayName) async {
    final appDatabase = this.appDatabase?.database;
    if (appDatabase != null) {
      final server = await getServer(serverUrl);
      await appDatabase.transaction((txn) async {
        await txn.update(SERVERS, {'displayName': displayName}, where: 'url = ?', whereArgs: [serverUrl]);
      });
    }
  }

  Future<bool> isServerPresent(String serverUrl) async {
    final server = await getServer(serverUrl);
    return server != null;
  }

  Future<String?> getActiveServerUrl() async {
    final server = await getActiveServer();
    return server?.url;
  }

  Future<String?> getActiveServerDisplayName() async {
    final server = await getActiveServer();
    return server?.displayName;
  }

  Future<String?> getServerUrlFromIdentifier(String identifier) async {
    final server = await getServerByIdentifier(identifier);
    return server?.url;
  }

  AppDatabase getAppDatabaseAndOperator() {
    final app = appDatabase;
    if (app == null) {
      throw Exception('App database not found');
    }
    return app;
  }

  ServerDatabase getServerDatabaseAndOperator(String serverUrl) {
    final server = serverDatabases[serverUrl];
    if (server == null) {
      throw Exception('$serverUrl database not found');
    }
    return server;
  }

  Future<Database?> getActiveServerDatabase() async {
    final server = await getActiveServer();
    if (server?.url != null) {
      return serverDatabases[server!.url]!.database;
    }
    return null;
  }

  Future<void> setActiveServerDatabase(String serverUrl) async {
    final database = appDatabase?.database;
    if (database != null) {
      await database.transaction((txn) async {
        final servers = await txn.query(SERVERS, where: 'url = ?', whereArgs: [serverUrl]);
        if (servers.isNotEmpty) {
          await txn.update(SERVERS, {'lastActiveAt': DateTime.now().millisecondsSinceEpoch}, where: 'url = ?', whereArgs: [serverUrl]);
        }
      });
    }
  }

  Future<void> deleteServerDatabase(String serverUrl) async {
    final database = appDatabase?.database;
    if (database != null) {
      final server = await getServer(serverUrl);
      if (server != null) {
        await database.transaction((txn) async {
          await txn.update(SERVERS, {'lastActiveAt': 0, 'identifier': ''}, where: 'url = ?', whereArgs: [serverUrl]);
        });

        serverDatabases.remove(serverUrl);
        await deleteServerDatabaseFiles(serverUrl);
      }
    }
  }

  Future<void> destroyServerDatabase(String serverUrl) async {
    final database = appDatabase?.database;
    if (database != null) {
      final server = await getServer(serverUrl);
      if (server != null) {
        await database.transaction((txn) async {
          await txn.delete(SERVERS, where: 'url = ?', whereArgs: [serverUrl]);
        });

        serverDatabases.remove(serverUrl);
        await deleteServerDatabaseFiles(serverUrl);
      }
    }
  }

  Future<void> deleteServerDatabaseFiles(String serverUrl) async {
    final databaseName = urlSafeBase64Encode(serverUrl);

    if (Platform.isIOS) {
      // On iOS, we'll delete the *.db file under the shared app-group/databases folder
      await deleteIOSDatabase(databaseName: databaseName);
      return;
    }

    // On Android, we'll delete both the *.db file and the *.db-journal file
    final directory = await getApplicationDocumentsDirectory();
    final androidFilesDir = '${directory.path}/databases/';
    final databaseFile = File('${androidFilesDir}$databaseName.db');
    final databaseJournal = File('${androidFilesDir}$databaseName.db-journal');

    try {
      await databaseFile.delete();
    } catch (e) {
      // do nothing
    }

    try {
      await databaseJournal.delete();
    } catch (e) {
      // do nothing
    }
  }

  Future<bool> factoryReset(bool shouldRemoveDirectory) async {
    try {
      if (Platform.isIOS) {
        await deleteIOSDatabase(shouldRemoveDirectory: shouldRemoveDirectory);
        return true;
      }

      final directory = await getApplicationDocumentsDirectory();
      final androidFilesDir = '${directory.path}/databases/';
      await Directory(androidFilesDir).delete(recursive: true);
      return true;
    } catch (e) {
      return false;
    }
  }

  Map<String, VoidCallback> buildMigrationCallbacks(String dbName) {
    return {
      'onSuccess': () => EventChannel('migration_success').receiveBroadcastStream({'dbName': dbName}),
      'onStart': () => EventChannel('migration_started').receiveBroadcastStream({'dbName': dbName}),
      'onError': (error) => EventChannel('migration_error').receiveBroadcastStream({'dbName': dbName, 'error': error}),
    };
  }

  String getDatabaseFilePath(String dbName) {
    return Platform.isIOS ? '$databaseDirectory/$dbName.db' : '$databaseDirectory$dbName.db';
  }

  String? searchUrl(String toFind) {
    final toFindWithoutProtocol = removeProtocol(toFind);
    return serverDatabases.keys.firstWhere(
          (k) => removeProtocol(k) == toFindWithoutProtocol,
      orElse: () => null,
    );
  }

  Future<ServerModel?> getServer(String serverUrl) async {
    try {
      final database = getAppDatabaseAndOperator().database;
      final servers = await database.query(SERVERS, where: 'url = ?', whereArgs: [serverUrl]);
      return servers.isNotEmpty ? ServerModel.fromMap(servers.first) : null;
    } catch (e) {
      return null;
    }
  }

  Future<List<ServerModel>> getAllServers() async {
    try {
      final database = getAppDatabaseAndOperator().database;
      final servers = await database.query(SERVERS);
      return servers.map((e) => ServerModel.fromMap(e)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<ServerModel?> getActiveServer() async {
    try {
      final servers = await getAllServers();
      return servers.isNotEmpty
          ? servers.reduce((a, b) => b.lastActiveAt > a.lastActiveAt ? b : a)
          : null;
    } catch (e) {
      return null;
    }
  }

  Future<ServerModel?> getServerByIdentifier(String identifier) async {
    try {
      final database = getAppDatabaseAndOperator().database;
      final servers = await database.query(SERVERS, where: 'identifier = ?', whereArgs: [identifier]);
      return servers.isNotEmpty ? ServerModel.fromMap(servers.first) : null;
    } catch (e) {
      return null;
    }
  }
}

final databaseManager = DatabaseManager();
