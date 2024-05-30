
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mattermost_flutter/components/option_item.dart';
import 'package:mattermost_flutter/utils/tap.dart';

class ConvertToChannelLabel extends StatelessWidget {
  final String channelId;

  ConvertToChannelLabel({required this.channelId});

  @override
  Widget build(BuildContext context) {
    final formatMessage = (String id, {required String defaultMessage}) {
      return Intl.message(defaultMessage, name: id);
    };

    Future<void> goToConvertToPrivateChannel() async {
      await dismissBottomSheet();
      final title = formatMessage('channel_info.convert_gm_to_channel.screen_title', defaultMessage: 'Convert to Private Channel');
      goToScreen(context, Screens.CONVERT_GM_TO_CHANNEL, title, {'channelId': channelId});
    }

    return OptionItem(
      action: preventDoubleTap(goToConvertToPrivateChannel),
      icon: Icons.lock_outline,
      label: formatMessage('channel_info.convert_gm_to_channel', defaultMessage: 'Convert to a Private Channel'),
      type: 'default',
    );
  }
}
