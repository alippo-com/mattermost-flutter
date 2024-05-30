
import 'package:flutter/material.dart';
import 'package:mattermost_flutter/components/compass_icon.dart';
import 'package:mattermost_flutter/components/touchable_with_feedback.dart';
import 'package:mattermost_flutter/constants/post_draft.dart';
import 'package:mattermost_flutter/context/theme.dart';
import 'package:mattermost_flutter/utils/theme.dart';

class InputQuickAction extends StatelessWidget {
  final String? testID;
  final bool? disabled;
  final String inputType;
  final ValueChanged<String> updateValue;
  final VoidCallback focus;

  InputQuickAction({
    this.testID,
    this.disabled,
    required this.inputType,
    required this.updateValue,
    required this.focus,
  });

  @override
  Widget build(BuildContext context) {
    final theme = useTheme(context);
    final style = getStyleSheet(theme);
    final iconName = inputType == 'at' ? inputType : 'slash-forward-box-outline';
    final iconColor = disabled == true
        ? changeOpacity(theme.centerChannelColor, 0.16)
        : changeOpacity(theme.centerChannelColor, 0.64);

    return TouchableWithFeedback(
      testID: disabled == true ? '$testID.disabled' : testID,
      disabled: disabled,
      onPress: () {
        updateValue((v) {
          if (inputType == 'at') {
            return '$v@';
          }
          return '/';
        });
        focus();
      },
      style: style.icon,
      type: 'opacity',
      child: CompassIcon(
        name: iconName,
        color: iconColor,
        size: ICON_SIZE,
      ),
    );
  }

  getStyleSheet(ThemeData theme) {
    return {
      'disabled': {
        'tintColor': changeOpacity(theme.centerChannelColor, 0.16),
      },
      'icon': {
        'alignItems': 'center',
        'justifyContent': 'center',
        'padding': 10,
      },
    };
  }
}
