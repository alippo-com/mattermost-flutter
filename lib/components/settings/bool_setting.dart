
import 'package:flutter/material.dart';
import 'package:mattermost_flutter/types/theme_model.dart';
import 'package:mattermost_flutter/utils/theme.dart';
import 'package:mattermost_flutter/components/footer.dart';
import 'package:mattermost_flutter/components/label.dart';

class BoolSetting extends StatelessWidget {
  final String? label;
  final bool value;
  final String? placeholder;
  final String? helpText;
  final String? errorText;
  final String? disabledText;
  final bool optional;
  final bool disabled;
  final Function(bool) onChange;
  final String testID;

  BoolSetting({
    this.label,
    required this.value,
    this.placeholder,
    this.helpText,
    this.errorText,
    this.disabledText,
    this.optional = false,
    this.disabled = false,
    required this.onChange,
    required this.testID,
  });

  BoxDecoration _inputContainerStyle(bool disabled, ThemeModel theme) {
    return BoxDecoration(
      color: disabled ? changeOpacity(theme.centerChannelBg, 0.1) : theme.centerChannelBg,
      border: Border.all(color: changeOpacity(theme.centerChannelColor, 0.1)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeModel theme = useTheme(context);
    final BoxDecoration inputContainerStyle = _inputContainerStyle(disabled, theme);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Label(
            label: label!,
            optional: optional,
            testID: testID,
          ),
          Divider(color: changeOpacity(theme.centerChannelColor, 0.1)),
        ],
        Container(
          decoration: inputContainerStyle,
          padding: EdgeInsets.symmetric(horizontal: 15),
          height: 40,
          child: Row(
            children: [
              if (placeholder != null)
                Text(
                  placeholder!,
                  style: TextStyle(
                    color: changeOpacity(theme.centerChannelColor, 0.5),
                    fontSize: 15,
                  ),
                ),
              Spacer(),
              Switch(
                value: value,
                onChanged: disabled ? null : onChange,
              ),
            ],
          ),
        ),
        Divider(color: changeOpacity(theme.centerChannelColor, 0.1)),
        Footer(
          disabled: disabled,
          disabledText: disabledText,
          errorText: errorText,
          helpText: helpText,
        ),
      ],
    );
  }
}
