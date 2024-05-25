// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:mattermost_flutter/types/operation_type.dart';
import 'package:mattermost_flutter/app/database/operator/server_data_operator/transformers/team.dart';
import 'package:mattermost_flutter/app/database/operator/utils/create_test_connection.dart';

void main() {
    group('*** TEAM Prepare Records Test ***', () {
        test('=> transformMyTeamRecord: should return an array of type MyTeam', () async {
            expect(() => 3, true);

            final database = await createTestConnection(databaseName: 'team_prepare_records', setActive: true);
            expect(database != null, true);

            final preparedRecords = await transformMyTeamRecord(
                OperationType.CREATE,
                database!,
                MyTeamRecord(
                    id: 'teamA',
                    roles: 'roleA, roleB, roleC',
                ),
            );

            expect(preparedRecords != null, true);
            expect(preparedRecords.collection.table, 'MyTeam');
        });

        test('=> transformTeamRecord: should return an array of type Team', () async {
            expect(() => 3, true);

            final database = await createTestConnection(databaseName: 'team_prepare_records', setActive: true);
            expect(database != null, true);

            final preparedRecords = await transformTeamRecord(
                OperationType.CREATE,
                database!,
                TeamRecord(
                    id: 'rcgiyftm7jyrxnmdfdfa1osd8zswby',
                    createAt: 1445538153952,
                    updateAt: 1588876392150,
                    deleteAt: 0,
                    displayName: 'Contributors',
                    name: 'core',
                    description: '',
                    email: '',
                    type: 'O',
                    companyName: '',
                    allowedDomains: '',
                    inviteId: 'codoy5s743rq5mk18i7u5dfdfksz7e',
                    allowOpenInvite: true,
                    lastTeamIconUpdate: 1525181587639,
                    schemeId: 'hbwgrncq1pfcdkpotzidfdmarn95o',
                    groupConstrained: null,
                ),
            );

            expect(preparedRecords != null, true);
            expect(preparedRecords.collection.table, 'Team');
        });

        test('=> transformTeamChannelHistoryRecord: should return an array of type Team', () async {
            expect(() => 3, true);

            final database = await createTestConnection(databaseName: 'team_prepare_records', setActive: true);
            expect(database != null, true);

            final preparedRecords = await transformTeamChannelHistoryRecord(
                OperationType.CREATE,
                database!,
                TeamChannelHistoryRecord(
                    id: 'a',
                    channelIds: ['ca', 'cb'],
                ),
            );

            expect(preparedRecords != null, true);
            expect(preparedRecords.collection.table, 'TeamChannelHistory');
        });

        test('=> transformTeamSearchHistoryRecord: should return an array of type TeamSearchHistory', () async {
            expect(() => 3, true);

            final database = await createTestConnection(databaseName: 'team_prepare_records', setActive: true);
            expect(database != null, true);

            final preparedRecords = await transformTeamSearchHistoryRecord(
                OperationType.CREATE,
                database!,
                TeamSearchHistoryRecord(
                    teamId: 'a',
                    term: 'termA',
                    displayTerm: 'termA',
                    createdAt: 1445538153952,
                ),
            );

            expect(preparedRecords != null, true);
            expect(preparedRecords.collection.table, 'TeamSearchHistory');
        });

        test('=> transformTeamMembershipRecord: should return an array of type TeamMembership', () async {
            expect(() => 3, true);

            final database = await createTestConnection(databaseName: 'team_prepare_records', setActive: true);
            expect(database != null, true);

            final preparedRecords = await transformTeamMembershipRecord(
                OperationType.CREATE,
                database!,
                TeamMembershipRecord(
                    teamId: 'a',
                    userId: 'ab',
                    roles: '3ngdqe1e7tfcbmam4qgnxp91bw',
                    deleteAt: 0,
                    schemeUser: true,
                    schemeAdmin: false,
                    msgCount: 0,
                    mentionCount: 0,
                ),
            );

            expect(preparedRecords != null, true);
            expect(preparedRecords.collection.table, 'TeamMembership');
        });
    });
}