// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mattermost_flutter/types/typography.dart';

class TestComponent extends StatelessWidget {
  final bool isSplitView;
  final bool isTablet;

  TestComponent({required this.isSplitView, required this.isTablet});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          '\${isSplitView}',
          key: Key('isSplitView'),
        ),
        Text(
          '\${isTablet}',
          key: Key('isTablet'),
        ),
      ],
    );
  }
}

void main() {
  group('<DeviceInfoProvider/>', () {
    testWidgets('should match the initial value of the context', (WidgetTester tester) async {
      final deviceInfoProvider = DeviceInfoProvider(
        child: TestComponent(isSplitView: false, isTablet: false),
      );

      await tester.pumpWidget(MaterialApp(home: deviceInfoProvider));

      expect(find.byKey(Key('isTablet')), findsOneWidget);
      expect(find.text('false'), findsWidgets);

      expect(find.byKey(Key('isSplitView')), findsOneWidget);
      expect(find.text('false'), findsWidgets);
    });

    testWidgets('should match the value emitted of the context', (WidgetTester tester) async {
      final deviceInfoProvider = DeviceInfoProvider(
        child: TestComponent(isSplitView: false, isTablet: false),
      );

      await tester.pumpWidget(MaterialApp(home: deviceInfoProvider));

      // Simulate emitter event
      deviceInfoProvider.updateContext(isTablet: true, isSplitView: true);
      await tester.pump();

      expect(find.byKey(Key('isTablet')), findsOneWidget);
      expect(find.text('true'), findsWidgets);

      expect(find.byKey(Key('isSplitView')), findsOneWidget);
      expect(find.text('true'), findsWidgets);
    });
  });
}
