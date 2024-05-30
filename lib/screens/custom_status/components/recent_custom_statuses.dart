import 'package:flutter/material.dart';
import 'package:mattermost_flutter/components/formatted_text.dart';
import 'package:mattermost_flutter/i18n.dart';
import 'package:mattermost_flutter/screens/custom_status/components/custom_status_suggestion/custom_status_suggestion.dart';
import 'package:mattermost_flutter/utils/theme.dart';

class RecentCustomStatuses extends StatelessWidget {
  final Function(UserCustomStatus) onHandleClear;
  final Function(UserCustomStatus) onHandleSuggestionClick;
  final List<UserCustomStatus> recentCustomStatuses;
  final Theme theme;

  const RecentCustomStatuses({
    Key? key,
    required this.onHandleClear,
    required this.onHandleSuggestionClick,
    required this.recentCustomStatuses,
    required this.theme,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final style = getStyleSheet(theme);

    if (recentCustomStatuses.isEmpty) {
      return SizedBox.shrink();
    }

    return Column(
      children: [
        SizedBox(height: 32),
        Container(
          key: Key('custom_status.recents'),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FormattedText(
                id: t('custom_status.suggestions.recent_title'),
                defaultMessage: 'Recent',
                style: style['title'],
              ),
              Container(
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: changeOpacity(theme.centerChannelColor, 0.1),
                      width: 1,
                    ),
                    bottom: BorderSide(
                      color: changeOpacity(theme.centerChannelColor, 0.1),
                      width: 1,
                    ),
                  ),
                ),
                child: Column(
                  children: recentCustomStatuses
                      .asMap()
                      .entries
                      .map((entry) {
                    final status = entry.value;
                    final index = entry.key;
                    return CustomStatusSuggestion(
                      key: Key('${status.text}-$index'),
                      handleSuggestionClick: onHandleSuggestionClick,
                      handleClear: onHandleClear,
                      emoji: status.emoji,
                      text: status.text,
                      theme: theme,
                      separator: index != recentCustomStatuses.length - 1,
                      duration: status.duration,
                      expiresAt: status.expiresAt,
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Map<String, TextStyle> getStyleSheet(Theme theme) {
    return {
      'separator': TextStyle(marginTop: 32),
      'title': TextStyle(
        fontSize: 17,
        marginBottom: 12,
        color: changeOpacity(theme.centerChannelColor, 0.5),
        marginLeft: 16,
        textTransform: TextTransform.uppercase,
      ),
      'block': BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: changeOpacity(theme.centerChannelColor, 0.1),
            width: 1,
          ),
          top: BorderSide(
            color: changeOpacity(theme.centerChannelColor, 0.1),
            width: 1,
          ),
        ),
      ),
    };
  }
}

class UserCustomStatus {
  final String? emoji;
  final String? text;
  final Duration duration;
  final DateTime expiresAt;

  UserCustomStatus({
    this.emoji,
    this.text,
    required this.duration,
    required this.expiresAt,
  });
}

class Theme {
  final Color centerChannelColor;

  Theme({required this.centerChannelColor});
}

class TextTransform {
  static const uppercase = 'uppercase';
}
