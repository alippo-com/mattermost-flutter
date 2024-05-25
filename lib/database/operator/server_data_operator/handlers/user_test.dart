// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:mattermost_flutter/database/manager.dart';
import 'package:mattermost_flutter/database/operator/server_data_operator/comparators.dart';
import 'package:mattermost_flutter/database/operator/server_data_operator/comparators/user.dart';
import 'package:mattermost_flutter/database/operator/server_data_operator/transformers/user.dart';
import 'package:mattermost_flutter/types/server_data_operator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('*** Operator: User Handlers tests ***', () {
    late ServerDataOperator operator;

    setUpAll(() async {
      await DatabaseManager.init(['baseHandler.test.com']);
      operator = DatabaseManager.serverDatabases['baseHandler.test.com']!.operator;
    });

    test('=> HandleReactions: should write to Reactions table', () async {
      expectAssertions(2);

      final spyOnPrepareRecords = spyOn(operator, 'prepareRecords');
      final spyOnBatchOperation = spyOn(operator, 'batchRecords');

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
      expect(spyOnPrepareRecords).toHaveBeenCalledTimes(1);

      // Only one batch operation for both tables
      expect(spyOnBatchOperation).toHaveBeenCalledTimes(1);
    });

    test('=> HandleUsers: should write to the User table', () async {
      expectAssertions(2);

      final users = [
        UserProfile(
          id: '9ciscaqbrpd6d8s68k76xb9bte',
          createAt: 1599457495881,
          updateAt: 1607683720173,
          deleteAt: 0,
          username: 'a.l',
          authService: 'saml',
          email: 'a.l@mattermost.com',
          emailVerified: true,
          isBot: false,
          nickname: '',
          firstName: 'A',
          lastName: 'L',
          position: 'Mobile Engineer',
          roles: 'system_user',
          props: {},
          notifyProps: NotifyProps(
            desktop: 'all',
            desktopSound: 'true',
            email: 'true',
            firstName: 'true',
            markUnread: 'mention',
            mentionKeys: '',
            highlightKeys: '',
            push: 'mention',
            channel: 'true',
            autoResponderActive: 'false',
            autoResponderMessage: 'Hello, I am out of office and unable to respond to messages.',
            comments: 'never',
            desktopNotificationSound: 'Hello',
            pushStatus: 'online',
          ),
          lastPictureUpdate: 1604686302260,
          locale: 'en',
          timezone: Timezone(
            automaticTimezone: 'Indian/Mauritius',
            manualTimezone: '',
            useAutomaticTimezone: '',
          ),
        ),
      ];

      final spyOnHandleRecords = spyOn(operator, 'handleRecords');

      await operator.handleUsers({'users': users, 'prepareRecordsOnly': false});

      expect(spyOnHandleRecords).toHaveBeenCalledTimes(1);
      expect(spyOnHandleRecords).toHaveBeenCalledWith({
        'fieldName': 'id',
        'createOrUpdateRawValues': users,
        'tableName': 'User',
        'prepareRecordsOnly': false,
        'transformer': transformUserRecord,
        'shouldUpdate': shouldUpdateUserRecord,
      }, 'handleUsers');
    });

    test('=> HandlePreferences: should write to the PREFERENCE table', () async {
      expectAssertions(2);

      final spyOnHandleRecords = spyOn(operator, 'handleRecords');
      final preferences = [
        Preference(
          userId: '9ciscaqbrpd6d8s68k76xb9bte',
          category: 'group_channel_show',
          name: 'qj91hepgjfn6xr4acm5xzd8zoc',
          value: 'true',
        ),
        Preference(
          userId: '9ciscaqbrpd6d8s68k76xb9bte',
          category: 'notifications',
          name: 'email_interval',
          value: '30',
        ),
        Preference(
          userId: '9ciscaqbrpd6d8s68k76xb9bte',
          category: 'theme',
          name: '',
          value:
              '{"awayIndicator":"#c1b966","buttonBg":"#4cbba4","buttonColor":"#ffffff","centerChannelBg":"#2f3e4e","centerChannelColor":"#dddddd","codeTheme":"solarized-dark","dndIndicator":"#e81023","errorTextColor":"#ff6461","image":"/static/files/0b8d56c39baf992e5e4c58d74fde0fd6.png","linkColor":"#a4ffeb","mentionBg":"#b74a4a","mentionColor":"#ffffff","mentionHighlightBg":"#984063","mentionHighlightLink":"#a4ffeb","newMessageSeparator":"#5de5da","onlineIndicator":"#65dcc8","sidebarBg":"#1b2c3e","sidebarHeaderBg":"#1b2c3e","sidebarHeaderTextColor":"#ffffff","sidebarText":"#ffffff","sidebarTextActiveBorder":"#66b9a7","sidebarTextActiveColor":"#ffffff","sidebarTextHoverBg":"#4a5664","sidebarUnreadText":"#ffffff","type":"Mattermost Dark"}',
        ),
        Preference(
          userId: '9ciscaqbrpd6d8s68k76xb9bte',
          category: 'tutorial_step', // we aren't using this category in the app, should be filtered
          name: '9ciscaqbrpd6d8s68k76xb9bte',
          value: '2',
        ),
      ];

      await operator.handlePreferences({
        'preferences': preferences,
        'prepareRecordsOnly': false,
        'sync': false,
      });

      expect(spyOnHandleRecords).toHaveBeenCalledTimes(1);
      expect(spyOnHandleRecords).toHaveBeenCalledWith({
        'fieldName': 'user_id',
        'createOrUpdateRawValues': preferences.where((p) => p.category != 'tutorial_step').toList(),
        'tableName': 'Preference',
        'prepareRecordsOnly': true,
        'buildKeyRecordBy': buildPreferenceKey,
        'transformer': transformPreferenceRecord,
      }, 'handlePreferences(NEVER)');
    });
  });
}
