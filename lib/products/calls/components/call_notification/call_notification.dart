// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'dart:async';
import 'dart:io';

import 'package:device_info/device_info.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:nozbe_watermelondb/adapters/sqlite.dart';
import 'package:nozbe_watermelondb/watermelondb.dart';
import 'package:path_provider/path_provider.dart';
import 'package:watermelondb/migrations.dart';
import 'package:watermelondb/utils/logger.dart';
import 'package:watermelondb/utils/common.dart';

import 'package:mattermost_flutter/constants/database.dart';
import 'package:mattermost_flutter/database/migration/app.dart';
import 'package:mattermost_flutter/database/migration/server.dart';
import 'package:mattermost_flutter/database/models/app/info_model.dart';
import 'package:mattermost_flutter/database/models/app/global_model.dart';
import 'package:mattermost_flutter/database/models/app/servers_model.dart';
import 'package:mattermost_flutter/database/models/server/category_model.dart';
import 'package:mattermost_flutter/database/models/server/category_channel_model.dart';
import 'package:mattermost_flutter/database/models/server/channel_model.dart';
import 'package:mattermost_flutter/database/models/server/channel_info_model.dart';
import 'package:mattermost_flutter/database/models/server/channel_membership_model.dart';
import 'package:mattermost_flutter/database/models/server/custom_emoji_model.dart';
import 'package:mattermost_flutter/database/models/server/draft_model.dart';
import 'package:mattermost_flutter/database/models/server/file_model.dart';
import 'package:mattermost_flutter/database/models/server/group_model.dart';
import 'package:mattermost_flutter/database/models/server/group_channel_model.dart';
import 'package:mattermost_flutter/database/models/server/group_team_model.dart';
import 'package:mattermost_flutter/database/models/server/group_membership_model.dart';
import 'package:mattermost_flutter/database/models/server/my_channel_model.dart';
import 'package:mattermost_flutter/database/models/server/my_channel_settings_model.dart';
import 'package:mattermost_flutter/database/models/server/my_team_model.dart';
import 'package:mattermost_flutter/database/models/server/post_model.dart';
import 'package:mattermost_flutter/database/models/server/posts_in_channel_model.dart';
import 'package:mattermost_flutter/database/models/server/posts_in_thread_model.dart';
import 'package:mattermost_flutter/database/models/server/preference_model.dart';
import 'package:mattermost_flutter/database/models/server/reaction_model.dart';
import 'package:mattermost_flutter/database/models/server/role_model.dart';
import 'package:mattermost_flutter/database/models/server/system_model.dart';
import 'package:mattermost_flutter/database/models/server/team_model.dart';
import 'package:mattermost_flutter/database/models/server/team_channel_history_model.dart';
import 'package:mattermost_flutter/database/models/server/team_membership_model.dart';
import 'package:mattermost_flutter/database/models/server/team_search_history_model.dart';
import 'package:mattermost_flutter/database/models/server/thread_model.dart';
import 'package:mattermost_flutter/database/models/server/thread_participant_model.dart';
import 'package:mattermost_flutter/database/models/server/thread_in_team_model.dart';
import 'package:mattermost_flutter/database/models/server/team_threads_sync_model.dart';
import 'package:mattermost_flutter/database/models/server/user_model.dart';
import 'package:mattermost_flutter/database/operator/app_data_operator.dart';
import 'package:mattermost_flutter/database/operator/server_data_operator.dart';
import 'package:mattermost_flutter/database/schema/app.dart';
import 'package:mattermost_flutter/database/schema/server.dart';
import 'package:mattermost_flutter/helpers/database/upgrade.dart';
import 'package:mattermost_flutter/queries/app/servers.dart';
import 'package:mattermost_flutter/utils/general.dart';
import 'package:mattermost_flutter/utils/log.dart';
import 'package:mattermost_flutter/utils/mattermost_managed.dart';
import 'package:mattermost_flutter/utils/security.dart';
import 'package:mattermost_flutter/utils/url.dart';

class DatabaseManager {
  AppDatabase? appDatabase;
  Map<String, ServerDatabase> serverDatabases = {};
  List<Type> appModels = [];
  String? databaseDirectory;
  List<Type> serverModels = [];

  DatabaseManager() {
    appModels = [
      InfoModel,
      GlobalModel,
      ServersModel,
    ];
    serverModels = [
      CategoryModel,
      CategoryChannelModel,
      ChannelModel,
      ChannelInfoModel,
      ChannelMembershipModel,
      CustomEmojiModel,
      DraftModel,
      FileModel,
      GroupModel,
      GroupChannelModel,
      GroupTeamModel,
      GroupMembershipModel,
      MyChannelModel,
      MyChannelSettingsModel,
      MyTeamModel,
      PostModel,
      PostsInChannelModel,
      PostsInThreadModel,
      PreferenceModel,
      ReactionModel,
      RoleModel,
      SystemModel,
      TeamModel,
      TeamChannelHistoryModel,
      TeamMembershipModel,
      TeamSearchHistoryModel,
      ThreadModel,
      ThreadParticipantModel,
      ThreadInTeamModel,
      TeamThreadsSyncModel,
      UserModel,
    ];

    if (Platform.isIOS) {
      getIOSAppGroupDetails().then((details) {
        databaseDirectory = details.appGroupDatabase;
      });
    } else {
      getApplicationDocumentsDirectory().then((dir) {
        databaseDirectory = '${dir.path}/databases/';
      });
    }
  }

