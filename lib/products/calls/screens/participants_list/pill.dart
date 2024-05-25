
import 'package:flutter/material.dart';
import 'package:mattermost_flutter/utils/theme.dart';
import 'package:mattermost_flutter/utils/typography.dart';

class Pill extends StatelessWidget {
  final dynamic text;

  const Pill({Key? key, required this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = useTheme(context);
    final styles = getStyleSheet(theme);

    return Container(
      decoration: BoxDecoration(
        color: changeOpacity(theme.centerChannelColor, 0.48),
        borderRadius: BorderRadius.circular(10),
      ),
      padding: EdgeInsets.symmetric(horizontal: 5),
      child: Text(
        '$text',
        style: styles['text'],
      ),
    );
  }

  Map<String, TextStyle> getStyleSheet(ThemeData theme) {
    return {
      'text': TextStyle(
        paddingTop: 1.5,
        paddingBottom: 1.5,
        paddingLeft: 2.5,
        paddingRight: 2.5,
        ...typography('Body', 50, 'SemiBold'),
        color: theme.centerChannelBg,
      ),
    };
  }
}
