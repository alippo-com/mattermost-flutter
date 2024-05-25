import 'package:flutter/material.dart';
import 'package:mattermost_flutter/components/channel_actions.dart';
import 'package:mattermost_flutter/components/channel_actions/copy_channel_link_option.dart';
import 'package:mattermost_flutter/components/channel_actions/info_box.dart';
import 'package:mattermost_flutter/components/channel_actions/leave_channel_label.dart';
import 'package:mattermost_flutter/context/theme.dart';
import 'package:mattermost_flutter/screens/navigation.dart';
import 'package:mattermost_flutter/utils/theme.dart';

class ChannelQuickAction extends StatelessWidget {
  final String channelId;
  final bool callsEnabled;
  final bool isDMorGM;

  ChannelQuickAction({required this.channelId, required this.callsEnabled, required this.isDMorGM});

  @override
  Widget build(BuildContext context) {
    final theme = useTheme(context);
    final styles = getStyleSheet(theme);

    return Container(
      child: Column(
        children: [
          Container(
            margin: EdgeInsets.only(bottom: MARGIN),
            child: ChannelActions(
              channelId: channelId,
              dismissChannelInfo: dismissBottomSheet,
              callsEnabled: callsEnabled,
              testID: 'channel.quick_actions',
            ),
          ),
          InfoBox(
            channelId: channelId,
            showAsLabel: true,
            testID: 'channel.quick_actions.channel_info.action',
          ),
          if (callsEnabled && !isDMorGM)
            CopyChannelLinkOption(
              channelId: channelId,
              showAsLabel: true,
            ),
          Container(
            color: changeOpacity(theme.centerChannelColor, 0.08),
            height: 1,
            margin: EdgeInsets.symmetric(vertical: MARGIN),
          ),
          LeaveChannelLabel(
            channelId: channelId,
            testID: 'channel.quick_actions.leave_channel.action',
          ),
        ],
      ),
    );
  }

  static const double SEPARATOR_HEIGHT = 17.0;
  static const double MARGIN = 8.0;

  static getStyleSheet(ThemeData theme) {
    return {
      'container': BoxDecoration(),
      'line': BoxDecoration(
        color: changeOpacity(theme.centerChannelColor, 0.08),
        height: 1,
        marginVertical: MARGIN,
      ),
      'wrapper': BoxDecoration(
        marginBottom: MARGIN,
      ),
      'separator': BoxDecoration(
        width: MARGIN,
      ),
    };
  }
}

changeOpacity(Color color, double opacity) {
  return color.withOpacity(opacity);
}
