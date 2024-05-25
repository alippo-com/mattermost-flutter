import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mattermost_flutter/components/custom_status/custom_status_emoji.dart';
import 'package:mattermost_flutter/components/custom_status/custom_status_expiry.dart';
import 'package:mattermost_flutter/components/custom_status/custom_status_text.dart';
import 'package:mattermost_flutter/components/formatted_text.dart';
import 'package:mattermost_flutter/context/theme.dart';
import 'package:mattermost_flutter/utils/theme.dart';
import 'package:mattermost_flutter/utils/typography.dart';

class UserProfileCustomStatus extends StatelessWidget {
  final UserCustomStatus customStatus;

  UserProfileCustomStatus({required this.customStatus});

  @override
  Widget build(BuildContext context) {
    final theme = useTheme(context);
    final styles = getStyleSheet(theme);

    return Container(
      margin: EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          Row(
            children: [
              FormattedText(
                id: 'user_profile.custom_status',
                defaultMessage: 'Custom Status',
                style: styles['title'],
                testID: 'user_profile.custom_status.title',
              ),
              if (customStatus.duration != null)
                CustomStatusExpiry(
                  time: DateFormat('yyyy-MM-ddTHH:mm:ss').parse(customStatus.expiresAt),
                  theme: theme,
                  textStyles: styles['expiry'],
                  withinBrackets: true,
                  showPrefix: true,
                  testID: 'user_profile.${customStatus.duration}.custom_status_expiry',
                ),
            ],
          ),
          Row(
            children: [
              if (customStatus.emoji != null)
                CustomStatusEmoji(
                  customStatus: customStatus,
                  emojiSize: 24,
                  style: styles['emoji'],
                ),
              CustomStatusText(
                text: customStatus.text,
                theme: theme,
                textStyle: styles['description'],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Map<String, TextStyle> getStyleSheet(Theme theme) {
    return {
      'container': TextStyle(),
      'row': TextStyle(),
      'description': TextStyle(
        color: theme.centerChannelColor,
      ).merge(typography('Body', 200)),
      'title': TextStyle(
        color: changeOpacity(theme.centerChannelColor, 0.56),
        marginBottom: 2,
      ).merge(typography('Body', 50, 'SemiBold')),
      'expiry': TextStyle(
        color: changeOpacity(theme.centerChannelColor, 0.56),
        marginLeft: 3,
        marginBottom: 2,
        textTransform: 'lowercase',
      ).merge(typography('Body', 50, 'SemiBold')),
      'emoji': TextStyle(
        marginRight: 8,
      ),
    };
  }
}
