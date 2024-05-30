import 'package:mattermost_flutter/constants.dart';
import 'package:mattermost_flutter/database/manager.dart';
import 'package:mattermost_flutter/init/push_notifications.dart';
import 'package:mattermost_flutter/managers/network_manager.dart';
import 'package:mattermost_flutter/queries/app/global.dart';
import 'package:mattermost_flutter/queries/app/servers.dart';
import 'package:mattermost_flutter/queries/servers/system.dart';
import 'package:mattermost_flutter/queries/servers/user.dart';
import 'package:mattermost_flutter/store/ephemeral_store.dart';
import 'package:mattermost_flutter/utils/errors.dart';
import 'package:mattermost_flutter/utils/log.dart';
import 'package:mattermost_flutter/utils/notification.dart';
import 'package:mattermost_flutter/utils/security.dart';
import 'package:connectivity_plus/connectivity_plus.dart'; // Using connectivity_plus for network info
import 'package:event/event.dart'; // Replace DeviceEventEmitter with Event package

const int HTTP_UNAUTHORIZED = 401;

Future<void> addPushProxyVerificationStateFromLogin(String serverUrl) async {
  try {
    final operator = DatabaseManager.getServerDatabaseAndOperator(serverUrl).operator;
    final systems = <IdValue>[];

    // Set push proxy verification
    final ppVerification = EphemeralStore.getPushProxyVerificationState(serverUrl);
    if (ppVerification != null) {
      systems.add(IdValue(id: SYSTEM_IDENTIFIERS.PUSH_VERIFICATION_STATUS, value: ppVerification));
    }

    if (systems.isNotEmpty) {
      await operator.handleSystem(systems: systems, prepareRecordsOnly: false);
    }
  } catch (error) {
    logDebug('error setting the push proxy verification state on login', error);
  }
}

Future<Map<String, dynamic>> forceLogoutIfNecessary(String serverUrl, dynamic err) async {
  final database = DatabaseManager.serverDatabases[serverUrl]?.database;
  if (database == null) {
    return {'error': '$serverUrl database not found'};
  }

  final currentUserId = await getCurrentUserId(database);

  if (isErrorWithStatusCode(err) && err.statusCode == HTTP_UNAUTHORIZED && isErrorWithUrl(err) && err.url?.contains('/login') == false && currentUserId != null) {
    await logout(serverUrl);
  }

  return {'error': null};
}

Future<List<dynamic>> fetchSessions(String serverUrl, String currentUserId) async {
  var client;
  try {
    client = NetworkManager.getClient(serverUrl);
  } catch (_) {
    return [];
  }

  try {
    return await client.getSessions(currentUserId);
  } catch (error) {
    logDebug('error on fetchSessions', getFullErrorMessage(error));
    await forceLogoutIfNecessary(serverUrl, error);
  }

  return [];
}

Future<Map<String, dynamic>> login(String serverUrl, {bool ldapOnly = false, String loginId, String mfaToken, String password, dynamic config, String serverDisplayName}) async {
  var deviceToken;
  var user;

  final appDatabase = DatabaseManager.appDatabase?.database;
  if (appDatabase == null) {
    return {'error': 'App database not found.', 'failed': true};
  }

  try {
    final client = NetworkManager.getClient(serverUrl);
    deviceToken = await getDeviceToken();
    user = await client.login(loginId, password, mfaToken, deviceToken, ldapOnly);

    final server = await DatabaseManager.createServerDatabase(
      config: {
        'dbName': serverUrl,
        'serverUrl': serverUrl,
        'identifier': config.DiagnosticId,
        'displayName': serverDisplayName,
      },
    );

    await server?.operator.handleUsers(users: [user], prepareRecordsOnly: false);
    await server?.operator.handleSystem(systems: [
      IdValue(id: Database.SYSTEM_IDENTIFIERS.CURRENT_USER_ID, value: user.id),
    ], prepareRecordsOnly: false);
    final csrfToken = await getCSRFFromCookie(serverUrl);
    client.setCSRFToken(csrfToken);
  } catch (error) {
    logDebug('error on login', getFullErrorMessage(error));
    return {'error': error, 'failed': true};
  }

  try {
    await addPushProxyVerificationStateFromLogin(serverUrl);
    final loginEntryResult = await loginEntry(serverUrl: serverUrl);
    await DatabaseManager.setActiveServerDatabase(serverUrl);
    return {'error': loginEntryResult['error'], 'failed': false};
  } catch (error) {
    return {'error': error, 'failed': false};
  }
}

Future<void> logout(String serverUrl, {bool skipServerLogout = false, bool removeServer = false, bool skipEvents = false}) async {
  if (!skipServerLogout) {
    try {
      final client = NetworkManager.getClient(serverUrl);
      await client.logout();
    } catch (error) {
      logWarning('An error occurred logging out from the server', serverUrl, getFullErrorMessage(error));
    }
  }

  if (!skipEvents) {
    Event.event(Events.SERVER_LOGOUT, {'serverUrl': serverUrl, 'removeServer': removeServer});
  }
}

