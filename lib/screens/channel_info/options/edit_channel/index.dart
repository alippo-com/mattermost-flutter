
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mattermost_flutter/components/option_item.dart';
import 'package:mattermost_flutter/constants/screens.dart';
import 'package:mattermost_flutter/utils/navigation.dart';
import 'package:mattermost_flutter/utils/tap.dart';

class EditChannel extends StatefulWidget {
  final String channelId;

  EditChannel({required this.channelId});

  @override
  _EditChannelState createState() => _EditChannelState();
}

class _EditChannelState extends State<EditChannel> {
  late String title;

  @override
  void initState() {
    super.initState();
    final intl = AppLocalizations.of(context);
    title = intl.screensChannelEdit;
  }

  void goToEditChannel() {
    preventDoubleTap(() async {
      goToScreen(Screens.createOrEditChannel, title, {'channelId': widget.channelId});
    });
  }

  @override
  Widget build(BuildContext context) {
    return OptionItem(
      action: goToEditChannel,
      label: title,
      icon: Icons.edit,
      type: Platform.isIOS ? 'arrow' : 'default',
      testID: 'channel_info.options.edit_channel.option',
    );
  }
}
