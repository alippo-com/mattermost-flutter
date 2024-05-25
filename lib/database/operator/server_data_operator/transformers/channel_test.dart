
// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:mattermost_flutter/types/constants.dart';
import 'package:mattermost_flutter/database/operator/server_data_operator/transformers/channel.dart';
import 'package:mattermost_flutter/database/operator/utils/create_test_connection.dart';

void main() {
  group('*** CHANNEL Prepare Records Test ***', () {
    test('=> transformChannelRecord: should return an array of type Channel', () async {
      expect(3);

      final database = await createTestConnection(databaseName: 'channel_prepare_records', setActive: true);
      expect(database != null);

      final preparedRecords = await transformChannelRecord(
        action: OperationType.CREATE,
        database: database!,
        value: {
          'record': null,
          'raw': {
            'id': 'kow9j1ttnxwig7tnqgebg7dtipno',
            'create_at': 1600185541285,
            'update_at': 1604401077256,
            'delete_at': 0,
            'team_id': '',
            'type': 'D',
            'display_name': '',
            'name': 'jui1zkzkhh357b4bejephjz5u8daw__9ciscaqbrpd6d8s68k76xb9bte',
            'header': 'https://mattermost)',
            'purpose': '',
            'last_post_at': 1617311494451,
            'total_msg_count': 585,
            'extra_update_at': 0,
            'creator_id': '',
            'scheme_id': null,
            'group_constrained': null,
            'shared': false,
          },
        }
      );

      expect(preparedRecords != null);
      expect(preparedRecords.collection.table == 'Channel');
    });

    test('=> transformMyChannelSettingsRecord: should return an array of type MyChannelSettings', () async {
      expect(3);

      final database = await createTestConnection(databaseName: 'channel_prepare_records', setActive: true);
      expect(database != null);

      final raw = {
        'channel_id': 'c',
        'user_id': 'me',
        'roles': '',
        'last_viewed_at': 0,
        'msg_count': 0,
        'mention_count': 0,
        'last_update_at': 0,
        'notify_props': {
          'desktop': 'default',
          'email': 'default',
          'push': 'mention',
          'mark_unread': 'mention',
          'ignore_channel_mentions': 'default',
        },
      };

      final preparedRecords = await transformMyChannelSettingsRecord(
        action: OperationType.CREATE,
        database: database!,
        value: {
          'record': null,
          'raw': raw,
        }
      );

      expect(preparedRecords != null);
      expect(preparedRecords.collection.table == 'MyChannelSettings');
    });

    test('=> transformChannelInfoRecord: should return an array of type ChannelInfo', () async {
      expect(3);

      final database = await createTestConnection(databaseName: 'channel_prepare_records', setActive: true);
      expect(database != null);

      final preparedRecords = await transformChannelInfoRecord(
        action: OperationType.CREATE,
        database: database!,
        value: {
          'record': null,
          'raw': {
            'id': 'c',
            'channel_id': 'c',
            'guest_count': 10,
            'header': 'channel info header',
            'member_count': 10,
            'pinned_post_count': 3,
            'files_count': 0,
            'purpose': 'sample channel ',
          },
        }
      );

      expect(preparedRecords != null);
      expect(preparedRecords.collection.table == 'ChannelInfo');
    });

    test('=> transformMyChannelRecord: should return an array of type MyChannel', () async {
      expect(3);

      final database = await createTestConnection(databaseName: 'channel_prepare_records', setActive: true);
      expect(database != null);

      final preparedRecords = await transformMyChannelRecord(
        action: OperationType.CREATE,
        database: database!,
        value: {
          'record': null,
          'raw': {
            'channel_id': 'cd',
            'user_id': 'guest',
            'last_post_at': 1617311494451,
            'last_viewed_at': 1617311494451,
            'last_update_at': 0,
            'mention_count': 3,
            'msg_count': 10,
            'roles': 'guest',
            'notify_props': {},
          },
        }
      );

      expect(preparedRecords != null);
      expect(preparedRecords.collection.table == 'MyChannel');
    });

    test('=> transformChannelMembershipRecord: should return an array of type ChannelMembership', () async {
      expect(3);

      final database = await createTestConnection(databaseName: 'user_prepare_records', setActive: true);
      expect(database != null);

      final preparedRecords = await transformChannelMembershipRecord(
        action: OperationType.CREATE,
        database: database!,
        value: {
          'record': null,
          'raw': {
            'channel_id': '17bfnb1uwb8epewp4q3x3rx9go',
            'user_id': '9ciscaqbrpd6d8s68k76xb9bte',
            'roles': 'wqyby5r5pinxxdqhoaomtacdhc',
            'last_viewed_at': 1613667352029,
            'msg_count': 3864,
            'mention_count': 0,
            'notify_props': {
              'desktop': 'default',
              'email': 'default',
              'ignore_channel_mentions': 'default',
              'mark_unread': 'mention',
              'push': 'default',
            },
            'last_update_at': 1613667352029,
            'scheme_user': true,
            'scheme_admin': false,
          },
        }
      );

      expect(preparedRecords != null);
      expect(preparedRecords.collection.table == 'ChannelMembership');
    });
  });
}
