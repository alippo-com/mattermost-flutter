// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:mattermost_flutter/constants/database.dart';
import 'package:mattermost_flutter/database/manager.dart';
import 'package:mattermost_flutter/database/operator/server_data_operator/transformers/category.dart';
import 'package:mattermost_flutter/types/server_data_operator.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

class MockServerDataOperator extends Mock implements ServerDataOperator {}

void main() {
  group('*** Operator: Category Handlers tests ***', () {
    late MockServerDataOperator operator;
    setUpAll(() async {
      await DatabaseManager.init(['baseHandler.test.com']);
      operator = MockServerDataOperator();
    });

    test('=> handleCategories: should write to the CATEGORY table', () async {
      final categories = [
        Category(
          id: 'kjlw9j1ttnxwig7tnqgebg7dtipno',
          collapsed: false,
          displayName: 'Test',
          muted: false,
          sortOrder: 1,
          sorting: 'recent',
          teamId: '',
          type: 'direct_messages',
        ),
      ];

      await operator.handleCategories(
        categories: categories,
        prepareRecordsOnly: false,
      );

      verify(operator.handleRecords(
        fieldName: 'id',
        createOrUpdateRawValues: categories,
        tableName: MM_TABLES.SERVER.CATEGORY,
        prepareRecordsOnly: false,
        transformer: transformCategoryRecord,
      )).called(1);
    });

    test('=> handleCategoryChannels: should write to the CATEGORY_CHANNEL table', () async {
      final categoryChannels = [
        CategoryChannel(
          id: 'team_id-channel_id',
          categoryId: 'kjlw9j1ttnxwig7tnqgebg7dtipno',
          channelId: 'channel-id',
          sortOrder: 1,
        ),
      ];

      await operator.handleCategoryChannels(
        categoryChannels: categoryChannels,
        prepareRecordsOnly: false,
      );

      verify(operator.handleRecords(
        fieldName: 'id',
        createOrUpdateRawValues: categoryChannels,
        tableName: MM_TABLES.SERVER.CATEGORY_CHANNEL,
        prepareRecordsOnly: false,
        transformer: transformCategoryChannelRecord,
      )).called(1);
    });
  });
}
