import 'package:flutter/material.dart';
import 'package:mattermost_flutter/components/channel_info_start_button.dart';
import 'package:mattermost_flutter/components/channel_actions/add_members_box.dart';
import 'package:mattermost_flutter/components/channel_actions/copy_channel_link_box.dart';
import 'package:mattermost_flutter/components/channel_actions/favorite_box.dart';
import 'package:mattermost_flutter/components/channel_actions/muted_box.dart';
import 'package:mattermost_flutter/components/channel_actions/set_header_box.dart';
import 'package:mattermost_flutter/context/server.dart';
import 'package:mattermost_flutter/screens/navigation.dart';
import 'package:mattermost_flutter/utils/channel.dart';

class ChannelActions extends StatelessWidget {
  final String channelId;
  final String? channelType;
  final bool inModal;
  final VoidCallback dismissChannelInfo;
  final bool callsEnabled;
  final String? testID;
  final bool canManageMembers;

  static const CHANNEL_ACTIONS_OPTIONS_HEIGHT = 62.0;

  ChannelActions({
    required this.channelId,
    this.channelType,
    this.inModal = false,
    required this.dismissChannelInfo,
    required this.callsEnabled,
    required this.canManageMembers,
    this.testID,
  });

  @override
  Widget build(BuildContext context) {
    final serverUrl = useServerUrl();
    final isDM = isTypeDMorGM(channelType);

    void onCopyLinkAnimationEnd() {
      if (!inModal) {
        Future.delayed(Duration.zero, () async {
          await dismissBottomSheet();
        });
      }
    }

    return Row(
      children: [
        FavoriteBox(
          channelId: channelId,
          showSnackBar: !inModal,
          testID: testID,
        ),
        SizedBox(width: 8),
        MutedBox(
          channelId: channelId,
          showSnackBar: !inModal,
          testID: testID,
        ),
        if (isDM)
          SetHeaderBox(
            channelId: channelId,
            inModal: inModal,
            testID: '${testID}.set_header.action',
          ),
        if (canManageMembers)
          AddMembersBox(
            channelId: channelId,
            inModal: inModal,
            testID: '${testID}.add_members.action',
          ),
        if (!isDM && !callsEnabled)
          Row(
            children: [
              SizedBox(width: 8),
              CopyChannelLinkBox(
                channelId: channelId,
                onAnimationEnd: onCopyLinkAnimationEnd,
                testID: '${testID}.copy_channel_link.action',
              ),
            ],
          ),
        if (callsEnabled)
          Row(
            children: [
              SizedBox(width: 8),
              ChannelInfoStartButton(
                serverUrl: serverUrl,
                channelId: channelId,
                dismissChannelInfo: dismissChannelInfo,
              ),
            ],
          ),
      ],
    );
  }
}
