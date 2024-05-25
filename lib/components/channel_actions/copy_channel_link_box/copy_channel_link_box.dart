
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:mattermost_flutter/components/animated_option_box.dart';
import 'package:mattermost_flutter/context/server.dart';
import 'package:mattermost_flutter/context/theme.dart';

class CopyChannelLinkBox extends StatelessWidget {
  final String? channelName;
  final VoidCallback? onAnimationEnd;
  final String? teamName;
  final String? testID;

  CopyChannelLinkBox({this.channelName, this.onAnimationEnd, this.teamName, this.testID});

  @override
  Widget build(BuildContext context) {
    final intl = Intl.of(context);
    final theme = useTheme(context);
    final serverUrl = useServerUrl(context);

    void onCopyLink() {
      Clipboard.setData(ClipboardData(text: '$serverUrl/$teamName/channels/$channelName'));
    }

    return AnimatedOptionBox(
      animatedBackgroundColor: theme.onlineIndicator,
      animatedColor: theme.buttonColor,
      animatedIconName: Icons.check,
      animatedText: intl.formatMessage('channel_info.copied', defaultMessage: 'Copied'),
      iconName: Icons.link,
      onAnimationEnd: onAnimationEnd,
      onPress: onCopyLink,
      testID: testID,
      text: intl.formatMessage('channel_info.copy_link', defaultMessage: 'Copy Link'),
    );
  }
}
