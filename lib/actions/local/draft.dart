// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:mattermost_flutter/database/manager.dart';
import 'package:mattermost_flutter/queries/servers/file.dart';
import 'package:mattermost_flutter/utils/log.dart';
import 'package:mattermost_flutter/types/file_info.dart';

Future<Map<String, dynamic>> updateLocalFile(String serverUrl, FileInfo file) async {
  try {
    final databaseAndOperator = await DatabaseManager.getServerDatabaseAndOperator(serverUrl);
    final operator = databaseAndOperator['operator'];
    return await operator.handleFiles(files: [file], prepareRecordsOnly: false);
  } catch (error) {
    logError('Failed updateLocalFile', error);
    return {'error': error};
  }
}

Future<Map<String, dynamic>> updateLocalFilePath(String serverUrl, String fileId, String localPath) async {
  try {
    final databaseAndOperator = await DatabaseManager.getServerDatabaseAndOperator(serverUrl);
    final database = databaseAndOperator['database'];
    final file = await getFileById(database, fileId);
    if (file != null) {
      await database.write(() async {
        await file.update((r) {
          r.localPath = localPath;
        });
      });
    }

    return {'error': null};
  } catch (error) {
    logError('Failed updateLocalFilePath', error);
    return {'error': error};
  }
}
