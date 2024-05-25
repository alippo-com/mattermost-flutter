
import 'package:flutter/material.dart';
import 'package:mattermost_flutter/types.dart';
import 'package:mattermost_flutter/components/footer.dart';
import 'package:mattermost_flutter/components/label.dart';
import 'package:mattermost_flutter/components/radio_entry.dart';
import 'package:mattermost_flutter/context/theme.dart';
import 'package:mattermost_flutter/utils/theme.dart';

class RadioSetting extends StatelessWidget {
  final String label;
  final List<PostActionOption>? options;
  final Function(String) onChange;
  final String helpText;
  final String errorText;
  final String value;
  final String testID;

  RadioSetting({
    required this.label,
    this.options,
    required this.onChange,
    this.helpText = '',
    this.errorText = '',
    required this.value,
    required this.testID,
  });

  @override
  Widget build(BuildContext context) {
    final theme = useTheme(context);
    final style = getStyleSheet(theme);

    List<Widget> optionsRender = [];
    if (options != null) {
      for (int i = 0; i < options!.length; i++) {
        final entry = options![i];
        optionsRender.add(
          RadioEntry(
            handleChange: onChange,
            isLast: i == options!.length - 1,
            isSelected: value == entry.value,
            text: entry.text,
            value: entry.value,
            key: Key(entry.value),
          ),
        );
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Label(
          label: label,
          optional: false,
          testID: testID,
        ),
        Container(
          decoration: BoxDecoration(
            color: theme.centerChannelBg,
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
            children: optionsRender,
          ),
        ),
        Footer(
          disabled: false,
          errorText: errorText,
          helpText: helpText,
        ),
      ],
    );
  }

  static Map<String, TextStyle> getStyleSheet(Theme theme) {
    return {
      'items': TextStyle(
        backgroundColor: theme.centerChannelBg,
        borderTop: Border.all(
          color: changeOpacity(theme.centerChannelColor, 0.1),
          width: 1,
        ),
        borderBottom: Border.all(
          color: changeOpacity(theme.centerChannelColor, 0.1),
          width: 1,
        ),
      ),
    };
  }
}
