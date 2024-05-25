
// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:mattermost_flutter/types/test/test_helper.dart';
import 'package:mattermost_flutter/screens/home/channel_list/categories_list/categories/unreads/unreads.dart';
import 'package:mattermost_flutter/types/database/database.dart';

void main() {
  group('components/channel_list/categories/body', () {
    late Database database;

    setUpAll(() async {
      final server = await TestHelper.setupServerDatabase();
      database = server.database;
    });

    testWidgets('do not render when there are no unread channels', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            Provider<Database>.value(value: database),
          ],
          child: const UnreadsCategory(
            unreadChannels: [],
            onChannelSwitch: () => null,
            onlyUnreads: false,
            unreadThreads: {"unreads": false, "mentions": 0},
          ),
        ),
      );

      expect(find.byType(UnreadsCategory), findsNothing);
    });
  });
}
