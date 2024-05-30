
// index_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:mattermost_flutter/utils/intl_test_helper.dart';
import 'package:mattermost_flutter/utils/test_helper.dart';
import 'package:mattermost_flutter/screens/integration_selector/custom_list.dart';
import 'package:mattermost_flutter/types/database.dart';

void main() {
  group('components/integration_selector/custom_list', () {
    late Database database;

    setUpAll(() async {
      final server = await TestHelper.setupServerDatabase();
      database = server.database;
    });

    testWidgets('should render', (WidgetTester tester) async {
      final channel = {
        'id': '1',
        'create_at': 1111,
        'update_at': 1111,
        'delete_at': 1111,
        'team_id': 'my team',
        'type': 'O',
        'display_name': 'channel',
        'name': 'channel',
        'header': 'channel',
        'purpose': 'channel',
        'last_post_at': 1,
        'total_msg_count': 1,
        'extra_update_at': 1,
        'creator_id': '1',
        'scheme_id': null,
        'group_constrained': null,
        'shared': true,
      };

      await tester.pumpWidget(
        Provider<Database>.value(
          value: database,
          child: MaterialApp(
            home: CustomList(
              data: [channel],
              key: Key('custom_list'),
              loading: false,
              theme: Preferences.THEMES_DENIM,
              testID: 'ChannelListRow',
              noResults: () => Text('No Results'),
              onLoadMore: () {
                // noop
              },
              onRowPress: () {
                // noop
              },
              renderItem: (props) => Text(props.toString()),
              loadingComponent: null,
            ),
          ),
        ),
      );

      expect(find.byType(CustomList), findsOneWidget);
    });
  });
}
