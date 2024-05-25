// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:mattermost_flutter/database/manager.dart';
import 'package:mattermost_flutter/database/operator/server_data_operator/comparators/thread.dart';
import 'package:mattermost_flutter/database/operator/server_data_operator/transformers/thread.dart';
import 'package:mattermost_flutter/types/server_data_operator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('*** Operator: Thread Handlers tests ***', () {
    late ServerDataOperator operator;

    setUpAll(() async {
      await DatabaseManager.init(['baseHandler.test.com']);
      operator = DatabaseManager.serverDatabases['baseHandler.test.com']!.operator;
    });

    test('=> HandleThreads: should write to the Thread, ThreadParticipant, & ThreadsInTeam tables', () async {
      expectAssertions(4);

      final spyOnBatchOperation = spyOn(operator, 'batchRecords');
      final spyOnHandleRecords = spyOn(operator, 'handleRecords');
      final spyOnHandleThreadParticipants = spyOn(operator, 'handleThreadParticipants');
      final spyOnHandleThreadInTeam = spyOn(operator, 'handleThreadInTeam');

      final threads = [
        ThreadWithLastFetchedAt(
          id: 'thread-1',
          replyCount: 2,
          lastReplyAt: 123,
          lastViewedAt: 123,
          participants: [
            ThreadParticipant(id: 'user-1'),
          ],
          isFollowing: true,
          unreadReplies: 0,
          unreadMentions: 0,
          lastFetchedAt: 0,
        ),
      ];

      final threadsMap = {'team_id_1': threads};
      await operator.handleThreads({
        'threads': threads,
        'prepareRecordsOnly': false,
        'teamId': 'team_id_1',
      });

      expect(spyOnHandleRecords).toHaveBeenCalledWith(
        {
          'fieldName': 'id',
          'transformer': transformThreadRecord,
          'createOrUpdateRawValues': threads,
          'tableName': 'Thread',
          'prepareRecordsOnly': true,
          'shouldUpdate': shouldUpdateThreadRecord,
        },
        'handleThreads(NEVER)',
      );

      // Should handle participants
      expect(spyOnHandleThreadParticipants).toHaveBeenCalledWith(
        {
          'threadsParticipants': threads.map((thread) => {
            'thread_id': thread.id,
            'participants': thread.participants.map((participant) => {
              'id': participant.id,
              'thread_id': thread.id,
            }).toList(),
          }).toList(),
          'prepareRecordsOnly': true,
        },
      );

      expect(spyOnHandleThreadInTeam).toHaveBeenCalledWith(
        {
          'threadsMap': threadsMap,
          'prepareRecordsOnly': true,
        },
      );

      // Only one batch operation for both tables
      expect(spyOnBatchOperation).toHaveBeenCalledTimes(1);
    });

    test('=> HandleThreadParticipants: should write to the ThreadParticipant table', () async {
      expectAssertions(1);

      final spyOnPrepareRecords = spyOn(operator, 'prepareRecords');

      final threadsParticipants = [
        {
          'thread_id': 'thread-1',
          'participants': [
            {
              'id': 'user-1',
              'thread_id': 'thread-1',
            },
          ],
        },
      ];

      await operator.handleThreadParticipants({
        'threadsParticipants': threadsParticipants,
        'prepareRecordsOnly': false,
      });

      expect(spyOnPrepareRecords).toHaveBeenCalledWith(
        {
          'createRaws': [
            {
              'raw': threadsParticipants[0]['participants'][0],
            },
          ],
          'transformer': transformThreadParticipantRecord,
          'tableName': 'ThreadParticipant',
        },
      );
    });

    test('=> HandleThreadInTeam: should write to the ThreadsInTeam table', () async {
      expectAssertions(1);

      final spyOnPrepareRecords = spyOn(operator, 'prepareRecords');

      final team1Threads = [
        Thread(
          id: 'thread-1',
          replyCount: 2,
          lastReplyAt: 123,
          lastViewedAt: 123,
          participants: [
            ThreadParticipant(id: 'user-1'),
          ],
          isFollowing: true,
          unreadReplies: 0,
          unreadMentions: 0,
        ),
        Thread(
          id: 'thread-2',
          replyCount: 2,
          lastReplyAt: 123,
          lastViewedAt: 123,
          participants: [
            ThreadParticipant(id: 'user-1'),
          ],
          isFollowing: true,
          unreadReplies: 0,
          unreadMentions: 0,
        ),
      ];

      final team2Threads = [
        Thread(
          id: 'thread-2',
          replyCount: 2,
          lastReplyAt: 123,
          lastViewedAt: 123,
          participants: [
            ThreadParticipant(id: 'user-1'),
          ],
          isFollowing: true,
          unreadReplies: 2,
          unreadMentions: 0,
        ),
      ];

      final threadsMap = {
        'team_id_1': team1Threads,
        'team_id_2': team2Threads,
      };

      await operator.handleThreadInTeam({
        'threadsMap': threadsMap,
        'prepareRecordsOnly': false,
      });

      expect(spyOnPrepareRecords).toHaveBeenCalledWith(
        {
          'createRaws': [
            {
              'raw': {'team_id': 'team_id_1', 'thread_id': 'thread-2'},
              'record': null,
            },
            {
              'raw': {'team_id': 'team_id_2', 'thread_id': 'thread-2'},
              'record': null,
            },
          ],
          'transformer': transformThreadInTeamRecord,
          'tableName': 'ThreadsInTeam',
        },
      );
    });

    test('=> HandleTeamThreadsSync: should write to the TeamThreadsSync table', () async {
      expectAssertions(1);

      final spyOnPrepareRecords = spyOn(operator, 'prepareRecords');

      final data = [
        TeamThreadsSync(
          id: 'team_id_1',
          earliest: 100,
          latest: 200,
        ),
        TeamThreadsSync(
          id: 'team_id_2',
          earliest: 100,
          latest: 300,
        ),
      ];

      await operator.handleTeamThreadsSync({'data': data, 'prepareRecordsOnly': false});

      expect(spyOnPrepareRecords).toHaveBeenCalledWith(
        {
          'createRaws': [
            {
              'raw': {'id': 'team_id_1', 'earliest': 100, 'latest': 200},
            },
            {
              'raw': {'id': 'team_id_2', 'earliest': 100, 'latest': 300},
            },
          ],
          'updateRaws': [],
          'transformer': transformTeamThreadsSyncRecord,
          'tableName': 'TeamThreadsSync',
        },
      );
    });

    test('=> HandleTeamThreadsSync: should update the record in TeamThreadsSync table', () async {
      expectAssertions(1);

      final spyOnPrepareRecords = spyOn(operator, 'prepareRecords');

      final data = [
        TeamThreadsSync(
          id: 'team_id_1',
          earliest: 100,
          latest: 300,
        ),
      ];

      await operator.handleTeamThreadsSync({'data': data, 'prepareRecordsOnly': false});

      expect(spyOnPrepareRecords).toHaveBeenCalledWith(
        {
          'createRaws': [],
          'updateRaws': [
            {
              'raw': {'id': 'team_id_1', 'earliest': 100, 'latest': 300},
            },
          ],
          'transformer': transformTeamThreadsSyncRecord,
          'tableName': 'TeamThreadsSync',
        },
      );
    });
  });
}