  /// init : Retrieves all the servers registered in the default database
  Future<void> init(List<String> serverUrls) async {
    await createAppDatabase();
    final buildNumber = (await DeviceInfoPlugin().iosInfo).utsname.version;
    final versionNumber = (await DeviceInfoPlugin().iosInfo).systemVersion;
    await beforeUpgrade(serverUrls, versionNumber, buildNumber);
    for (final serverUrl in serverUrls) {
      await initServerDatabase(serverUrl);
    }
    appDatabase?.operator.handleInfo(
      info: [
        InfoModel(
          buildNumber: buildNumber,
          createdAt: DateTime.now().millisecondsSinceEpoch,
          versionNumber: versionNumber,
        )
      ],
      prepareRecordsOnly: false,
    );
  }

  /// createAppDatabase: Creates the App database. However,
  /// if a database could not be created, it will return undefined.
  Future<AppDatabase?> createAppDatabase() async {
    try {
      const databaseName = APP_DATABASE;
      if (!Platform.isIOS) {
        await Directory(databaseDirectory!).create(recursive: true);
      }
      final databaseFilePath = getDatabaseFilePath(databaseName);
      final modelClasses = appModels;
      final schema = appSchema;

      final adapter = SQLiteAdapter(
        dbName: databaseFilePath,
        migrationEvents: buildMigrationCallbacks(databaseName),
        migrations: AppDatabaseMigrations,
        jsi: true,
        schema: schema,
      );

      final database = Database(
        adapter: adapter,
        modelClasses: modelClasses,
      );
      final operator = AppDataOperator(database);
      appDatabase = AppDatabase(database: database, operator: operator);
      return appDatabase;
    } catch (e) {
      logError('Unable to create the App Database!!', e);
    }

    return null;
  }

