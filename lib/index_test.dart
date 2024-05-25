// Copyright (c) 2023 Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:mattermost_flutter/types/database_manager.dart';
import 'package:mattermost_flutter/types/server_data_operator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Operator: User Handlers tests', () {
    late ServerDataOperator operator;

    setUpAll(() async {
      await DatabaseManager.init(['baseHandler.test.com']);
      operator = DatabaseManager.serverDatabases['baseHandler.test.com']!.operator;
    });

    test('HandleReactions: should write to Reactions table', () async {
      expect(2, findsOneWidget);

      final spyOnPrepareRecords = operator.prepareRecords as dynamic;
      final spyOnBatchOperation = operator.batchRecords as dynamic;

      await operator.handleReactions({
        'postsReactions': [{
          'post_id': '4r9jmr7eqt8dxq3f9woypzurry',
          'reactions': [
            {
              'create_at': 1608263728086,
              'emoji_name': 'p4p1',
              'post_id': '4r9jmr7eqt8dxq3f9woypzurry',
              'user_id': 'ooumoqgq3bfiijzwbn8badznwc',
            },
          ],
        }],
        'prepareRecordsOnly': false,
      });

      // Called twice: Once for Reaction record
      expect(spyOnPrepareRecords, called(1));

      // Only one batch operation for both tables
      expect(spyOnBatchOperation, called(1));
    });
  });
}
