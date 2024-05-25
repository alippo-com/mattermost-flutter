// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:mattermost_flutter/constants/database.dart';
import 'package:mattermost_flutter/database/manager.dart';
import 'package:mattermost_flutter/database/operator/server_data_operator/transformers/group.dart';
import 'package:mattermost_flutter/types/server_data_operator.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

class MockServerDataOperator extends Mock implements ServerDataOperator {}

void main() {
  group('*** Operator: Group Handlers tests ***', () {
    late MockServerDataOperator operator;
    setUpAll(() async {
      await DatabaseManager.init(['baseHandler.test.com']);
      operator = MockServerDataOperator();
    });

    test('=> handleGroups: should write to the GROUP table', () async {
      final groups = [
        Group(
          id: 'kjlw9j1ttnxwig7tnqgebg7dtipno',
          name: 'test',
          displayName: 'Test',
          source: 'custom',
          remoteId: 'iuh4r89egnslnvakjsdjhg',
          description: 'Test description',
          memberCount: 0,
          allowReference: true,
          createAt: 0,
          updateAt: 0,
          deleteAt: 0,
        ),
      ];

      await operator.handleGroups(
        groups: groups,
        prepareRecordsOnly: false,
      );

      verify(operator.handleRecords(
        fieldName: 'id',
        createOrUpdateRawValues: groups,
        tableName: MM_TABLES.SERVER.GROUP,
        prepareRecordsOnly: false,
        transformer: transformGroupRecord,
      )).called(1);
    });
  });
}
