import 'package:flutter/material.dart';
import 'package:mattermost_flutter/constants/general.dart';
import 'package:mattermost_flutter/screens/channel_info/title/direct_message.dart';
import 'package:mattermost_flutter/screens/channel_info/title/group_message.dart';
import 'package:mattermost_flutter/screens/channel_info/title/public_private.dart';

class Title extends StatelessWidget {
  final String channelId;
  final String? displayName;
  final ChannelType? type;

  Title({
    required this.channelId,
    this.displayName,
    this.type,
  });

  @override
  Widget build(BuildContext context) {
    Widget component;

    switch (type) {
      case General.DM_CHANNEL:
        component = DirectMessage(
          channelId: channelId,
          displayName: displayName,
        );
        break;
      case General.GM_CHANNEL:
        component = GroupMessage(
          channelId: channelId,
          displayName: displayName,
        );
        break;
      default:
        component = PublicPrivate(
          channelId: channelId,
          displayName: displayName,
        );
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16, top: 24),
      child: component,
    );
  }
}