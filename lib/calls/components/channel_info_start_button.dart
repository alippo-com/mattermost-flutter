import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // Assuming localization is handled similarly
import 'package:mattermost_flutter/types/calls.dart'; // Assuming necessary types and actions are defined here
import 'package:mattermost_flutter/components/option_box.dart'; // Assuming this component exists
import 'package:mattermost_flutter/utils/tap.dart'; // Assuming a utility for preventing double-tap exists

class ChannelInfoStartButton extends StatefulWidget {
  final String serverUrl;
  final String channelId;
  final bool isACallInCurrentChannel;
  final bool alreadyInCall;
  final VoidCallback dismissChannelInfo;
  final LimitRestrictedInfo limitRestrictedInfo;

  ChannelInfoStartButton({
    required this.serverUrl,
    required this.channelId,
    required this.isACallInCurrentChannel,
    required this.alreadyInCall,
    required this.dismissChannelInfo,
    required this.limitRestrictedInfo,
  });

  @override
  _ChannelInfoStartButtonState createState() => _ChannelInfoStartButtonState();
}

class _ChannelInfoStartButtonState extends State<ChannelInfoStartButton> {
  void toggleJoinLeave() {
    if (widget.alreadyInCall) {
      leaveCall();
    } else if (widget.limitRestrictedInfo.limitRestricted) {
      showLimitRestrictedAlert(widget.limitRestrictedInfo, AppLocalizations.of(context));
    } else {
      leaveAndJoinWithAlert(AppLocalizations.of(context), widget.serverUrl, widget.channelId);
    }

    widget.dismissChannelInfo();
  }

  @override
  Widget build(BuildContext context) {
    final intl = AppLocalizations.of(context);
    final joinText = intl.mobile_calls_join_call;
    final startText = intl.mobile_calls_start_call;
    final leaveText = intl.mobile_calls_leave_call;

    return OptionBox(
      onPress: preventDoubleTap(toggleJoinLeave),
      text: startText,
      iconName: 'phone',
      activeText: joinText,
      activeIconName: 'phone-in-talk',
      isActive: widget.isACallInCurrentChannel,
      destructiveText: leaveText,
      destructiveIconName: 'phone-hangup',
      isDestructive: widget.alreadyInCall,
      testID: 'channel_info.channel_actions.join_start_call.action',
    );
  }
}
