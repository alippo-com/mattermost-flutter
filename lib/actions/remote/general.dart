// Converted Dart code from TypeScript

import 'package:mattermost_flutter/constants/database.dart';
import 'package:mattermost_flutter/constants/push_proxy.dart';
import 'package:mattermost_flutter/database/manager.dart';
import 'package:mattermost_flutter/i18n.dart';
import 'package:mattermost_flutter/utils/errors.dart';
import 'package:mattermost_flutter/utils/log.dart';


Future<String?> getDeviceIdForPing(String serverUrl, bool checkDeviceId) async {
  if (!checkDeviceId) {
    return null;
  }

  final serverDatabase = DatabaseManager.serverDatabases?[serverUrl]?.database;
  if (serverDatabase != null) {
    final status = await getPushVerificationStatus(serverDatabase);
    if (status == PUSH_PROXY_STATUS_VERIFIED) {
      return null;
    }
  }

  return getDeviceToken();
}

// Default timeout interval for ping is 5 seconds
Future<Map<String, dynamic>> doPing(String serverUrl, bool verifyPushProxy, {int timeoutInterval = 5000}) async {
  dynamic client;
  try {
    client = await NetworkManager.createClient(serverUrl);
  } catch (error) {
    return {'error': error};
  }

  final certificateError = {
    'id': t('mobile.server_requires_client_certificate'),
    'defaultMessage': 'Server requires client certificate for authentication.',
  };

  final pingError = {
    'id': t('mobile.server_ping_failed'),
    'defaultMessage': 'Cannot connect to the server.',
  };

  final deviceId = await getDeviceIdForPing(serverUrl, verifyPushProxy);

  dynamic response;
  try {
    response = await client.ping(deviceId, timeoutInterval);

    if (response.code == 401) {
      // Don't invalidate the client since we want to eventually
      // import a certificate with client.importClientP12()
      // if for some reason cert is not imported do invalidate the client then.
      return {'error': {'intl': certificateError}};
    }

    if (!response.ok) {
      logDebug('Server ping returned not ok response', response);
      NetworkManager.invalidateClient(serverUrl);
      return {'error': {'intl': pingError}};
    }
  } catch (error) {
    logDebug('Server ping threw an exception', getFullErrorMessage(error));
    NetworkManager.invalidateClient(serverUrl);
    return {'error': {'intl': pingError}};
  }

  if (verifyPushProxy) {
    var canReceiveNotifications = response?.data?.CanReceiveNotifications;

    // Already verified or old server
    if (deviceId == null || canReceiveNotifications == null) {
      canReceiveNotifications = PUSH_PROXY_RESPONSE_VERIFIED;
    }

    return {'canReceiveNotifications': canReceiveNotifications};
  }

  return {};
}

Future<Map<String, dynamic>> getRedirectLocation(String serverUrl, String link) async {
  try {
    final client = NetworkManager.getClient(serverUrl);
    final databaseOperator = DatabaseManager.getServerDatabaseAndOperator(serverUrl);
    final expandedLink = await client.getRedirectLocation(link);
    if (expandedLink?.location != null) {
      final storedLinks = await getExpandedLinks(databaseOperator.database);
      storedLinks[link] = expandedLink.location;
      final expanded = {
        'id': SYSTEM_IDENTIFIERS.EXPANDED_LINKS,
        'value': jsonEncode(storedLinks),
      };
      await databaseOperator.operator.handleSystem({
        'systems': [expanded],
        'prepareRecordsOnly': false,
      });
    }

    return {'expandedLink': expandedLink};
  } catch (error) {
    logDebug('error on getRedirectLocation', getFullErrorMessage(error));
    forceLogoutIfNecessary(serverUrl, error);
    return {'error': error};
  }
}