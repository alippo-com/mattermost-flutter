
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:mattermost_flutter/types/calls.dart';
import 'package:mattermost_flutter/utils/theme.dart';
import 'package:mattermost_flutter/utils/typography.dart';
import 'package:mattermost_flutter/components/compass_icon.dart';
import 'package:provider/provider.dart';

const double CALL_ERROR_BAR_HEIGHT = 50.0;

class MessageBar extends HookWidget {
  final MessageBarType type;
  final VoidCallback onDismiss;

  MessageBar({
    required this.type,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final intl = useIntl();
    final theme = useTheme();
    final callsTheme = useMemo(() => makeCallsTheme(theme), [theme]);
    final style = getStyleSheet(callsTheme);
    final warning = type == MessageBarType.CallQuality;

    String message = '';
    Icon icon;

    switch (type) {
      case MessageBarType.Microphone:
        message = intl.formatMessage(
          id: 'mobile.calls_mic_error',
          defaultMessage:
              'To participate, open Settings to grant Mattermost access to your microphone.',
        );
        icon = Icon(Icons.mic_off, style: style.icon);
        break;
      case MessageBarType.CallQuality:
        message = intl.formatMessage(
          id: 'mobile.calls_quality_warning',
          defaultMessage:
              'Call quality may be degraded due to unstable network conditions.',
        );
        icon = Icon(Icons.warning, style: [style.icon, style.warningIcon]);
        break;
      default:
        icon = Icon(Icons.error, style: style.icon);
    }

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: theme.centerChannelColor.withOpacity(0.12),
            offset: Offset(0, 6),
            blurRadius: 4,
          ),
        ],
      ),
      margin: EdgeInsets.symmetric(horizontal: 8),
      height: CALL_ERROR_BAR_HEIGHT,
      child: Material(
        color: warning ? theme.awayIndicator : theme.dndIndicator,
        child: InkWell(
          onTap: () => Permissions.openSettings(),
          borderRadius: BorderRadius.circular(8),
          child: Row(
            children: [
              Container(
                width: 32,
                alignment: Alignment.center,
                child: icon,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(
                    message,
                    style: [style.errorText, if (warning) style.warningText],
                  ),
                ),
              ),
              GestureDetector(
                onTap: onDismiss,
                child: Container(
                  width: 32,
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.close,
                    style: [
                      style.icon,
                      style.closeIcon,
                      if (warning) style.closeIconWarning,
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Map<String, dynamic> getStyleSheet(CallsTheme theme) {
  return {
    'outerContainer': BoxDecoration(
      borderRadius: BorderRadius.circular(8),
      height: CALL_ERROR_BAR_HEIGHT,
      margin: EdgeInsets.symmetric(horizontal: 8),
      boxShadow: [
        BoxShadow(
          color: theme.centerChannelColor,
          offset: Offset(0, 6),
          blurRadius: 4,
        ),
      ],
    ),
    'outerContainerWarning': BoxDecoration(
      backgroundColor: theme.awayIndicator,
    ),
    'innerContainer': BoxDecoration(
      borderRadius: BorderRadius.circular(8),
      padding: EdgeInsets.all(8),
      backgroundColor: theme.dndIndicator,
    ),
    'innerContainerWarning': BoxDecoration(
      backgroundColor: theme.awayIndicator,
    ),
    'iconContainer': BoxDecoration(
      width: 32,
      alignment: Alignment.center,
    ),
    'icon': TextStyle(
      fontSize: 18,
      color: theme.buttonColor,
    ),
    'warningIcon': TextStyle(
      color: theme.callsBg,
    ),
    'textContainer': BoxDecoration(
      flex: 1,
      marginLeft: 8,
    ),
    'errorText': typography('Body', 100, 'SemiBold').copyWith(
      color: theme.buttonColor,
    ),
    'warningText': TextStyle(
      color: theme.callsBg,
    ),
    'dismissContainer': BoxDecoration(
      width: 32,
      alignment: Alignment.center,
    ),
    'closeIcon': TextStyle(
      color: changeOpacity(theme.buttonColor, 0.56),
    ),
    'closeIconWarning': TextStyle(
      color: changeOpacity(theme.callsBg, 0.56),
    ),
  };
}
