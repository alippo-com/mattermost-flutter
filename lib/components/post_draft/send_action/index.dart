import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mattermost_flutter/components/compass_icon.dart';
import 'package:mattermost_flutter/components/touchable_with_feedback.dart';
import 'package:mattermost_flutter/constants/post_draft.dart';
import 'package:mattermost_flutter/context/theme.dart';
import 'package:mattermost_flutter/utils/theme.dart';

class SendButton extends StatelessWidget {
  final String testID;
  final bool disabled;
  final VoidCallback sendMessage;

  SendButton({
    required this.testID,
    required this.disabled,
    required this.sendMessage,
  });

  @override
  Widget build(BuildContext context) {
    final theme = useTheme(context);
    final style = getStyleSheet(theme);

    final sendButtonTestID = disabled ? '\$testID.send.button.disabled' : '\$testID.send.button';
    final viewStyle = disabled ? [style['sendButton'], style['disableButton']] : [style['sendButton']];
    final buttonColor = disabled ? changeOpacity(theme.buttonColor, 0.5) : theme.buttonColor;

    return TouchableWithFeedback(
      testID: sendButtonTestID,
      onPress: sendMessage,
      style: style['sendButtonContainer'],
      type: 'opacity',
      disabled: disabled,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          color: disabled ? changeOpacity(theme.buttonBg, 0.3) : theme.buttonBg,
        ),
        height: 32,
        width: 80,
        child: Center(
          child: CompassIcon(
            name: 'send',
            size: 24,
            color: buttonColor,
          ),
        ),
      ),
    );
  }

  Map<String, dynamic> getStyleSheet(ThemeData theme) {
    return {
      'disableButton': {
        'backgroundColor': changeOpacity(theme.buttonBg, 0.3),
      },
      'sendButtonContainer': {
        'justifyContent': MainAxisAlignment.end,
        'paddingRight': 8.0,
      },
      'sendButton': {
        'backgroundColor': theme.buttonBg,
        'borderRadius': 4.0,
        'height': 32.0,
        'width': 80.0,
        'alignItems': Alignment.center,
        'justifyContent': MainAxisAlignment.center,
      },
    };
  }
}
