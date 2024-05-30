
import 'package:flutter/material.dart';
import 'package:mattermost_flutter/i18n.dart';
import 'package:mattermost_flutter/components/custom_status/clear_button.dart';
import 'package:mattermost_flutter/constants/custom_status.dart';
import 'package:mattermost_flutter/utils/theme.dart';
import 'custom_status_emoji.dart';

class CustomStatusInput extends StatelessWidget {
  final String? emoji;
  final bool isStatusSet;
  final Function(String value) onChangeText;
  final Function() onClearHandle;
  final Function() onOpenEmojiPicker;
  final String? text;
  final ThemeData theme;

  CustomStatusInput({
    this.emoji,
    required this.isStatusSet,
    required this.onChangeText,
    required this.onClearHandle,
    required this.onOpenEmojiPicker,
    this.text,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final style = getStyleSheet(theme);
    final intl = IntlShape(); // Mock implementation of the intl.formatMessage function
    final placeholder = intl.formatMessage(id: 'custom_status.set_status', defaultMessage: 'Set a custom status');

    return Column(
      children: [
        Container(
          height: 48,
          decoration: BoxDecoration(
            color: theme.backgroundColor,
          ),
          child: Row(
            children: [
              CustomStatusEmoji(
                emoji: emoji,
                isStatusSet: isStatusSet,
                onPress: onOpenEmojiPicker,
                theme: theme,
              ),
              Expanded(
                child: TextField(
                  key: Key('custom_status.status.input'),
                  autocorrect: false,
                  autofocus: false,
                  keyboardType: TextInputType.text,
                  maxLength: CUSTOM_STATUS_TEXT_CHARACTER_LIMIT,
                  onChanged: onChangeText,
                  decoration: InputDecoration(
                    hintText: placeholder,
                    hintStyle: TextStyle(
                      color: changeOpacity(theme.primaryColor, 0.5),
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16),
                  ),
                  style: TextStyle(
                    color: theme.primaryColor,
                    fontSize: 17,
                  ),
                  textInputAction: TextInputAction.go,
                  obscureText: false,
                ),
              ),
              if (isStatusSet)
                Positioned(
                  right: 14,
                  child: ClearButton(
                    handlePress: onClearHandle,
                    theme: theme,
                  ),
                ),
            ],
          ),
        ),
        if (isStatusSet)
          Container(
            height: 1,
            margin: EdgeInsets.only(right: 16, left: 52),
            color: changeOpacity(theme.primaryColor, 0.2),
          ),
      ],
    );
  }

  static getStyleSheet(ThemeData theme) {
    return {
      'divider': BoxDecoration(
        color: changeOpacity(theme.primaryColor, 0.2),
        border: Border(
          bottom: BorderSide(color: changeOpacity(theme.primaryColor, 0.2)),
        ),
      ),
      'clearButton': BoxDecoration(
        position: 'absolute',
        top: 3,
        right: 14,
      ),
      'input': TextStyle(
        alignSelf: 'stretch',
        color: theme.primaryColor,
        fontSize: 17,
        paddingHorizontal: 16,
        height: '100%',
      ),
      'inputContainer': BoxDecoration(
        justifyContent: 'center',
        alignItems: 'center',
        height: 48,
        color: theme.backgroundColor,
        flexDirection: 'row',
      ),
    };
  }
}
