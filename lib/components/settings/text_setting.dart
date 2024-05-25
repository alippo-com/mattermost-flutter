
import 'package:flutter/material.dart';
import 'package:mattermost_flutter/types/theme.dart';
import 'package:mattermost_flutter/utils/theme.dart';
import 'package:provider/provider.dart';
import 'package:mattermost_flutter/components/formatted_text.dart';
import 'package:mattermost_flutter/components/settings/label.dart';
import 'package:mattermost_flutter/components/settings/footer.dart';

class TextSetting extends StatelessWidget {
  final String label;
  final String? placeholder;
  final String? helpText;
  final String? errorText;
  final bool disabled;
  final String? disabledText;
  final int? maxLength;
  final bool optional;
  final Function(String) onChange;
  final String value;
  final bool multiline;
  final TextInputType keyboardType;
  final bool secureTextEntry;
  final String testID;

  const TextSetting({
    Key? key,
    required this.label,
    this.placeholder,
    this.helpText,
    this.errorText,
    required this.disabled,
    this.disabledText,
    this.maxLength,
    required this.optional,
    required this.onChange,
    required this.value,
    required this.multiline,
    required this.keyboardType,
    required this.secureTextEntry,
    required this.testID,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<Theme>(context);
    final style = _getStyleSheet(theme);

    final inputContainerStyle = disabled
        ? [style['inputContainer'], style['disabled']]
        : style['inputContainer'];
    final inputStyle = multiline ? style['multiline'] : style['input'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty)
          Label(
            label: label,
            optional: optional,
            testID: testID,
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
            color: theme.centerChannelBg,
          ),
          child: TextField(
            controller: TextEditingController(text: value),
            decoration: InputDecoration(
              hintText: placeholder,
              hintStyle: TextStyle(
                color: changeOpacity(theme.centerChannelColor, 0.5),
              ),
              border: InputBorder.none,
            ),
            style: inputStyle,
            maxLength: maxLength,
            enabled: !disabled,
            obscureText: secureTextEntry,
            keyboardType: keyboardType,
          ),
        ),
        Footer(
          disabled: disabled,
          disabledText: disabledText,
          errorText: errorText,
          helpText: helpText,
        ),
      ],
    );
  }

  Map<String, dynamic> _getStyleSheet(Theme theme) {
    const input = TextStyle(
      fontSize: 14,
      padding: EdgeInsets.symmetric(horizontal: 15),
    );

    return {
      'inputContainer': BoxDecoration(
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
        color: theme.centerChannelBg,
      ),
      'input': input.copyWith(
        color: theme.centerChannelColor,
        height: 40,
      ),
      'multiline': input.copyWith(
        color: theme.centerChannelColor,
        height: 125,
        padding: EdgeInsets.symmetric(vertical: 10),
      ),
      'disabled': BoxDecoration(
        color: changeOpacity(theme.centerChannelColor, 0.1),
      ),
    };
  }
}
