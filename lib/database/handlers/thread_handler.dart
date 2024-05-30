// Converted Dart code from TypeScript

import 'package:watermelondb/watermelondb.dart';
import 'package:watermelondb/decorators.dart';
import 'package:mattermost_flutter/constants/database.dart';
import 'package:mattermost_flutter/log.dart';
import 'package:mattermost_flutter/types/database.dart';
import 'package:mattermost_flutter/types/thread.dart';
import 'package:mattermost_flutter/types/thread_in_team.dart';
import 'package:mattermost_flutter/types/thread_participant.dart';

const THREAD = MM_TABLES.SERVER['THREAD'];
const THREAD_PARTICIPANT = MM_TABLES.SERVER['THREAD_PARTICIPANT'];
const THREADS_IN_TEAM = MM_TABLES.SERVER['THREADS_IN_TEAM'];

mixin ThreadHandlerMixin on ServerDataOperatorBase {
  Future<List<Model>> handleThreads({required List<Thread> threads, String? teamId, bool prepareRecordsOnly = false}) async {
    if (threads.isEmpty) {
      logWarning('An empty or undefined "threads" array has been passed to the handleThreads method');
      return [];
    }

    final uniqueThreads = getUniqueRawsBy<Thread>(raws: threads, key: 'id');

    final deletedThreadIds = <String>[];
    final createOrUpdateThreads = <Thread>[];
    for (final thread in uniqueThreads) {
      if (thread.deleteAt > 0) {
        deletedThreadIds.add(thread.id);
      } else {
        createOrUpdateThreads.add(thread);
      }
    }

    if (deletedThreadIds.isNotEmpty) {
      final database = this.database;
      final threadsToDelete = await database.get<ThreadModel>(THREAD).query(Q.where('id', Q.oneOf(deletedThreadIds))).fetch();
      if (threadsToDelete.isNotEmpty) {
        await database.write(() async {
          for (final thread in threadsToDelete) {
            await thread.destroyPermanently();
            await thread.threadsInTeam.destroyAllPermanently();
            await thread.participants.destroyAllPermanently();
          }
        });
      }
    }

    if (createOrUpdateThreads.isEmpty) {
      return [];
    }

    final threadsParticipants = <ParticipantsPerThread>[];

    for (final thread in createOrUpdateThreads) {
      if (thread.participants != null) {
        threadsParticipants.add(ParticipantsPerThread(
          threadId: thread.id,
          participants: thread.participants!.map((participant) => ThreadParticipant(
            id: participant.id,
            threadId: thread.id,
          )).toList(),
        ));
      }
    }

    final preparedThreads = await handleRecords(
      fieldName: 'id',
      transformer: transformThreadRecord,
      prepareRecordsOnly: true,
      createOrUpdateRawValues: createOrUpdateThreads,
      tableName: THREAD,
      shouldUpdate: shouldUpdateThreadRecord,
    );

    final batch = <Model>[...preparedThreads];

    final threadParticipants = await handleThreadParticipants(threadsParticipants: threadsParticipants, prepareRecordsOnly: true);
    batch.addAll(threadParticipants);

    if (teamId != null) {
      final threadsInTeam = await handleThreadInTeam(threadsMap: {teamId: threads}, prepareRecordsOnly: true);
      batch.addAll(threadsInTeam);
    }

    if (batch.isNotEmpty && !prepareRecordsOnly) {
      await batchRecords(batch, 'handleThreads');
    }

    return batch;
  }

  Future<List<ThreadParticipantModel>> handleThreadParticipants({
    required List<ParticipantsPerThread> threadsParticipants,
    bool prepareRecordsOnly = false,
    bool skipSync = false,
  }) async {
    final batchRecords = <ThreadParticipantModel>[];

    for (final threadParticipant in threadsParticipants) {
      final rawValues = getUniqueRawsBy<ThreadParticipant>(raws: threadParticipant.participants, key: 'id');
      final sanitizedData = await sanitizeThreadParticipants(
        database: this.database,
        threadId: threadParticipant.threadId,
        rawParticipants: rawValues,
        skipSync: skipSync,
      );

      if (sanitizedData.createParticipants.isNotEmpty) {
        final participantsRecords = await prepareRecords(
          createRaws: sanitizedData.createParticipants,
          transformer: transformThreadParticipantRecord,
          tableName: THREAD_PARTICIPANT,
        ) as List<ThreadParticipantModel>;
        batchRecords.addAll(participantsRecords);
      }

      if (sanitizedData.deleteParticipants.isNotEmpty) {
        batchRecords.addAll(sanitizedData.deleteParticipants);
      }
    }

    if (prepareRecordsOnly) {
      return batchRecords;
    }

    if (batchRecords.isNotEmpty) {
      await batchRecords(batchRecords, 'handleThreadParticipants');
    }

    return batchRecords;
  }

  Future<List<ThreadInTeamModel>> handleThreadInTeam({
    required Map<String, List<Thread>> threadsMap,
    bool prepareRecordsOnly = false,
  }) async {
    if (threadsMap.isEmpty) {
      logWarning('An empty or undefined "threadsMap" object has been passed to the handleReceivedPostForChannel method');
      return [];
    }

    final create = <ThreadInTeam>[];
    for (final teamId in threadsMap.keys) {
      final threadIds = threadsMap[teamId]!.map((thread) => thread.id).toList();
      final chunks = await this.database.get<ThreadInTeamModel>(THREADS_IN_TEAM).query(
        Q.where('team_id', teamId),
        Q.where('thread_id', Q.oneOf(threadIds)),
      ).fetch();
      final chunksMap = {for (var chunk in chunks) chunk.threadId: chunk};

      for (final thread in threadsMap[teamId]!) {
        if (!chunksMap.containsKey(thread.id)) {
          create.add(ThreadInTeam(
            threadId: thread.id,
            teamId: teamId,
          ));
        }
      }
    }

    final threadsInTeam = await prepareRecords(
      createRaws: getRawRecordPairs(create),
      transformer: transformThreadInTeamRecord,
      tableName: THREADS_IN_TEAM,
    ) as List<ThreadInTeamModel>;

    if (threadsInTeam.isNotEmpty && !prepareRecordsOnly) {
      await batchRecords(threadsInTeam, 'handleThreadInTeam');
    }

    return threadsInTeam;
  }
}
