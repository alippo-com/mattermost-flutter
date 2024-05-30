import 'package:flutter/material.dart';
import 'package:mattermost_flutter/components/formatted_text.dart';
import 'package:mattermost_flutter/context/theme.dart';
import 'package:mattermost_flutter/utils/theme.dart';
import 'package:mattermost_flutter/utils/typography.dart';

class EmptyMentions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = useTheme(context);
    final styles = _getStyleSheet(theme);

    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          MentionIcon(style: styles['icon']),
          FormattedText(
            defaultMessage: 'No Mentions yet',
            id: 'mentions.empty.title',
            style: styles['title'],
            testID: 'recent_mentions.empty.title',
          ),
          FormattedText(
            defaultMessage: 'You\'ll see messages here when someone mentions you or uses terms you\'re monitoring.',
            id: 'mentions.empty.paragraph',
            style: styles['paragraph'],
            testID: 'recent_mentions.empty.paragraph',
          ),
        ],
      ),
    );
  }

  Map<String, TextStyle> _getStyleSheet(ThemeData theme) {
    return {
      'container': TextStyle(
        flex: 1,
        alignItems: 'center',
        justifyContent: 'center',
        paddingHorizontal: 40,
      ),
      'title': typography('Heading', 400).copyWith(color: theme.centerChannelColor),
      'paragraph': typography('Body', 200).copyWith(
        margin: EdgeInsets.only(top: 8),
        textAlign: TextAlign.center,
        color: changeOpacity(theme.centerChannelColor, 0.72),
      ),
      'icon': TextStyle(
        alignItems: 'center',
        justifyContent: 'center',
      ),
    };
  }
}
