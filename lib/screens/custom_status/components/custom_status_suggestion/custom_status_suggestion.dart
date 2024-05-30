import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mattermost_flutter/components/custom_status/clear_button.dart';
import 'package:mattermost_flutter/components/custom_status/custom_status_text.dart';
import 'package:mattermost_flutter/components/emoji.dart';
import 'package:mattermost_flutter/utils/tap.dart';
import 'package:mattermost_flutter/utils/theme.dart';

class CustomStatusSuggestion extends StatelessWidget {
  final String? duration;
  final String? emoji;
  final DateTime? expiresAt;
  final Function? handleClear;
  final Function handleSuggestionClick;
  final bool isExpirySupported;
  final bool separator;
  final String? text;
  final ThemeData theme;

  const CustomStatusSuggestion({
    Key? key,
    this.duration,
    this.emoji,
    this.expiresAt,
    this.handleClear,
    required this.handleSuggestionClick,
    required this.isExpirySupported,
    required this.separator,
    this.text,
    required this.theme,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final style = getStyleSheet(theme);
    final intl = Intl();

    void handleClick() {
      preventDoubleTap(() {
        handleSuggestionClick({'emoji': emoji, 'text': text, 'duration': duration});
      })();
    }

    void handleSuggestionClear() {
      if (handleClear != null) {
        handleClear!({'emoji': emoji, 'text': text, 'duration': duration, 'expiresAt': expiresAt});
      }
    }

    final showCustomStatus = duration != null && duration != 'date_and_time' && isExpirySupported;
    final customStatusSuggestionTestId = 'custom_status.custom_status_suggestion.$text';

    final clearButton = handleClear != null && expiresAt != null
        ? ClearButton(
            handlePress: handleSuggestionClear,
            theme: theme,
            iconName: Icons.close,
            size: 18,
            testID: '$customStatusSuggestionTestId.clear.button',
          )
        : null;

    return GestureDetector(
      onTap: handleClick,
      child: Container(
        color: theme.colorScheme.surface,
        child: Row(
          children: [
            if (emoji != null)
              Container(
                margin: EdgeInsets.only(left: 14, right: 10),
                child: Emoji(
                  emojiName: emoji!,
                  size: 20,
                  testID: '$customStatusSuggestionTestId.custom_status_emoji.$emoji',
                ),
              ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (text != null)
                    CustomStatusText(
                      text: text!,
                      theme: theme,
                      textStyle: style['customStatusText']!,
                      testID: '$customStatusSuggestionTestId.custom_status_text',
                    ),
                  if (showCustomStatus)
                    Padding(
                      padding: const EdgeInsets.only(top: 5.0),
                      child: CustomStatusText(
                        text: intl.message(CST[duration]!['defaultMessage']!),
                        theme: theme,
                        textStyle: style['customStatusDuration']!,
                        testID: '$customStatusSuggestionTestId.custom_status_duration.$duration',
                      ),
                    ),
                ],
              ),
            ),
            if (separator)
              Container(
                color: changeOpacity(theme.textTheme.bodyLarge!.color!, 0.2),
                height: 1,
                margin: EdgeInsets.only(right: 16),
              ),
            if (clearButton != null) clearButton
          ],
        ),
      ),
    );
  }

  Map<String, TextStyle> getStyleSheet(ThemeData theme) {
    return {
      'customStatusText': TextStyle(
        color: theme.textTheme.bodyLarge!.color,
      ),
      'customStatusDuration': TextStyle(
        color: changeOpacity(theme.textTheme.bodyLarge!.color!, 0.6),
        fontSize: 15,
      ),
    };
  }
}
