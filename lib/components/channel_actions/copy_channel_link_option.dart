import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:mattermost_flutter/components/option_item.dart';
import 'package:mattermost_flutter/components/slide_up_panel_item.dart';
import 'package:mattermost_flutter/constants/screens.dart';
import 'package:mattermost_flutter/constants/snack_bar.dart';
import 'package:mattermost_flutter/context/server.dart';
import 'package:mattermost_flutter/screens/navigation.dart';
import 'package:mattermost_flutter/utils/snack_bar.dart';

class CopyChannelLinkOption extends StatelessWidget {
  final String? channelName;
  final String? teamName;
  final bool? showAsLabel;
  final String? testID;

  CopyChannelLinkOption({
    this.channelName,
    this.teamName,
    this.showAsLabel,
    this.testID,
  });

  @override
  Widget build(BuildContext context) {
    final intl = Intl.message;
    final serverUrl = useServerUrl();

    void onCopyLink() async {
      Clipboard.setData(ClipboardData(text: '\$serverUrl/\$teamName/channels/\$channelName'));
      await dismissBottomSheet();
      showSnackBar(
        barType: SNACK_BAR_TYPE.LINK_COPIED,
        sourceScreen: CHANNEL_INFO,
      );
    }

    if (showAsLabel == true) {
      return SlideUpPanelItem(
        onPress: onCopyLink,
        text: intl('channel_info.copy_link', defaultMessage: 'Copy Link'),
        leftIcon: Icons.link,
        testID: testID,
      );
    }

    return OptionItem(
      action: onCopyLink,
      label: intl('channel_info.copy_link', defaultMessage: 'Copy Link'),
      icon: Icons.link,
      type: 'default',
      testID: testID,
    );
  }
}
