import 'package:flutter/material.dart';
import 'package:mattermost_flutter/components/formatted_text.dart';
import 'package:mattermost_flutter/types/theme.dart';
import 'package:mattermost_flutter/utils/theme.dart';
import 'package:mattermost_flutter/utils/typography.dart';

class CustomStatusText extends StatelessWidget {
  final UserCustomStatus? customStatus;
  final bool isStatusSet;
  final String? testID;

  CustomStatusText({this.customStatus, required this.isStatusSet, this.testID});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final styles = getStyleSheet(theme);

    String text = 'Set a custom status';

    if (isStatusSet && customStatus?.text != null) {
      text = customStatus!.text;
    }

    return CustomText(
      text: text,
      theme: theme,
      textStyle: styles.text,
      testID: testID,
    );
  }

  TextStyle getStyleSheet(Theme theme) {
    return TextStyle(
      color: theme.centerChannelColor,
      ...typography('Body', 200),
    );
  }
}
