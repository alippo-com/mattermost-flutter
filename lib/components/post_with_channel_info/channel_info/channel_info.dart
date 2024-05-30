import 'package:flutter/material.dart';
import 'package:mattermost_flutter/utils/theme.dart';
import 'package:mattermost_flutter/utils/typography.dart';
import 'package:mattermost_flutter/utils/change_opacity.dart';
import 'package:mattermost_flutter/actions/remote/channel.dart';
import 'package:mattermost_flutter/components/touchable_with_feedback.dart';
import 'package:mattermost_flutter/context/server.dart';
import 'package:mattermost_flutter/context/theme.dart';

class ChannelInfo extends StatefulWidget {
  final String channelId;
  final String channelName;
  final String teamName;
  final String? testID;

  const ChannelInfo({
    required this.channelId,
    required this.channelName,
    required this.teamName,
    this.testID,
    Key? key,
  }) : super(key: key);

  @override
  _ChannelInfoState createState() => _ChannelInfoState();
}

class _ChannelInfoState extends State<ChannelInfo> {
  bool isPressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = useTheme(context);
    final serverUrl = useServerUrl(context);

    final styles = _getStyleSheet(theme);

    final channelNameStyle = [
      styles.channel,
      if (isPressed) TextStyle(color: theme.buttonBg),
    ];

    final teamContainerStyle = [
      styles.teamContainer,
      if (!isPressed) Border(
        left: BorderSide(width: 0.5, color: theme.centerChannelColor),
      ),
    ];

    void onChannelNamePressed() {
      if (widget.channelId.isNotEmpty) {
        switchToChannelById(serverUrl, widget.channelId);
      }
    }

    void togglePressed() {
      setState(() {
        isPressed = !isPressed;
      });
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              overflow: Overflow.visible,
            ),
            child: TouchableWithFeedback(
              onPress: onChannelNamePressed,
              onPressIn: togglePressed,
              onPressOut: togglePressed,
              type: TouchableWithFeedbackType.native,
              underlayColor: changeOpacity(theme.buttonBg, 0.08),
              child: Text(
                widget.channelName,
                style: TextStyle(
                  fontSize: 75,
                  fontWeight: FontWeight.w600,
                  color: changeOpacity(theme.centerChannelColor, 0.72),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          if (widget.teamName.isNotEmpty)
            Container(
              decoration: BoxDecoration(
                border: Border(
                  left: BorderSide(
                    width: 0.5,
                    color: theme.centerChannelColor,
                  ),
                ),
              ),
              margin: const EdgeInsets.only(left: 8),
              child: Text(
                widget.teamName,
                style: TextStyle(
                  fontSize: 75,
                  fontWeight: FontWeight.w400,
                  color: changeOpacity(theme.centerChannelColor, 0.72),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
        ],
      ),
    );
  }

  _getStyleSheet(ThemeData theme) {
    return {
      'container': {
        'flex': 1,
        'flexDirection': 'row',
        'alignItems': 'center',
        'marginVertical': 8,
        'paddingHorizontal': 8,
      },
      'channelContainer': {
        'borderRadius': 4,
        'overflow': 'hidden',
      },
      'channel': {
        ...typography('Body', 75, 'SemiBold'),
        'color': changeOpacity(theme.centerChannelColor, 0.72),
        'flexShrink': 1,
        'paddingHorizontal': 8,
        'paddingVertical': 4,
      },
      'teamContainer': {
        'borderColor': theme.centerChannelColor,
        'flexShrink': 1,
      },
      'team': {
        ...typography('Body', 75, 'Regular'),
        'color': changeOpacity(theme.centerChannelColor, 0.72),
        'marginLeft': 8,
      },
    };
  }
}
