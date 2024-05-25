import 'package:flutter/material.dart';
import 'package:mattermost_flutter/components/channel_actions/manage_members_label.dart';
import 'package:mattermost_flutter/constants/members.dart';
import 'package:mattermost_flutter/context/theme.dart';
import 'package:mattermost_flutter/utils/theme.dart';

const double DIVIDER_MARGIN = 8.0;
const MAKE_CHANNEL_ADMIN = Members.ManageOptions.MAKE_CHANNEL_ADMIN;
const MAKE_CHANNEL_MEMBER = Members.ManageOptions.MAKE_CHANNEL_MEMBER;
const REMOVE_USER = Members.ManageOptions.REMOVE_USER;

class ManageUserOptions extends StatelessWidget {
  final String channelId;
  final bool isDefaultChannel;
  final bool isChannelAdmin;
  final bool canChangeMemberRoles;
  final String userId;

  ManageUserOptions({
    required this.channelId,
    required this.isDefaultChannel,
    required this.isChannelAdmin,
    required this.canChangeMemberRoles,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    final theme = useTheme(context);
    final styles = _getStyleSheet(theme);

    return Column(
      children: [
        Container(
          margin: EdgeInsets.symmetric(vertical: DIVIDER_MARGIN),
          padding: EdgeInsets.symmetric(horizontal: 20.0),
          width: double.infinity,
          height: 1.0,
          color: changeOpacity(theme.centerChannelColor, 0.16),
        ),
        if (canChangeMemberRoles)
          ManageMembersLabel(
            channelId: channelId,
            isDefaultChannel: isDefaultChannel,
            manageOption: isChannelAdmin ? MAKE_CHANNEL_MEMBER : MAKE_CHANNEL_ADMIN,
            testID: 'channel.make_channel_admin',
            userId: userId,
          ),
        ManageMembersLabel(
          channelId: channelId,
          isDefaultChannel: isDefaultChannel,
          manageOption: REMOVE_USER,
          testID: 'channel.remove_member',
          userId: userId,
        ),
      ],
    );
  }

  Map<String, dynamic> _getStyleSheet(Theme theme) {
    return {
      'divider': {
        'alignSelf': Alignment.center,
        'backgroundColor': changeOpacity(theme.centerChannelColor, 0.16),
        'height': 1.0,
        'marginVertical': DIVIDER_MARGIN,
        'paddingHorizontal': 20.0,
        'width': double.infinity,
      },
    };
  }
}
