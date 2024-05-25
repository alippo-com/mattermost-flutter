// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:nozbe_watermelondb/watermelondb.dart';
import 'package:mattermost_flutter/constants/database.dart';
import 'package:mattermost_flutter/database/operator/server_data_operator/transformers/thread.dart';
import 'package:mattermost_flutter/database/operator/utils/general.dart';
import 'package:mattermost_flutter/utils/log.dart';

import 'server_data_operator_base.dart';
import 'package:mattermost_flutter/types/database/database.dart';
import 'package:mattermost_flutter/types/database/models/servers/team_threads_sync.dart';

abstract class TeamThreadsSyncHandlerMix {
  Future<List<TeamThreadsSyncModel>> handleTeamThreadsSync({required HandleTeamThreadsSyncArgs data, bool prepareRecordsOnly = false});
}

class TeamThreadsSyncHandler<TBase extends ServerDataOperatorBase> extends TBase implements TeamThreadsSyncHandlerMix {
  @override
  Future<List<TeamThreadsSyncModel>> handleTeamThreadsSync({required HandleTeamThreadsSyncArgs data, bool prepareRecordsOnly = false}) async {
    if (data.isEmpty) {
      logWarning('An empty or undefined "data" array has been passed to the handleTeamThreadsSync method');
      return [];
    }

    final uniqueRaws = getUniqueRawsBy(raws: data, key: 'id') as List<TeamThreadsSync>;
    final ids = uniqueRaws.map((item) => item.id).toList();
    final chunks = await (database as Database).get<TeamThreadsSyncModel>(MM_TABLES_SERVER.TEAM_THREADS_SYNC).query(
      Q.where('id', Q.oneOf(ids)),
    ).fetch();
    final chunksMap = Map<String, TeamThreadsSyncModel>.fromIterable(chunks, key: (chunk) => chunk.id);

    final create = <TeamThreadsSync>[];
    final update = <RecordPair>[];

    for (final item in uniqueRaws) {
      final id = item.id;
      final chunk = chunksMap[id];
      if (chunk != null) {
        update.add(getValidRecordsForUpdate(
          tableName: MM_TABLES_SERVER.TEAM_THREADS_SYNC,
          newValue: item,
          existingRecord: chunk,
        ));
      } else {
        create.add(item);
      }
    }

    final models = await prepareRecords(
      createRaws: getRawRecordPairs(create),
      updateRaws: update,
      transformer: transformTeamThreadsSyncRecord,
      tableName: MM_TABLES_SERVER.TEAM_THREADS_SYNC,
    ) as List<TeamThreadsSyncModel>;

    if (models.isNotEmpty && !prepareRecordsOnly) {
      await batchRecords(models, 'handleTeamThreadsSync');
    }

    return models;
  }
}
