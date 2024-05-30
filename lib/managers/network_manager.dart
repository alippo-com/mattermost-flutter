// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:device_info/device_info.dart';
import 'package:flutter/material.dart';
import 'package:mattermost_flutter/assets/config.dart';
import 'package:mattermost_flutter/client/client.dart';
import 'package:mattermost_flutter/client/constants.dart' as ClientConstants;
import 'package:mattermost_flutter/client/error.dart';
import 'package:mattermost_flutter/constants/network.dart';
import 'package:mattermost_flutter/i18n.dart';
import 'package:mattermost_flutter/utils/log.dart';
import 'package:mattermost_flutter/utils/security.dart';
import 'package:mattermost_flutter/types.dart';
import 'package:sqflite/sqflite.dart';
import 'package:url_launcher/url_launcher.dart';

const CLIENT_CERTIFICATE_IMPORT_ERROR_CODES = [-103, -104, -105, -108];
const CLIENT_CERTIFICATE_MISSING_ERROR_CODE = -200;
const SERVER_CERTIFICATE_INVALID = -299;

class NetworkManager {
  final Map<String, Client> clients = {};

  final Map<String, String> DEFAULT_HEADERS = {
    'X-Requested-With': 'XMLHttpRequest',
  };

  final Map<String, dynamic> DEFAULT_SESSION_CONFIGURATION = {
    'allowsCellularAccess': true,
    'waitsForConnectivity': false,
    'httpMaximumConnectionsPerHost': 10,
    'cancelRequestsOnUnauthorized': true,
  };

  final Map<String, dynamic> DEFAULT_RETRY_POLICY_CONFIGURATION = {
    'type': RetryTypes.EXPONENTIAL_RETRY,
    'retryLimit': 3,
    'exponentialBackoffBase': 2,
    'exponentialBackoffScale': 0.5,
  };

  final Map<String, String> DEFAULT_REQUEST_ADAPTER_CONFIGURATION = {
    'bearerAuthTokenResponseHeader': 'token',
  };

  Future<void> init(List<ServerCredential> serverCredentials) async {
    for (final credential in serverCredentials) {
      try {
        await createClient(credential.serverUrl, credential.token);
      } catch (error) {
        logError('NetworkManager init error', error);
      }
    }
  }

  void invalidateClient(String serverUrl) {
    clients[serverUrl]?.invalidate();
    clients.remove(serverUrl);
  }

  Client getClient(String serverUrl) {
    final client = clients[serverUrl];
    if (client == null) {
      throw Exception('$serverUrl client not found');
    }
    return client;
  }

  Future<Client> createClient(String serverUrl, [String? bearerToken]) async {
    final config = await buildConfig();
    try {
      final clientResponse = await getOrCreateAPIClient(serverUrl, config, clientErrorEventHandler);
      final csrfToken = await getCSRFFromCookie(serverUrl);
      clients[serverUrl] = Client(clientResponse.client, serverUrl, bearerToken, csrfToken);
    } catch (error) {
      throw ClientError(serverUrl, {
        'message': 'Can’t find this server. Check spelling and URL format.',
        'intl': {
          'id': 'apps.error.network.no_server',
          'defaultMessage': 'Can’t find this server. Check spelling and URL format.',
        },
        'url': serverUrl,
        'details': error,
      });
    }
    return clients[serverUrl]!;
  }

  Future<Map<String, dynamic>> buildConfig() async {
    final deviceInfo = DeviceInfoPlugin();
    final androidInfo = await deviceInfo.androidInfo;
    final iosInfo = await deviceInfo.iosInfo;

    final userAgent = 'Mattermost Mobile/${androidInfo.version.release}+${androidInfo.version.sdkInt} (${androidInfo.model}; ${androidInfo.version.release}; ${androidInfo.manufacturer})';
    final managedConfig = ManagedApp.enabled ? await Emm.getManagedConfig<ManagedConfig>() : null;
    final headers = {
      ClientConstants.HEADER_USER_AGENT: userAgent,
      ...DEFAULT_HEADERS,
    };

    final config = {
      ...DEFAULT_SESSION_CONFIGURATION,
      'timeoutIntervalForRequest': managedConfig?.timeout ?? DEFAULT_SESSION_CONFIGURATION['timeoutIntervalForRequest'],
      'timeoutIntervalForResource': managedConfig?.timeoutVPN ?? DEFAULT_SESSION_CONFIGURATION['timeoutIntervalForResource'],
      'waitsForConnectivity': managedConfig?.useVPN == 'true',
      'headers': headers,
    };

    return config;
  }

  void clientErrorEventHandler(APIClientErrorEvent event) {
    if (CLIENT_CERTIFICATE_IMPORT_ERROR_CODES.contains(event.errorCode)) {
      DeviceEventEmitter.emit(CERTIFICATE_ERRORS.CLIENT_CERTIFICATE_IMPORT_ERROR, event.serverUrl);
    } else if (CLIENT_CERTIFICATE_MISSING_ERROR_CODE == event.errorCode) {
      DeviceEventEmitter.emit(CERTIFICATE_ERRORS.CLIENT_CERTIFICATE_MISSING, event.serverUrl);
    } else if (SERVER_CERTIFICATE_INVALID == event.errorCode) {
      logDebug('Invalid SSL certificate:', event.errorDescription);
      final parsed = Uri.parse(event.serverUrl);
      showDialog(
        context: BuildContext,
        builder: (context) {
          return AlertDialog(
            title: Text(getLocalizedMessage(DEFAULT_LOCALE, t('server.invalid.certificate.title'), 'Invalid SSL certificate')),
            content: Text(
              getLocalizedMessage(
                DEFAULT_LOCALE,
                t('server.invalid.certificate.description'),
                'The certificate for this server is invalid.\nYou might be connecting to a server that is pretending to be “{hostname}” which could put your confidential information at risk.',
              ).replaceAll('{hostname}', parsed.host),
            ),
            actions: <Widget>[
              TextButton(
                child: Text(getLocalizedMessage(DEFAULT_LOCALE, t('server.invalid.certificate.ok'), 'OK')),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }
}

final networkManager = NetworkManager();