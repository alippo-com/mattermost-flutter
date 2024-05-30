import 'package:rx_dart/rx_dart.dart';
import 'package:mattermost_flutter/constants.dart';
import 'package:mattermost_flutter/database/manager.dart';

class ServerQueries {
  static Future<List<ServerModel>> queryServerDisplayName(String serverUrl) async {
    try {
      final database = DatabaseManager.getAppDatabaseAndOperator().database;
      return database.get<ServerModel>(MM_TABLES.APP.SERVERS).query(Q.where('url', serverUrl)).toList();
    } catch (e) {
      return [];
    }
  }

  static Future<List<ServerModel>> queryAllActiveServers() async {
    try {
      final database = DatabaseManager.getAppDatabaseAndOperator().database;
      return database.get<ServerModel>(MM_TABLES.APP.SERVERS).query(
        Q.and(
          Q.where('identifier', Q.notEq('')),
          Q.where('last_active_at', Q.gt(0)),
        ),
      ).toList();
    } catch (e) {
      return [];
    }
  }

  static Future<ServerModel?> getServer(String serverUrl) async {
    try {
      final database = DatabaseManager.getAppDatabaseAndOperator().database;
      final servers = await database.get<ServerModel>(MM_TABLES.APP.SERVERS).query(Q.where('url', serverUrl)).fetch();
      return servers.isNotEmpty ? servers[0] : null;
    } catch (e) {
      return null;
    }
  }

  static Future<List<ServerModel>> getAllServers() async {
    try {
      final database = DatabaseManager.getAppDatabaseAndOperator().database;
      return database.get<ServerModel>(MM_TABLES.APP.SERVERS).query().fetch();
    } catch (e) {
      return [];
    }
  }

  static Future<ServerModel?> getActiveServer() async {
    try {
      final servers = await getAllServers();
      if (servers.isEmpty) return null;
      return servers.where((s) => s.identifier.isNotEmpty).reduce((a, b) => b.lastActiveAt > a.lastActiveAt ? b : a);
    } catch (e) {
      return null;
    }
  }

  static Future<String> getActiveServerUrl() async {
    final server = await getActiveServer();
    return server?.url ?? '';
  }

  static Future<ServerModel?> getServerByIdentifier(String identifier) async {
    try {
      final database = DatabaseManager.getAppDatabaseAndOperator().database;
      final servers = await database.get<ServerModel>(MM_TABLES.APP.SERVERS).query(Q.where('identifier', identifier)).fetch();
      return servers.isNotEmpty ? servers[0] : null;
    } catch (e) {
      return null;
    }
  }

  static Future<ServerModel?> getServerByDisplayName(String displayName) async {
    final servers = await getAllServers();
    return servers.firstWhere((s) => s.displayName.toLowerCase() == displayName.toLowerCase(), orElse: () => null);
  }

  static Future<String> getServerDisplayName(String serverUrl) async {
    final servers = await queryServerDisplayName(serverUrl);
    return servers.isNotEmpty ? servers[0].displayName : serverUrl;
  }

  static Stream<String> observeServerDisplayName(String serverUrl) {
    return queryServerDisplayName(serverUrl).asStream().switchMap((s) {
      return Rx.value(s.isNotEmpty ? s[0].displayName : serverUrl);
    }).distinct();
  }

  static Stream<List<ServerModel>> observeAllActiveServers() {
    return queryAllActiveServers().asStream();
  }

  static Future<bool> areAllServersSupported() async {
    final servers = await getAllServers();
    for (final s in servers) {
      if (s.lastActiveAt > 0) {
        try {
          final serverDatabase = DatabaseManager.getServerDatabaseAndOperator(s.url).database;
          final version = await getConfigValue(serverDatabase, 'Version');
          final isSupportedServer = isMinimumServerVersion(version, SupportedServer.MAJOR_VERSION, SupportedServer.MIN_VERSION, SupportedServer.PATCH_VERSION);
          if (!isSupportedServer) {
            return false;
          }
        } catch (e) {
          continue;
        }
      }
    }
    return true;
  }
}
