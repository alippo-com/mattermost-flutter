
import 'package:flutter/material.dart';
import 'package:mattermost_flutter/components/formatted_text.dart';
import 'package:mattermost_flutter/i18n.dart';
import 'package:mattermost_flutter/utils/theme.dart';
import 'package:mattermost_flutter/screens/custom_status/components/custom_status_suggestion.dart';

class CustomStatusSuggestions extends StatelessWidget {
  final IntlShape intl;
  final Function(UserCustomStatus status) onHandleCustomStatusSuggestionClick;
  final List<UserCustomStatus> recentCustomStatuses;
  final ThemeData theme;

  CustomStatusSuggestions({
    required this.intl,
    required this.onHandleCustomStatusSuggestionClick,
    required this.recentCustomStatuses,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final style = getStyleSheet(theme);
    final recentCustomStatusTexts = recentCustomStatuses.map((status) => status.text).toSet();

    final customStatusSuggestions = defaultCustomStatusSuggestions
        .map((status) => DefaultUserCustomStatus(
      emoji: status.emoji,
      text: intl.formatMessage(id: status.message, defaultMessage: status.messageDefault),
      duration: status.durationDefault,
    ))
        .where((status) => !recentCustomStatusTexts.contains(status.text))
        .toList();

    if (customStatusSuggestions.isEmpty) {
      return Container();
    }

    return Column(
      children: [
        Container(height: 32),
        Container(
          key: Key('custom_status.suggestions'),
          child: Column(
            children: [
              FormattedText(
                id: t('custom_status.suggestions.title'),
                defaultMessage: 'Suggestions',
                style: style.title,
              ),
              Container(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: changeOpacity(theme.dividerColor, 0.1)),
                    top: BorderSide(color: changeOpacity(theme.dividerColor, 0.1)),
                  ),
                ),
                child: Column(
                  children: customStatusSuggestions
                      .map((status) => CustomStatusSuggestion(
                    key: Key(status.text),
                    handleSuggestionClick: onHandleCustomStatusSuggestionClick,
                    emoji: status.emoji,
                    text: status.text,
                    theme: theme,
                    separator: customStatusSuggestions.last != status,
                    duration: status.duration,
                  ))
                      .toList(),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  static List<DefaultUserCustomStatus> get defaultCustomStatusSuggestions => [
    DefaultUserCustomStatus(
        emoji: 'calendar',
        message: t('custom_status.suggestions.in_a_meeting'),
        messageDefault: 'In a meeting',
        durationDefault: 'one_hour'),
    DefaultUserCustomStatus(
        emoji: 'hamburger',
        message: t('custom_status.suggestions.out_for_lunch'),
        messageDefault: 'Out for lunch',
        durationDefault: 'thirty_minutes'),
    DefaultUserCustomStatus(
        emoji: 'sneezing_face',
        message: t('custom_status.suggestions.out_sick'),
        messageDefault: 'Out sick',
        durationDefault: 'today'),
    DefaultUserCustomStatus(
        emoji: 'house',
        message: t('custom_status.suggestions.working_from_home'),
        messageDefault: 'Working from home',
        durationDefault: 'today'),
    DefaultUserCustomStatus(
        emoji: 'palm_tree',
        message: t('custom_status.suggestions.on_a_vacation'),
        messageDefault: 'On a vacation',
        durationDefault: 'this_week'),
  ];

  static getStyleSheet(ThemeData theme) {
    return {
      'separator': TextStyle(
        height: 32,
      ),
      'title': TextStyle(
        fontSize: 17,
        marginBottom: 12,
        color: changeOpacity(theme.textTheme.headline1!.color!, 0.5),
        marginLeft: 16,
        textTransform: 'uppercase',
      ),
      'block': BoxDecoration(
        border: Border(
          bottom: BorderSide(color: changeOpacity(theme.dividerColor, 0.1)),
          top: BorderSide(color: changeOpacity(theme.dividerColor, 0.1)),
        ),
      ),
    };
  }
}

class DefaultUserCustomStatus {
  final String emoji;
  final String message;
  final String messageDefault;
  final String durationDefault;

  DefaultUserCustomStatus({
    required this.emoji,
    required this.message,
    required this.messageDefault,
    required this.durationDefault,
  });
}

class UserCustomStatus {
  final String text;

  UserCustomStatus({required this.text});
}

class IntlShape {
  String formatMessage({required String id, required String defaultMessage}) {
    // Mock implementation of the intl.formatMessage function
    return defaultMessage;
  }
}
