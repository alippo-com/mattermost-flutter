// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:mattermost_flutter/queries/app/info.dart';
import 'package:mattermost_flutter/utils/log.dart';
import 'package:mattermost_flutter/types/manager.dart';
import 'package:mattermost_flutter/types/info.dart';

Future<void> beforeUpgrade(List<String> serverUrls, String versionNumber, String buildNumber) async {
  final info = await getLastInstalledVersion();
  final DatabaseManager? manager = this.serverDatabases != null ? this : null;
  if (manager != null && serverUrls.isNotEmpty && info != null && (versionNumber != info.versionNumber || buildNumber != info.buildNumber)) {
    await beforeUpgradeTo450(manager, serverUrls, info);
  }
}

Future<void> beforeUpgradeTo450(DatabaseManager manager, List<String> serverUrls, InfoModel info) async {
  try {
    final buildNumber = int.parse(info.buildNumber);
    if (info.versionNumber == '2.0.0' && buildNumber < 450) {
      for (final serverUrl in serverUrls) {
        logInfo('Remove database before upgrading for $serverUrl');
        await manager.deleteServerDatabaseFiles(serverUrl);
      }
    }
  } catch (e) {
    logError('Error running the upgrade before build 450', e);
  }
}
