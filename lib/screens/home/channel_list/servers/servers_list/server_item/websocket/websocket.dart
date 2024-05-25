import 'package:flutter/material.dart';
import 'package:mattermost_flutter/components/compass_icon.dart';
import 'package:mattermost_flutter/utils/theme.dart';
import 'package:mattermost_flutter/types/typography.dart';

class WebSocket extends StatelessWidget {
  final String websocketState;

  WebSocket({
    required this.websocketState,
  });

  @override
  Widget build(BuildContext context) {
    final theme = useTheme(context);
    if (websocketState == 'connected' || websocketState == 'connecting') {
      return SizedBox.shrink();
    }

    final styles = getStyleSheet(theme);
    return Container(
      margin: EdgeInsets.only(bottom: 12, top: -4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CompassIcon(
            name: 'alert-outline',
            color: theme.dndIndicator,
            size: 14.4,
          ),
          SizedBox(width: 5),
          Text(
            'Server is unreachable.',
            style: styles['unreachable'],
          ),
        ],
      ),
    );
  }

  Map<String, TextStyle> getStyleSheet(ThemeData theme) {
    return {
      'unreachable': TextStyle(
        color: theme.dndIndicator,
        ...typography('Body', 75, 'Regular'),
      ),
    };
  }

  ThemeData useTheme(BuildContext context) {
    return Theme.of(context);
  }
}
