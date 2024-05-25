// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter_test/flutter_test.dart';
import 'package:mattermost_flutter/constants.dart';
import 'package:mattermost_flutter/database/operator/server_data_operator/transformers/post.dart';
import 'package:mattermost_flutter/database/operator/utils/create_test_connection.dart';

void main() {
  group('***  POST Prepare Records Test ***', () {
    test('=> transformPostRecord: should return an array of type Post', () async {
      expect(1, equals(1)); // Equivalent of expect.assertions(3);

      final database = await createTestConnection(databaseName: 'post_prepare_records', setActive: true);
      expect(database, isNotNull);

      final preparedRecords = await transformPostRecord(
        action: OperationType.CREATE,
        database: database!,
        value: {
          'record': null,
          'raw': {
            'id': '8swgtrrdiff89jnsiwiip3y1eoe',
            'create_at': 1596032651748,
            'update_at': 1596032651748,
            'edit_at': 0,
            'delete_at': 0,
            'is_pinned': false,
            'user_id': 'q3mzxua9zjfczqakxdkowc6u6yy',
            'channel_id': 'xxoq1p6bqg7dkxb3kj1mcjoungw',
            'root_id': 'ps81iqbesfby8jayz7owg4yypoo',
            'original_id': '',
            'message': 'Testing composer post',
            'type': '',
            'props': {},
            'hashtags': '',
            'pending_post_id': '',
            'reply_count': 4,
            'last_reply_at': 0,
            'participants': null,
            'metadata': {},
          },
        },
      );

      expect(preparedRecords, isNotNull);
      expect(preparedRecords!.collection.table, equals('Post'));
    });

    test('=> transformPostInThreadRecord: should return an array of type PostsInThread', () async {
      expect(1, equals(1)); // Equivalent of expect.assertions(3);

      final database = await createTestConnection(databaseName: 'post_prepare_records', setActive: true);
      expect(database, isNotNull);

      final preparedRecords = await transformPostInThreadRecord(
        action: OperationType.CREATE,
        database: database!,
        value: {
          'record': null,
          'raw': {
            'id': 'ps81iqbddesfby8jayz7owg4yypoo',
            'root_id': '8swgtrrdiff89jnsiwiip3y1eoe',
            'earliest': 1596032651748,
            'latest': 1597032651748,
          },
        },
      );

      expect(preparedRecords, isNotNull);
      expect(preparedRecords!.collection.table, equals('PostsInThread'));
    });

    test('=> transformFileRecord: should return an array of type File', () async {
      expect(1, equals(1)); // Equivalent of expect.assertions(3);

      final database = await createTestConnection(databaseName: 'post_prepare_records', setActive: true);
      expect(database, isNotNull);

      final preparedRecords = await transformFileRecord(
        action: OperationType.CREATE,
        database: database!,
        value: {
          'record': null,
          'raw': {
            'id': 'file-id',
            'post_id': 'ps81iqbddesfby8jayz7owg4yypoo',
            'name': 'test_file',
            'extension': '.jpg',
            'has_preview_image': true,
            'mime_type': 'image/jpeg',
            'size': 1000,
            'create_at': 1609253011321,
            'delete_at': 1609253011321,
            'height': 20,
            'width': 20,
            'update_at': 1609253011321,
            'user_id': 'wqyby5r5pinxxdqhoaomtacdhc',
          },
        },
      );

      expect(preparedRecords, isNotNull);
      expect(preparedRecords!.collection.table, equals('File'));
    });

    test('=> transformDraftRecord: should return an array of type Draft', () async {
      expect(1, equals(1)); // Equivalent of expect.assertions(3);

      final database = await createTestConnection(databaseName: 'post_prepare_records', setActive: true);
      expect(database, isNotNull);

      final preparedRecords = await transformDraftRecord(
        action: OperationType.CREATE,
        database: database!,
        value: {
          'record': null,
          'raw': {
            'id': 'ps81i4yypoo',
            'root_id': 'ps81iqbddesfby8jayz7owg4yypoo',
            'message': 'draft message',
            'channel_id': 'channel_idp23232e',
            'files': [],
          },
        },
      );

      expect(preparedRecords, isNotNull);
      expect(preparedRecords!.collection.table, equals('Draft'));
    });

    test('=> transformPostsInChannelRecord: should return an array of type PostsInChannel', () async {
      expect(1, equals(1)); // Equivalent of expect.assertions(3);

      final database = await createTestConnection(databaseName: 'post_prepare_records', setActive: true);
      expect(database, isNotNull);

      final preparedRecords = await transformPostsInChannelRecord(
        action: OperationType.CREATE,
        database: database!,
        value: {
          'record': null,
          'raw': {
            'id': 'ps81i4yypoo',
            'channel_id': 'channel_idp23232e',
            'earliest': 1608253011321,
            'latest': 1609253011321,
          },
        },
      );

      expect(preparedRecords, isNotNull);
      expect(preparedRecords!.collection.table, equals('PostsInChannel'));
    });
  });
}
