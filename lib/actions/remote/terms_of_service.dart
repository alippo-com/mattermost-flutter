
// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:mattermost_flutter/database/manager.dart';
import 'package:mattermost_flutter/managers/network_manager.dart';
import 'package:mattermost_flutter/queries/servers/user.dart';
import 'package:mattermost_flutter/utils/errors.dart';
import 'package:mattermost_flutter/utils/log.dart';

import 'session.dart';

Future<Map<String, dynamic>> fetchTermsOfService(String serverUrl) async {
  try {
    final client = NetworkManager.getClient(serverUrl);
    final terms = await client.getTermsOfService();
    return {'terms': terms};
  } catch (error) {
    logDebug('error on fetchTermsOfService', getFullErrorMessage(error));
    forceLogoutIfNecessary(serverUrl, error);
    return {'error': error};
  }
}

Future<Map<String, dynamic>> updateTermsOfServiceStatus(String serverUrl, String id, bool status) async {
  try {
    final client = NetworkManager.getClient(serverUrl);
    final resp = await client.updateMyTermsOfServiceStatus(id, status);

    final dbManager = DatabaseManager.getServerDatabaseAndOperator(serverUrl);
    final database = dbManager.database;
    final operator = dbManager.operator;
    final currentUser = await getCurrentUser(database);
    if (currentUser != null) {
      currentUser.prepareUpdate((u) {
        if (status) {
          u.termsOfServiceCreateAt = DateTime.now().millisecondsSinceEpoch;
          u.termsOfServiceId = id;
        } else {
          u.termsOfServiceCreateAt = 0;
          u.termsOfServiceId = '';
        }
      });
      await operator.batchRecords([currentUser], 'updateTermsOfServiceStatus');
    }
    return {'resp': resp};
  } catch (error) {
    logDebug('error on updateTermsOfServiceStatus', getFullErrorMessage(error));
    forceLogoutIfNecessary(serverUrl, error);
    return {'error': error};
  }
}
