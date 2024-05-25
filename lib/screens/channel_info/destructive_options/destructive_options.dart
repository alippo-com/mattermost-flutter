import 'package:flutter/material.dart';
import 'package:mattermost_flutter/components/channel_actions/leave_channel_label.dart';
import 'package:mattermost_flutter/constants/general.dart';
import 'package:mattermost_flutter/screens/channel_info/destructive_options/archive.dart';
import 'package:mattermost_flutter/screens/channel_info/destructive_options/convert_private.dart';
import 'package:mattermost_flutter/types/screens/navigation.dart';

class DestructiveOptions extends StatelessWidget {
  final String channelId;
  final AvailableScreens componentId;
  final ChannelType? type;

  DestructiveOptions({
    required this.channelId,
    required this.componentId,
    this.type,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (type == General.OPEN_CHANNEL)
          ConvertPrivate(channelId: channelId),
        LeaveChannelLabel(
          channelId: channelId,
          isOptionItem: true,
          testID: 'channel_info.options.leave_channel.option',
        ),
        if (type != General.DM_CHANNEL && type != General.GM_CHANNEL)
          Archive(
            channelId: channelId,
            componentId: componentId,
            type: type,
          ),
      ],
    );
  }
}