Future<void> cancelSessionNotification(String serverUrl) async {
  try {
    final dbOperator = DatabaseManager.getServerDatabaseAndOperator(serverUrl);
    final database = dbOperator.database;
    final operator = dbOperator.operator;
    final expiredSession = await getExpiredSession(database);
    final connectivityResult = await (Connectivity().checkConnectivity());

    if (expiredSession?.notificationId != null && connectivityResult != ConnectivityResult.none) {
      PushNotifications.cancelScheduleNotification(int.parse(expiredSession.notificationId));
      operator.handleSystem(systems: [
        IdValue(id: SYSTEM_IDENTIFIERS.SESSION_EXPIRATION, value: ''),
      ], prepareRecordsOnly: false);
    }
  } catch (e) {
    logError('cancelSessionNotification', e);
  }
}

Future<void> scheduleSessionNotification(String serverUrl) async {
  try {
    final dbOperator = DatabaseManager.getServerDatabaseAndOperator(serverUrl);
    final database = dbOperator.database;
    final operator = dbOperator.operator;
    final sessions = await fetchSessions(serverUrl, 'me');
    final user = await getCurrentUser(database);
    final serverName = await getServerDisplayName(serverUrl);

    await cancelSessionNotification(serverUrl);

    if (sessions.isNotEmpty) {
      final session = await findSession(serverUrl, sessions);

      if (session != null) {
        final sessionId = session.id;
        final notificationId = scheduleExpiredNotification(serverUrl, session, serverName, user?.locale);
        operator.handleSystem(systems: [
          IdValue(id: SYSTEM_IDENTIFIERS.SESSION_EXPIRATION, value: {
            'id': sessionId,
            'notificationId': notificationId,
            'expiresAt': session.expiresAt,
          }),
        ], prepareRecordsOnly: false);
      }
    }
  } catch (e) {
    logError('scheduleExpiredNotification', e);
    await forceLogoutIfNecessary(serverUrl, e);
  }
}

Future<Map<String, dynamic>> sendPasswordResetEmail(String serverUrl, String email) async {
  try {
    final client = NetworkManager.getClient(serverUrl);
    final response = await client.sendPasswordResetEmail(email);
    return {'status': response.status};
  } catch (error) {
    logDebug('error on sendPasswordResetEmail', getFullErrorMessage(error));
    return {'error': error};
  }
}

Future<Map<String, dynamic>> ssoLogin(String serverUrl, String serverDisplayName, String serverIdentifier, String bearerToken, String csrfToken) async {
  final database = DatabaseManager.appDatabase?.database;
  if (database == null) {
    return {'error': 'App database not found', 'failed': true};
  }

  try {
    final client = NetworkManager.getClient(serverUrl);

    client.setBearerToken(bearerToken);
    client.setCSRFToken(csrfToken);

    final server = await DatabaseManager.createServerDatabase(
      config: {
        'dbName': serverUrl,
        'serverUrl': serverUrl,
        'identifier': serverIdentifier,
        'displayName': serverDisplayName,
      },
    );
    final user = await client.getMe();
    await server?.operator.handleUsers(users: [user], prepareRecordsOnly: false);
    await server?.operator.handleSystem(systems: [
      IdValue(id: Database.SYSTEM_IDENTIFIERS.CURRENT_USER_ID, value: user.id),
    ], prepareRecordsOnly: false);
  } catch (error) {
    logDebug('error on ssoLogin', getFullErrorMessage(error));
    return {'error': error, 'failed': true};
  }

  try {
    await addPushProxyVerificationStateFromLogin(serverUrl);
    final loginEntryResult = await loginEntry(serverUrl: serverUrl);
    await DatabaseManager.setActiveServerDatabase(serverUrl);
    return {'error': loginEntryResult['error'], 'failed': false};
  } catch (error) {
    return {'error': error, 'failed': false};
  }
}

Future<dynamic> findSession(String serverUrl, List<dynamic> sessions) async {
  try {
    final database = DatabaseManager.getServerDatabaseAndOperator(serverUrl).database;
    final expiredSession = await getExpiredSession(database);
    final deviceToken = await getDeviceToken();

    var session = sessions.firstWhere((s) => s.id == expiredSession?.id, orElse: () => null);
    if (session != null) {
      return session;
    }

    if (deviceToken != null) {
      session = sessions.firstWhere((s) => s.deviceId == deviceToken, orElse: () => null);
      if (session != null) {
        return session;
      }
    }

    final csrfToken = await getCSRFFromCookie(serverUrl);
    if (csrfToken != null) {
      session = sessions.firstWhere((s) => s.props?.csrf == csrfToken, orElse: () => null);
      if (session != null) {
        return session;
      }
    }

    session = sessions.firstWhere((s) => s.props?.os.toLowerCase() == Platform.operatingSystem, orElse: () => null);
    if (session != null) {
      return session;
    }
  } catch (e) {
    logError('findSession', e);
  }

  return null;
}