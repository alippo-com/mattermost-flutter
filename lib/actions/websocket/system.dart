
import 'dart:convert';

import 'package:mattermost_flutter/actions/local/channel.dart';
import 'package:mattermost_flutter/actions/local/systems.dart';
import 'package:mattermost_flutter/constants/database.dart';
import 'package:mattermost_flutter/database/manager.dart';

Future<void> handleLicenseChangedEvent(String serverUrl, WebSocketMessage msg) async {
  try {
    final databaseAndOperator = DatabaseManager.getServerDatabaseAndOperator(serverUrl);
    final database = databaseAndOperator.database;
    final operator = databaseAndOperator.operator;

    final license = msg.data['license'];
    final systems = [
      {'id': SYSTEM_IDENTIFIERS.LICENSE, 'value': jsonEncode(license)},
    ];

    final prevLicense = await getLicense(database);
    await operator.handleSystem(systems: systems, prepareRecordsOnly: false);

    if (license['LockTeammateNameDisplay'] != null &&
        prevLicense['LockTeammateNameDisplay'] != license['LockTeammateNameDisplay']) {
      updateDmGmDisplayName(serverUrl);
    }
  } catch (e) {
    // do nothing
  }
}

Future<void> handleConfigChangedEvent(String serverUrl, WebSocketMessage msg) async {
  try {
    final databaseAndOperator = DatabaseManager.getServerDatabaseAndOperator(serverUrl);
    final database = databaseAndOperator.database;

    final config = msg.data['config'];
    final prevConfig = await getConfig(database);
    await storeConfig(serverUrl, config);

    if (config['LockTeammateNameDisplay'] != null &&
        prevConfig['LockTeammateNameDisplay'] != config['LockTeammateNameDisplay']) {
      updateDmGmDisplayName(serverUrl);
    }
  } catch (e) {
    // do nothing
  }
}
