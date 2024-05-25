import 'package:flutter/material.dart';
import 'package:mattermost_flutter/components/formatted_text.dart';
import 'package:mattermost_flutter/context/theme.dart';
import 'package:mattermost_flutter/utils/theme.dart';
import 'package:mattermost_flutter/utils/typography.dart';
import 'package:mattermost_flutter/screens/home/saved_messages/components/saved_posts_icon.dart';

class EmptySavedMessages extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = useTheme(context);
    final styles = getStyleSheet(theme);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 40),
      alignment: Alignment.center,
      constraints: BoxConstraints(maxWidth: 480),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SavedPostsIcon(style: styles['icon']),
          FormattedText(
            defaultMessage: 'No saved messages yet',
            id: 'saved_messages.empty.title',
            style: styles['title'],
            testID: 'saved_messages.empty.title',
          ),
          SizedBox(height: 8),
          FormattedText(
            defaultMessage: 'To save something for later, long-press on a message and choose Save from the menu. Saved messages are only visible to you.',
            id: 'saved_messages.empty.paragraph',
            style: styles['paragraph'],
            testID: 'saved_messages.empty.paragraph',
          ),
        ],
      ),
    );
  }

  Map<String, TextStyle> getStyleSheet(ThemeData theme) {
    return {
      'title': TextStyle(
        color: theme.centerChannelColor,
        textAlign: TextAlign.center,
        ...typography('Heading', 400),
      ),
      'paragraph': TextStyle(
        color: changeOpacity(theme.centerChannelColor, 0.72),
        textAlign: TextAlign.center,
        ...typography('Body', 200),
      ),
      'icon': TextStyle(
        // This should not be here since it's not a text style.
      ),
    };
  }

  ThemeData useTheme(BuildContext context) {
    return Theme.of(context);
  }
}
