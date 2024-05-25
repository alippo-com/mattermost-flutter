import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:mattermost_flutter/components/compass_icon.dart';
import 'package:mattermost_flutter/screens/integration_selector/custom_list_row.dart';
import 'package:mattermost_flutter/utils/test_helper.dart';

void main() {
  group('components/integration_selector/custom_list_row', () {
    late Database database;

    setUpAll(() async {
      final server = await TestHelper.setupServerDatabase();
      database = server.database;
    });

    testWidgets('should match snapshot', (WidgetTester tester) async {
      await tester.pumpWidget(
        Provider<Database>.value(
          value: database,
          child: MaterialApp(
            home: CustomListRow(
              id: '1',
              onPress: () {
                // noop
              },
              enabled: true,
              selectable: true,
              selected: true,
              child: Column(
                children: [
                  Column(
                    children: [
                      CompassIcon(
                        name: 'globe',
                      ),
                      Text('My channel'),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      await tester.pump();
      expect(find.byType(CustomListRow), matchesGoldenFile('custom_list_row.png'));
    });
  });
}
