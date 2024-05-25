// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter_test/flutter_test.dart';
import 'package:your_flutter_project/constants.dart';
import 'package:your_flutter_project/i18n.dart';
import 'package:your_flutter_project/models/category_model.dart';
import 'package:your_flutter_project/components/category_body.dart';
import 'package:your_flutter_project/test_helpers.dart';

void main() {
  group('components/channel_list/categories/body', () {
    late Database database;
    late CategoryModel category;

    setUp(() async {
      final server = await TestHelper.setupServerDatabase();
      database = server.database;

      final categories = await database.get<CategoryModel>(CATEGORY).query(
        Q.take(1),
      ).fetch();

      category = categories[0];
    });

    testWidgets('should match snapshot', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestHelper.renderWithEverything(
          CategoryBody(
            category: category,
            locale: DEFAULT_LOCALE,
            isTablet: false,
            onChannelSwitch: () => null,
          ),
          database,
        ),
      );

      await tester.pumpAndSettle();
      expect(find.byType(CategoryBody), findsOneWidget);
    });
  });
}
