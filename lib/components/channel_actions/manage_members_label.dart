import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:mattermost_flutter/components/option_item.dart';
import 'package:mattermost_flutter/constants/events.dart';
import 'package:mattermost_flutter/utils/alert.dart';
import 'package:mattermost_flutter/utils/dismiss_bottom_sheet.dart';
import 'package:mattermost_flutter/utils/snack_bar.dart';
import 'package:mattermost_flutter/context/server.dart';

class ManageMembersLabel extends StatelessWidget {
  final bool canRemoveUser;
  final String channelId;
  final ManageOptionsTypes manageOption;
  final String? testID;
  final String userId;

  ManageMembersLabel({
    required this.canRemoveUser,
    required this.channelId,
    required this.manageOption,
    this.testID,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    final intl = Intl.message;
    final serverUrl = Provider.of<ServerUrl>(context);

    void handleRemoveUser() async {
      final res = await removeMemberFromChannel(serverUrl, channelId, userId);
      if (res.error == null) {
        fetchChannelStats(serverUrl, channelId, false);
      }
      await dismissBottomSheet();
      DeviceEventEmitter.emit(Events.REMOVE_USER_FROM_CHANNEL, userId);
    }

    void removeFromChannel() {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(intl('mobile.manage_members.remove_member', defaultMessage: 'Remove From Channel')),
            content: Text(intl('mobile.manage_members.message', defaultMessage: 'Are you sure you want to remove the selected member from the channel?')),
            actions: [
              TextButton(
                child: Text(intl('mobile.manage_members.cancel', defaultMessage: 'Cancel')),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: Text(intl('mobile.manage_members.remove', defaultMessage: 'Remove')),
                onPressed: () {
                  handleRemoveUser();
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }

    void updateChannelMemberSchemeRole(bool schemeAdmin) async {
      final result = await updateChannelMemberSchemeRoles(serverUrl, channelId, userId, true, schemeAdmin);
      if (result.error != null) {
        alertErrorWithFallback(context, intl('mobile.manage_members.change_role.error', defaultMessage: 'An error occurred while trying to update the role. Please check your connection and try again.'));
      }
      await dismissBottomSheet();
      DeviceEventEmitter.emit(Events.MANAGE_USER_CHANGE_ROLE, {'userId': userId, 'schemeAdmin': schemeAdmin});
    }

    void onAction() {
      switch (manageOption) {
        case ManageOptionsTypes.REMOVE_USER:
          removeFromChannel();
          break;
        case ManageOptionsTypes.MAKE_CHANNEL_ADMIN:
          updateChannelMemberSchemeRole(true);
          break;
        case ManageOptionsTypes.MAKE_CHANNEL_MEMBER:
          updateChannelMemberSchemeRole(false);
          break;
        default:
          break;
      }
    }

    String? actionText;
    IconData? icon;
    bool isDestructive = false;
    switch (manageOption) {
      case ManageOptionsTypes.REMOVE_USER:
        actionText = intl('mobile.manage_members.remove_member', defaultMessage: 'Remove From Channel');
        icon = Icons.delete_outline;
        isDestructive = true;
        break;
      case ManageOptionsTypes.MAKE_CHANNEL_ADMIN:
        actionText = intl('mobile.manage_members.make_channel_admin', defaultMessage: 'Make Channel Admin');
        icon = Icons.admin_panel_settings_outlined;
        break;
      case ManageOptionsTypes.MAKE_CHANNEL_MEMBER:
        actionText = intl('mobile.manage_members.make_channel_member', defaultMessage: 'Make Channel Member');
        icon = Icons.person_outline;
        break;
    }

    if (manageOption == ManageOptionsTypes.REMOVE_USER && !canRemoveUser) {
      return SizedBox.shrink();
    }

    if (actionText == null) {
      return SizedBox.shrink();
    }

    return OptionItem(
      action: onAction,
      destructive: isDestructive,
      icon: icon,
      label: actionText,
      testID: testID,
      type: 'default',
    );
  }
}
