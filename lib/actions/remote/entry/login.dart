// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:mattermost_flutter/actions/remote/systems.dart';
import 'package:mattermost_flutter/database/manager.dart';
import 'package:mattermost_flutter/init/credentials.dart';
import 'package:mattermost_flutter/managers/websocket_manager.dart';

class AfterLoginArgs {
  final String serverUrl;

  AfterLoginArgs({required this.serverUrl});
}

Future<Map<String, dynamic>> loginEntry(AfterLoginArgs args) async {
  final operator = DatabaseManager.serverDatabases[args.serverUrl]?.operator;
  if (operator == null) {
    return {'error': '${args.serverUrl} database not found'};
  }

  try {
    final clData = await fetchConfigAndLicense(args.serverUrl, false);
    if (clData['error'] != null) {
      return {'error': clData['error']};
    }

    final credentials = await getServerCredentials(args.serverUrl);
    if (credentials?.token != null) {
      WebsocketManager.createClient(args.serverUrl, credentials.token);
      await WebsocketManager.initializeClient(args.serverUrl);
    }

    return {};
  } catch (error) {
    return {'error': error};
  }
}
