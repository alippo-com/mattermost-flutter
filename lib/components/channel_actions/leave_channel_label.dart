import 'package:flutter/material.dart';
import 'package:mattermost_flutter/components/option_item.dart';
import 'package:mattermost_flutter/components/slide_up_panel_item.dart';
import 'package:mattermost_flutter/constants/general.dart';
import 'package:mattermost_flutter/context/server.dart';
import 'package:mattermost_flutter/hooks/device.dart';
import 'package:mattermost_flutter/screens/navigation.dart';
import 'package:mattermost_flutter/actions/remote/channel.dart';
import 'package:mattermost_flutter/actions/remote/preference.dart';

class LeaveChannelLabel extends StatelessWidget {
  final bool canLeave;
  final String channelId;
  final String? displayName;
  final bool isOptionItem;
  final String? type;
  final String? testID;

  LeaveChannelLabel({
    this.isOptionItem = false,
    required this.canLeave,
    required this.channelId,
    this.displayName,
    this.type,
    this.testID,
  });

  @override
  Widget build(BuildContext context) {
    final intl = Intl.of(context);
    final serverUrl = useServerUrl(context);
    final isTablet = useIsTablet(context);

    void close() async {
      await dismissBottomSheet(context);
      if (!isTablet) {
        await dismissAllModalsAndPopToRoot(context);
      }
    }

    void closeDirectMessage() {
      showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: Text(intl.formatMessage(id: 'channel_info.close_dm', defaultMessage: 'Close direct message')),
          content: Text(intl.formatMessage(
              id: 'channel_info.close_dm_channel',
              defaultMessage: 'Are you sure you want to close this direct message? This will remove it from your home screen, but you can always open it again.')),
          actions: <Widget>[
            TextButton(
              child: Text(intl.formatMessage(id: 'mobile.post.cancel', defaultMessage: 'Cancel')),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text(intl.formatMessage(id: 'channel_info.close', defaultMessage: 'Close')),
              onPressed: () {
                setDirectChannelVisible(serverUrl, channelId, false);
                close();
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      );
    }

    void closeGroupMessage() {
      showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: Text(intl.formatMessage(id: 'channel_info.close_gm', defaultMessage: 'Close group message')),
          content: Text(intl.formatMessage(
              id: 'channel_info.close_gm_channel',
              defaultMessage: 'Are you sure you want to close this group message? This will remove it from your home screen, but you can always open it again.')),
          actions: <Widget>[
            TextButton(
              child: Text(intl.formatMessage(id: 'mobile.post.cancel', defaultMessage: 'Cancel')),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text(intl.formatMessage(id: 'channel_info.close', defaultMessage: 'Close')),
              onPressed: () {
                setDirectChannelVisible(serverUrl, channelId, false);
                close();
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      );
    }

    void leavePublicChannel() {
      showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: Text(intl.formatMessage(id: 'channel_info.leave_channel', defaultMessage: 'Leave Channel')),
          content: Text(intl.formatMessage(
              id: 'channel_info.leave_public_channel',
              defaultMessage: 'Are you sure you want to leave the public channel {displayName}? You can always rejoin.',
              args: {'displayName': displayName})),
          actions: <Widget>[
            TextButton(
              child: Text(intl.formatMessage(id: 'mobile.post.cancel', defaultMessage: 'Cancel')),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text(intl.formatMessage(id: 'channel_info.leave', defaultMessage: 'Leave')),
              onPressed: () {
                leaveChannel(serverUrl, channelId);
                close();
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      );
    }

    void leavePrivateChannel() {
      showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: Text(intl.formatMessage(id: 'channel_info.leave_channel', defaultMessage: 'Leave Channel')),
          content: Text(intl.formatMessage(
              id: 'channel_info.leave_private_channel',
              defaultMessage: "Are you sure you want to leave the private channel {displayName}? You cannot rejoin the channel unless you're invited again.",
              args: {'displayName': displayName})),
          actions: <Widget>[
            TextButton(
              child: Text(intl.formatMessage(id: 'mobile.post.cancel', defaultMessage: 'Cancel')),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text(intl.formatMessage(id: 'channel_info.leave', defaultMessage: 'Leave')),
              onPressed: () {
                leaveChannel(serverUrl, channelId);
                close();
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      );
    }

    void onLeave() {
      switch (type) {
        case General.OPEN_CHANNEL:
          leavePublicChannel();
          break;
        case General.PRIVATE_CHANNEL:
          leavePrivateChannel();
          break;
        case General.DM_CHANNEL:
          closeDirectMessage();
          break;
        case General.GM_CHANNEL:
          closeGroupMessage();
          break;
      }
    }

    if (displayName == null || type == null || !canLeave) {
      return Container();
    }

    String leaveText;
    IconData icon;
    switch (type) {
      case General.DM_CHANNEL:
        leaveText = intl.formatMessage(id: 'channel_info.close_dm', defaultMessage: 'Close direct message');
        icon = Icons.close;
        break;
      case General.GM_CHANNEL:
        leaveText = intl.formatMessage(id: 'channel_info.close_gm', defaultMessage: 'Close group message');
        icon = Icons.close;
        break;
      default:
        leaveText = intl.formatMessage(id: 'channel_info.leave_channel', defaultMessage: 'Leave channel');
        icon = Icons.exit_to_app;
        break;
    }

    if (isOptionItem) {
      return OptionItem(
        action: onLeave,
        destructive: true,
        icon: icon,
        label: leaveText,
        testID: testID,
        type: 'default',
      );
    }

    return SlideUpPanelItem(
      destructive: true,
      leftIcon: icon,
      onPress: onLeave,
      text: leaveText,
      testID: testID,
    );
  }
}
