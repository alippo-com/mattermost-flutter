// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter_test/flutter_test.dart';
import 'package:mattermost_flutter/screens/integration_selector/selected_options.dart';
import 'package:mattermost_flutter/test_helpers/test_helper.dart';
import 'package:mattermost_flutter/types/database/models/servers/database.dart';

void main() {
  group('components/integration_selector/selected_options', () {
    late Database database;

    setUpAll(() async {
      final server = await TestHelper.setupServerDatabase();
      database = server.database;
    });

    testWidgets('should match snapshot for users', (WidgetTester tester) async {
      final userProfile = {
        'id': '1',
        'create_at': 1111,
        'update_at': 1111,
        'delete_at': 1111,
        'username': 'johndoe',
        'nickname': 'johndoe',
        'first_name': 'johndoe',
        'last_name': 'johndoe',
        'position': 'hacker',
        'roles': 'admin',
        'locale': 'en_US',
        'notify_props': {
          'channel': 'true',
          'comments': 'never',
          'desktop': 'all',
          'desktop_sound': 'true',
          'email': 'true',
          'first_name': 'true',
          'mention_keys': 'false',
          'highlight_keys': '',
          'push': 'mention',
          'push_status': 'ooo',
        },
        'email': 'johndoe@me.com',
        'auth_service': 'dummy',
      };

      await tester.pumpWidget(
        SelectedOptions(
          theme: Preferences.themes['denim'],
          selectedOptions: [userProfile],
          dataSource: ViewConstants.DATA_SOURCE_USERS,
          onRemove: () {
            // noop
          },
        ),
      );

      expect(find.byType(SelectedOptions), matchesGoldenFile('selected_options_users.png'));
    });

    testWidgets('should match snapshot for channels', (WidgetTester tester) async {
      final channel = {
        'id': '1',
        'create_at': 1111,
        'update_at': 1111,
        'delete_at': 0,
        'team_id': 'my team',
        'type': 'O',
        'display_name': 'channel',
        'name': 'channel',
        'header': 'channel',
        'purpose': '',
        'last_post_at': 1,
        'total_msg_count': 1,
        'extra_update_at': 1,
        'creator_id': '1',
        'scheme_id': null,
        'group_constrained': null,
        'shared': true,
      };

      await tester.pumpWidget(
        SelectedOptions(
          theme: Preferences.themes['denim'],
          selectedOptions: [channel],
          dataSource: ViewConstants.DATA_SOURCE_CHANNELS,
          onRemove: () {
            // noop
          },
        ),
      );

      expect(find.byType(SelectedOptions), matchesGoldenFile('selected_options_channels.png'));
    });

    testWidgets('should match snapshot for options', (WidgetTester tester) async {
      final myItem = {
        'value': '1',
        'text': 'my text',
      };

      await tester.pumpWidget(
        SelectedOptions(
          theme: Preferences.themes['denim'],
          selectedOptions: [myItem],
          dataSource: ViewConstants.DATA_SOURCE_DYNAMIC,
          onRemove: () {
            // noop
          },
        ),
      );

      expect(find.byType(SelectedOptions), matchesGoldenFile('selected_options_options.png'));
    });
  });
}
