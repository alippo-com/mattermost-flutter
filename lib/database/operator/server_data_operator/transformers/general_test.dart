// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:mattermost_flutter/types/operation_type.dart';
import 'package:mattermost_flutter/database/operator/server_data_operator/transformers/general.dart';
import 'package:mattermost_flutter/database/operator/utils/create_test_connection.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Role Prepare Records Test', () {
    test('transformRoleRecord: should return an array of type Role', () async {
      expect(await createTestConnection(databaseName: 'isolated_prepare_records', setActive: true), isNotNull);

      final preparedRecords = await transformRoleRecord(
        action: OperationType.CREATE,
        database: database,
        value: {
          'record': null,
          'raw': {
            'id': 'role-1',
            'name': 'role-name-1',
            'permissions': [],
          },
        },
      );

      expect(preparedRecords, isNotNull);
      expect(preparedRecords.collection.table, equals('Role'));
    });
  });

  group('System Prepare Records Test', () {
    test('transformSystemRecord: should return an array of type System', () async {
      expect(await createTestConnection(databaseName: 'isolated_prepare_records', setActive: true), isNotNull);

      final preparedRecords = await transformSystemRecord(
        action: OperationType.CREATE,
        database: database,
        value: {
          'record': null,
          'raw': {'id': 'system-1', 'name': 'system-name-1', 'value': 'system'},
        },
      );

      expect(preparedRecords, isNotNull);
      expect(preparedRecords.collection.table, equals('System'));
    });
  });

  group('CustomEmoji Prepare Records Test', () {
    test('transformCustomEmojiRecord: should return an array of type CustomEmoji', () async {
      expect(await createTestConnection(databaseName: 'isolated_prepare_records', setActive: true), isNotNull);

      final preparedRecords = await transformCustomEmojiRecord(
        action: OperationType.CREATE,
        database: database,
        value: {
          'record': null,
          'raw': {
            'id': 'i',
            'create_at': 1580913641769,
            'update_at': 1580913641769,
            'delete_at': 0,
            'creator_id': '4cprpki7ri81mbx8efixcsb8jo',
            'name': 'boomI',
          },
        },
      );

      expect(preparedRecords, isNotNull);
      expect(preparedRecords.collection.table, equals('CustomEmoji'));
    });
  });
}
