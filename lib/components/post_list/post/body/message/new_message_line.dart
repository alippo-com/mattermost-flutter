import 'package:flutter/material.dart';
import 'package:mattermost_flutter/components/formatted_text.dart';
import 'package:mattermost_flutter/utils/theme.dart';
import 'package:mattermost_flutter/utils/typography.dart';

class NewMessagesLine extends StatelessWidget {
  final Theme theme;
  final String? testID;
  final TextStyle? style;

  const NewMessagesLine({
    Key? key,
    required this.theme,
    this.testID,
    this.style,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final styles = _getStyleFromTheme(theme);

    return Container(
      alignment: Alignment.center,
      height: 28,
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 1,
              color: theme.newMessageSeparator,
            ),
          ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 8),
            child: FormattedText(
              id: 'posts_view.newMsg',
              defaultMessage: 'New Messages',
              style: styles['text']!.merge(style),
              testID: testID,
            ),
          ),
          Expanded(
            child: Container(
              height: 1,
              color: theme.newMessageSeparator,
            ),
          ),
        ],
      ),
    );
  }

  Map<String, TextStyle> _getStyleFromTheme(Theme theme) {
    return {
      'text': TextStyle(
        color: theme.newMessageSeparator,
        margin: EdgeInsets.symmetric(horizontal: 4),
      ).merge(typography('Body', 75, 'SemiBold')),
    };
  }
}
