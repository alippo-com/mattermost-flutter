import 'package:flutter/material.dart';
import 'package:mattermost_flutter/context/theme.dart';
import 'package:mattermost_flutter/utils/theme.dart';
import 'package:mattermost_flutter/utils/typography.dart';

import 'illustrations/empty_state.dart';

class EmptyState extends StatelessWidget {
  final bool isUnreads;

  EmptyState({required this.isUnreads});

  String getTitle(BuildContext context, bool isUnreads) {
    if (isUnreads) {
      return 'No unread threads';
    } else {
      return 'No followed threads yet';
    }
  }

  String getSubTitle(BuildContext context, bool isUnreads) {
    if (isUnreads) {
      return "Looks like you're all caught up.";
    } else {
      return 'Any threads you are mentioned in or have participated in will show here along with any threads you have followed.';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = useTheme(context);
    final style = getStyleSheet(theme);

    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          EmptyStateIllustration(theme: theme),
          Container(
            margin: EdgeInsets.only(top: 24),
            child: Column(
              children: [
                Text(
                  getTitle(context, isUnreads),
                  textAlign: TextAlign.center,
                  style: style['title'],
                ),
                SizedBox(height: 8),
                Text(
                  getSubTitle(context, isUnreads),
                  textAlign: TextAlign.center,
                  style: style['paragraph'],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> getStyleSheet(ThemeData theme) {
    return {
      'title': TextStyle(
        color: theme.centerChannelColor,
        ...typography('Heading', 400, 'SemiBold'),
      ),
      'paragraph': TextStyle(
        marginTop: 8,
        textAlign: TextAlign.center,
        color: changeOpacity(theme.centerChannelColor, 0.72),
        ...typography('Body', 200),
      ),
    };
  }
}
