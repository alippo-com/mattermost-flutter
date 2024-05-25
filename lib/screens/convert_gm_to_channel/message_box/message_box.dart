import 'package:flutter/material.dart';
import 'package:mattermost_flutter/components/compass_icon.dart';
import 'package:mattermost_flutter/context/theme.dart';
import 'package:mattermost_flutter/utils/theme.dart';
import 'package:mattermost_flutter/utils/typography.dart';

enum MessageBoxTypes { defaultType, danger }

class MessageBox extends StatelessWidget {
  final String header;
  final String body;
  final MessageBoxTypes? type;

  MessageBox({required this.header, required this.body, this.type});

  @override
  Widget build(BuildContext context) {
    final theme = useTheme(context);
    final baseStyle = getBaseStyles(theme);
    final kindStyle = getStyleFromTheme(theme, type);

    return Container(
      decoration: BoxDecoration(
        color: changeOpacity(theme.sidebarTextActiveBorder, 0.08),
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(
          color: changeOpacity(theme.sidebarTextActiveBorder, 0.16),
        ),
      ),
      padding: EdgeInsets.all(16.0),
      child: Row(
        children: [
          Container(
            margin: EdgeInsets.only(top: 5.0),
            child: CompassIcon(
              name: 'exclamation-thick',
              color: theme.sidebarTextActiveBorder,
              size: 20.0,
            ),
          ),
          SizedBox(width: 12.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  header,
                  style: typography('Body', 100, 'SemiBold').copyWith(color: theme.centerChannelColor),
                ),
                SizedBox(height: 8.0),
                Text(
                  body,
                  style: typography('Body', 100).copyWith(color: theme.centerChannelColor),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> getBaseStyles(Theme theme) {
    return {
      'container': BoxDecoration(
        color: changeOpacity(theme.sidebarTextActiveBorder, 0.08),
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(
          color: changeOpacity(theme.sidebarTextActiveBorder, 0.16),
        ),
      ),
      'icon': {
        'color': theme.sidebarTextActiveBorder,
        'borderColor': theme.sidebarTextActiveBorder,
      },
    };
  }

  Map<String, dynamic> getStyleFromTheme(Theme theme, MessageBoxTypes? kind) {
    switch (kind) {
      case MessageBoxTypes.danger:
        return {
          'container': BoxDecoration(
            color: changeOpacity(theme.dndIndicator, 0.08),
            borderRadius: BorderRadius.circular(8.0),
            border: Border.all(
              color: changeOpacity(theme.dndIndicator, 0.16),
            ),
          ),
          'icon': {
            'color': theme.dndIndicator,
            'borderColor': theme.dndIndicator,
          },
        };
      default:
        return {
          'container': BoxDecoration(
            color: changeOpacity(theme.sidebarTextActiveBorder, 0.08),
            borderRadius: BorderRadius.circular(8.0),
            border: Border.all(
              color: changeOpacity(theme.sidebarTextActiveBorder, 0.16),
            ),
          ),
          'icon': {
            'color': theme.sidebarTextActiveBorder,
            'borderColor': theme.sidebarTextActiveBorder,
          },
        };
    }
  }
}
