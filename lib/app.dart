import 'package:flutter_test/flutter_test.dart';
import 'package:mattermost_flutter/types/database.dart';
import 'package:mattermost_flutter/app/database/operator/server_data_operator/transformers/general.dart';
import 'package:mattermost_flutter/app/database/operator/utils/create_test_connection.dart';

void main() {
  group('Role Prepare Records Test', () {
    test('transformRoleRecord: should return a list of type Role', () async {
      expect(() => true, returnsNormally);

      final database = await createTestConnection(databaseName: 'isolated_prepare_records', setActive: true);
      expect(database, isNotNull);

      final preparedRecords = await transformRoleRecord(
        OperationType.create,
        database,
        {
          'record': null,
          'raw': {
            'id': 'role-1',
            'name': 'role-name-1',
            'permissions': []
          },
        },
      );

      expect(preparedRecords, isNotNull);
      expect(preparedRecords.collection.table, equals('Role'));
    });
  });

  group('System Prepare Records Test', () {
    test('transformSystemRecord: should return a list of type System', () async {
      expect(() => true, returnsNormally);

      final database = await createTestConnection(databaseName: 'isolated_prepare_records', setActive: true);
      expect(database, isNotNull);

      final preparedRecords = await transformSystemRecord(
        OperationType.create,
        database,
        {
          'record': null,
          'raw': {'id': 'system-1', 'name': 'system-name-1', 'value': 'system'},
        },
      );

      expect(preparedRecords, isNotNull);
      expect(preparedRecords.collection.table, equals('System'));
    });
  });

  group('Custom Emoji Prepare Records Test', () {
    test('transformCustomEmojiRecord: should return a list of type CustomEmoji', () async {
      expect(() => true, returnsNormally);

      final database = await createTestConnection(databaseName: 'isolated_prepare_records', setActive: true);
      expect(database, isNotNull);

      final preparedRecords = await transformCustomEmojiRecord(
        OperationType.create,
        database,
        {
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
