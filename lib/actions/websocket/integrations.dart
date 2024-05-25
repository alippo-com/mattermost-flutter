// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'dart:convert';
import 'package:mattermost_flutter/managers/integrations_manager.dart';
import 'package:mattermost_flutter/queries/app/servers.dart';

Future<void> handleOpenDialogEvent(String serverUrl, WebSocketMessage msg) async {
  final data = msg.data?.dialog;
  if (data == null) {
    return;
  }

  try {
    final dialog = jsonDecode(data) as InteractiveDialogConfig;
    final currentServer = await getActiveServerUrl();
    if (currentServer == serverUrl) {
      IntegrationsManager.getManager(serverUrl).setDialog(dialog);
    }
  } catch (e) {
    print('Error handling open dialog event: $e');
  }
}