  /// createServerDatabase: Creates a server database and registers the the server in the app database. However,
  /// if a database connection could not be created, it will return undefined.
  Future<ServerDatabase?> createServerDatabase(
      {required CreateServerDatabaseArgs config}) async {
    final dbName = config.dbName;
    final displayName = config.displayName;
    final identifier = config.identifier;
    final serverUrl = config.serverUrl;

    if (serverUrl != null) {
      try {
        final databaseName = urlSafeBase64Encode(serverUrl);
        final databaseFilePath = getDatabaseFilePath(databaseName);
        final migrations = ServerDatabaseMigrations;
        final modelClasses = serverModels;
        final schema = serverSchema;

        final adapter = SQLiteAdapter(
          dbName: databaseFilePath,
          migrationEvents: buildMigrationCallbacks(databaseName),
          migrations: migrations,
          jsi: true,
          schema: schema,
        );

        // Registers the new server connection into the DEFAULT database
        await addServerToAppDatabase(
          databaseFilePath: databaseFilePath,
          displayName: displayName ?? dbName,
          identifier: identifier,
          serverUrl: serverUrl,
        );

        final database = Database(
          adapter: adapter,
          modelClasses: modelClasses,
        );
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

  /// initServerDatabase : initializes the server database.
  Future<void> initServerDatabase(String serverUrl) async {
    await createServerDatabase(
      config: CreateServerDatabaseArgs(
        dbName: serverUrl,
        dbType: DatabaseType.SERVER,
        serverUrl: serverUrl,
      ),
    );
  }

  /// addServerToAppDatabase: Adds a record in the 'app' database - into the 'servers' table - for this new server connection
  Future<void> addServerToAppDatabase({
    required String databaseFilePath,
    required String displayName,
    required String serverUrl,
    String? identifier = '',
  }) async {
    try {
      final appDatabaseInstance = appDatabase?.database;
      if (appDatabaseInstance != null) {
        final serverModel = await getServer(serverUrl);

        if (serverModel == null) {
          await appDatabaseInstance.write(() async {
            final serversCollection = appDatabaseInstance.collections.get(SERVERS);
            await serversCollection.create((server) {
              server.dbPath = databaseFilePath;
              server.displayName = displayName;
              server.url = serverUrl;
              server.identifier = identifier;
              server.lastActiveAt = 0;
            });
          });
        } else if (serverModel.dbPath != databaseFilePath) {
          await appDatabaseInstance.write(() async {
            serverModel.update((s) {
              s.dbPath = databaseFilePath;
            });
          });
        } else if (identifier != null) {
          await updateServerIdentifier(serverUrl, identifier, displayName);
        }
      }
    } catch (e) {
      logError('Error adding server to App database', e);
    }
  }

  Future<void> updateServerIdentifier(
      String serverUrl, String identifier, String? displayName) async {
    final appDatabaseInstance = appDatabase?.database;
    if (appDatabaseInstance != null) {
      final server = await getServer(serverUrl);
      await appDatabaseInstance.write(() async {
        server?.update((record) {
          record.identifier = identifier;
          if (displayName != null) {
            record.displayName = displayName;
          }
        });
      });
    }
  }

  Future<void> updateServerDisplayName(
      String serverUrl, String displayName) async {
    final appDatabaseInstance = appDatabase?.database;
    if (appDatabaseInstance != null) {
      final server = await getServer(serverUrl);
      await appDatabaseInstance.write(() async {
        server?.update((record) {
          record.displayName = displayName;
        });
      });
    }
  }

  /// isServerPresent : Confirms if the current serverUrl does not already exist in the database
  Future<bool> isServerPresent(String serverUrl) async {
    final server = await getServer(serverUrl);
    return server != null;
  }

  /// getActiveServerUrl: Get the server url for active server database.
  Future<String?> getActiveServerUrl() async {
    final server = await getActiveServer();
    return server?.url;
  }

  /// getActiveServerDisplayName: Get the server display name for active server database.
  Future<String?> getActiveServerDisplayName() async {
    final server = await getActiveServer();
    return server?.displayName;
  }

  Future<String?> getServerUrlFromIdentifier(String identifier) async {
    final server = await getServerByIdentifier(identifier);
    return server?.url;
  }

  /// getActiveServerDatabase: Get the record for active server database.
  Future<Database?> getActiveServerDatabase() async {
    final server = await getActiveServer();
    if (server?.url != null) {
      return serverDatabases[server!.url]?.database;
    }

    return null;
  }

  /// getAppDatabaseAndOperator: Helper function that returns App the database and operator.
  /// use within a try/catch block
  AppDatabase getAppDatabaseAndOperator() {
    final app = appDatabase;
    if (app == null) {
      throw Exception('App database not found');
    }

    return app;
  }

  /// getServerDatabaseAndOperator: Helper function that returns the database and operator
  /// for a specific server.
  /// use within a try/catch block
  ServerDatabase getServerDatabaseAndOperator(String serverUrl) {
    final server = serverDatabases[serverUrl];
    if (server == null) {
      throw Exception('$serverUrl database not found');
    }

    return server;
  }

  /// setActiveServerDatabase: Set the new active server database.
  /// This method should be called when switching to another server.
  Future<void> setActiveServerDatabase(String serverUrl) async {
    if (appDatabase?.database != null) {
      final database = appDatabase?.database;
      await database!.write(() async {
        final servers = await database.collections
            .get(SERVERS)
            .query(Q.where('url', serverUrl))
            .fetch();
        if (servers.isNotEmpty) {
          servers[0].update((server) {
            server.lastActiveAt = DateTime.now().millisecondsSinceEpoch;
          });
        }
      });
    }
  }

  /// deleteServerDatabase: Removes the *.db file from the App-Group directory for iOS or the files directory on Android.
  /// Also, it sets the last_active_at to '0' entry in the 'servers' table from the APP database
  Future<void> deleteServerDatabase(String serverUrl) async {
    final database = appDatabase?.database;
    if (database != null) {
      final server = await getServer(serverUrl);
      if (server != null) {
        database.write(() async {
          server.update((record) {
            record.lastActiveAt = 0;
            record.identifier = '';
          });
        });

        serverDatabases.remove(serverUrl);
        deleteServerDatabaseFiles(serverUrl);
      }
    }
  }

  /// destroyServerDatabase: Removes the *.db file from the App-Group directory for iOS or the files directory on Android.
  /// Also, removes the entry in the 'servers' table from the APP database
  Future<void> destroyServerDatabase(String serverUrl) async {
    final database = appDatabase?.database;
    if (database != null) {
      final server = await getServer(serverUrl);
      if (server != null) {
        database.write(() async {
          await server.destroyPermanently();
        });

        serverDatabases.remove(serverUrl);
        deleteServerDatabaseFiles(serverUrl);
      }
    }
  }

  /// deleteServerDatabaseFiles: Removes the *.db file from the App-Group directory for iOS or the files directory on Android.
  Future<void> deleteServerDatabaseFiles(String serverUrl) async {
    final databaseName = urlSafeBase64Encode(serverUrl);
    return deleteServerDatabaseFilesByName(databaseName);
  }

  /// deleteServerDatabaseFilesByName: Removes the *.db file from the App-Group directory for iOS or the files directory for Android, given the database name
  Future<void> deleteServerDatabaseFilesByName(String databaseName) async {
    if (Platform.isIOS) {
      // On iOS, we'll delete the *.db file under the shared app-group/databases folder
      await deleteIOSDatabase(databaseName);
      return;
    }

    // On Android, we'll delete the *.db, the *.db-shm and *.db-wal files
    final databaseFile = '$databaseDirectory$databaseName.db';
    final databaseShm = '$databaseDirectory$databaseName.db-shm';
    final databaseWal = '$databaseDirectory$databaseName.db-wal';

    await File(databaseFile).delete().catchError((_) {});
    await File(databaseShm).delete().catchError((_) {});
    await File(databaseWal).delete().catchError((_) {});
  }

  /// renameDatabase: Ren...