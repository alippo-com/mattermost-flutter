// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:mattermost_flutter/actions/local/systems.dart';
import 'package:mattermost_flutter/actions/remote/systems.dart';
import 'package:mattermost_flutter/database/manager.dart';
import 'package:mattermost_flutter/managers/websocket_manager.dart';
import 'package:mattermost_flutter/queries/servers/system.dart';
import 'package:mattermost_flutter/utils/file.dart';

import 'common.dart';

Future<Map<String, dynamic>> appEntry(String serverUrl, [int since = 0]) async {
  final operator = DatabaseManager.serverDatabases[serverUrl]?.operator;
  if (operator == null) {
    return {'error': '$serverUrl database not found'};
  }

  if (since == 0) {
    if (DatabaseManager.serverDatabases.keys.length == 1) {
      await setLastServerVersionCheck(serverUrl, true);
    }
  }

  // clear lastUnreadChannelId
  final removeLastUnreadChannelId = await prepareCommonSystemValues(operator, {'lastUnreadChannelId': ''});
  if (removeLastUnreadChannelId != null) {
    await operator.batchRecords(removeLastUnreadChannelId, 'appEntry - removeLastUnreadChannelId');
  }

  WebsocketManager.openAll();

  verifyPushProxy(serverUrl);

  return {};
}

Future<Map<String, dynamic>> upgradeEntry(String serverUrl) async {
  final dt = DateTime.now().millisecondsSinceEpoch;

  try {
    final configAndLicense = await fetchConfigAndLicense(serverUrl, fetchOnly: false);
    final entryData = await appEntry(serverUrl, 0);
    final error = configAndLicense.error ?? entryData['error'];

    if (error == null) {
      await DatabaseManager.updateServerIdentifier(serverUrl, configAndLicense.config!.diagnosticId);
      await DatabaseManager.setActiveServerDatabase(serverUrl);
      deleteV1Data();
    }

    return {'error': error, 'time': DateTime.now().millisecondsSinceEpoch - dt};
  } catch (e) {
    return {'error': e.toString(), 'time': DateTime.now().millisecondsSinceEpoch - dt};
  }
}
