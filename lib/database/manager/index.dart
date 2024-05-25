// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:sqflite/sqflite.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'dart:async';
import 'dart:io';
import 'package:mattermost_flutter/models/app_models.dart';
import 'package:mattermost_flutter/models/server_models.dart';
import 'package:mattermost_flutter/utils/log.dart';
import 'package:mattermost_flutter/database/migration/app_migration.dart';
import 'package:mattermost_flutter/database/migration/server_migration.dart';
import 'package:mattermost_flutter/utils/database_utils.dart';
import 'package:mattermost_flutter/utils/platform_utils.dart';
import 'package:mattermost_flutter/types/database.dart';
import 'package:mattermost_flutter/types/api_client_interface.dart';

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
  final String? databaseDirectory = Platform.isIOS 
    ? getIOSAppGroupDetails().appGroupDatabase 
    : '${getDatabasesPath()}/databases/';

  DatabaseManager();

  Future<void> init(List<String> serverUrls) async {
    await createAppDatabase();
    final buildNumber = await DeviceInfoPlugin().buildNumber;
    final versionNumber = await DeviceInfoPlugin().version;
    await beforeUpgrade(serverUrls, versionNumber, buildNumber);
    for (var serverUrl in serverUrls) {
      await initServerDatabase(serverUrl);
    }
    appDatabase?.operator.handleInfo({
      'info': [
        {
          'build_number': buildNumber,
          'created_at': DateTime.now().millisecondsSinceEpoch,
          'version_number': versionNumber,
        }
      ],
      'prepareRecordsOnly': false,
    });
  }

  Future<AppDatabase?> createAppDatabase() async {
    try {
      final databaseName = 'app';
      if (Platform.isAndroid) {
        await Directory(databaseDirectory!).create(recursive: true);
      }
      final databaseFilePath = getDatabaseFilePath(databaseName);
      final adapter = SQLiteAdapter(
        dbName: databaseFilePath,
        migrationEvents: buildMigrationCallbacks(databaseName),
        migrations: AppDatabaseMigrations,
        jsi: true,
        schema: appSchema,
      );

      final database = Database(adapter: adapter, modelClasses: appModels);
      final operator = AppDataOperator(database);

      appDatabase = AppDatabase(database: database, operator: operator);

      return appDatabase;
    } catch (e) {
      logError('Unable to create the App Database!!', e);
    }

    return null;
  }

  Future<ServerDatabase?> createServerDatabase(CreateServerDatabaseArgs config) async {
    final dbName = config.dbName;
    final displayName = config.displayName;
    final identifier = config.identifier;
    final serverUrl = config.serverUrl;

    if (serverUrl != null) {
      try {
        final databaseName = urlSafeBase64Encode(serverUrl);
        final databaseFilePath = getDatabaseFilePath(databaseName);
        final adapter = SQLiteAdapter(
          dbName: databaseFilePath,
          migrationEvents: buildMigrationCallbacks(databaseName),
          migrations: ServerDatabaseMigrations,
          jsi: true,
          schema: serverSchema,
        );

        await addServerToAppDatabase(RegisterServerDatabaseArgs(
          databaseFilePath: databaseFilePath,
          displayName: displayName ?? dbName,
          identifier: identifier,
          serverUrl: serverUrl,
        ));

        final database = Database(adapter: adapter, modelClasses: serverModels);
        final operator = ServerDataOperator(database);
        final serverDatabase = ServerDatabase(database: database, operator: operator);

        serverDatabases[serverUrl] = serverDatabase;

        return serverDatabase;
      } catch (e) {
        logError('Error initializing database', e);
      }
    }

    return null;
  }

  Future<void> initServerDatabase(String serverUrl) async {
    await createServerDatabase(CreateServerDatabaseArgs(
      config: ServerConfig(
        dbName: serverUrl,
        dbType: DatabaseType.SERVER,
        serverUrl: serverUrl,
      ),
    ));
  }

  Future<void> addServerToAppDatabase(RegisterServerDatabaseArgs args) async {
    try {
      final appDatabase = this.appDatabase?.database;
      if (appDatabase != null) {
        final serverModel = await getServer(args.serverUrl);
        if (serverModel == null) {
          await appDatabase.write(() async {
            final serversCollection = appDatabase.collections.get(SERVERS);
            await serversCollection.create((server) {
              server.dbPath = args.databaseFilePath;
              server.displayName = args.displayName;
              server.url = args.serverUrl;
              server.identifier = args.identifier;
              server.lastActiveAt = 0;
            });
          });
        } else if (serverModel.dbPath != args.databaseFilePath) {
          await appDatabase.write(() async {
            await serverModel.update((s) {
              s.dbPath = args.databaseFilePath;
            });
          });
        } else if (args.identifier.isNotEmpty) {
          await updateServerIdentifier(args.serverUrl, args.identifier, args.displayName);
        }
      }
    } catch (e) {
      logError('Error adding server to App database', e);
    }
  }

  Future<void> updateServerIdentifier(String serverUrl, String identifier, String? displayName) async {
    final appDatabase = this.appDatabase?.database;
    if (appDatabase != null) {
      final server = await getServer(serverUrl);
      await appDatabase.write(() async {
        await server?.update((record) {
          record.identifier = identifier;
          if (displayName != null) {
            record.displayName = displayName;
          }
        });
      });
    }
  }

  Future<void> updateServerDisplayName(String serverUrl, String displayName) async {
    final appDatabase = this.appDatabase?.database;
    if (appDatabase != null) {
      final server = await getServer(serverUrl);
      await appDatabase.write(() async {
        await server?.update((record) {
          record.displayName = displayName;
        });
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

  Future<Database?> getActiveServerDatabase() async {
    final server = await getActiveServer();
    if (server?.url != null) {
      return serverDatabases[server!.url]?.database;
    }
    return null;
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

  Future<void> setActiveServerDatabase(String serverUrl) async {
    if (appDatabase?.database != null) {
      final database = appDatabase!.database;
      await database.write(() async {
        final servers = await database.collections.get(SERVERS).query(Q.where('url', serverUrl)).fetch();
        if (servers.isNotEmpty) {
          servers[0].update((server) {
            server.lastActiveAt = DateTime.now().millisecondsSinceEpoch;
          });
        }
      });
    }
  }

  Future<void> deleteServerDatabase(String serverUrl) async {
    final database = appDatabase?.database;
    if (database != null) {
      final server = await getServer(serverUrl);
      if (server != null) {
        await database.write(() async {
          await server.update((record) {
            record.lastActiveAt = 0;
            record.identifier = '';
          });
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
        await database.write(() async {
          await server.destroyPermanently();
        });

        serverDatabases.remove(serverUrl);
        await deleteServerDatabaseFiles(serverUrl);
      }
    }
  }

  Future<void> deleteServerDatabaseFiles(String serverUrl) async {
    final databaseName = urlSafeBase64Encode(serverUrl);
    await deleteServerDatabaseFilesByName(databaseName);
  }

  Future<void> deleteServerDatabaseFilesByName(String databaseName) async {
    if (Platform.isIOS) {
      await deleteIOSDatabase(databaseName);
      return;
    }

    final databaseFile = '$databaseDirectory$databaseName.db';
    final databaseShm = '$databaseDirectory$databaseName.db-shm';
    final databaseWal = '$databaseDirectory$databaseName.db-wal';

    await File(databaseFile).delete().catchError((_) {});
    await File(databaseShm).delete().catchError((_) {});
    await File(databaseWal).delete().catchError((_) {});
  }

  Future<void> renameDatabase(String databaseName, String newDBName) async {
    if (Platform.isIOS) {
      await renameIOSDatabase(databaseName, newDBName);
      return;
    }

    final databaseFile = '$databaseDirectory$databaseName.db';
    final databaseShm = '$databaseDirectory$databaseName.db-shm';
    final databaseWal = '$databaseDirectory$databaseName.db-wal';

    final newDatabaseFile = '$databaseDirectory$newDBName.db';
    final newDatabaseShm = '$databaseDirectory$newDBName.db-shm';
    final newDatabaseWal = '$databaseDirectory$newDBName.db-wal';

    if (await File(newDatabaseFile).exists()) {
      return;
    }

    if (!await File(databaseFile).exists()) {
      return;
    }

    try {
      await File(databaseFile).rename(newDatabaseFile);
      await File(databaseShm).rename(newDatabaseShm);
      await File(databaseWal).rename(newDatabaseWal);
    } catch (error) {
      // Do nothing
    }
  }

  Future<bool> factoryReset(bool shouldRemoveDirectory) async {
    try {
      if (Platform.isIOS) {
        await deleteIOSDatabase(shouldRemoveDirectory);
        return true;
      }

      final androidFilesDir = '$databaseDirectory/databases/';
      await Directory(androidFilesDir).delete(recursive: true);
      return true;
    } catch (e) {
      return false;
    }
  }

  MigrationEvents buildMigrationCallbacks(String dbName) {
    return MigrationEvents(
      onSuccess: () {
        logDebug('DB Migration success', dbName);
        DeviceEventEmitter.emit(MIGRATION_EVENTS.MIGRATION_SUCCESS, {'dbName': dbName});
      },
      onStart: () {
        logDebug('DB Migration start', dbName);
        DeviceEventEmitter.emit(MIGRATION_EVENTS.MIGRATION_STARTED, {'dbName': dbName});
      },
      onError: (error) {
        logDebug('DB Migration error', dbName);
        DeviceEventEmitter.emit(MIGRATION_EVENTS.MIGRATION_ERROR, {'dbName': dbName, 'error': error});
      },
    );
  }

  String getDatabaseFilePath(String dbName) {
    return Platform.isIOS 
      ? '$databaseDirectory/$dbName.db' 
      : '$databaseDirectory$dbName.db';
  }

  String? searchUrl(String toFind) {
    final toFindWithoutProtocol = removeProtocol(toFind);
    return serverDatabases.keys.firstWhere((k) => removeProtocol(k) == toFindWithoutProtocol, orElse: () => null);
  }
}

DatabaseManager databaseManager = DatabaseManager();
