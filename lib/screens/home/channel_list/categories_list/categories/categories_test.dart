// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:mattermost_flutter/types/test/test_helper.dart';
import 'package:mattermost_flutter/screens/home/channel_list/categories_list/categories/categories.dart';

void main() {
  group('components/channel_list/categories', () {
    late Database database;

    setUpAll(() async {
      final server = await TestHelper.setupServerDatabase();
      database = server.database;
    });

    testWidgets('render without error', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            Provider<Database>.value(value: database),
          ],
          child: const Categories(),
        ),
      );

      expect(find.byType(Categories), findsOneWidget);
    });
  });
}
