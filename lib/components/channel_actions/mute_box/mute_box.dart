// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/material.dart';
import 'package:mattermost_flutter/actions/remote/channel.dart';
import 'package:mattermost_flutter/components/option_box.dart';
import 'package:mattermost_flutter/context/server.dart';
import 'package:mattermost_flutter/screens/navigation.dart';
import 'package:intl/intl.dart';

class MuteBox extends StatelessWidget {
  final String channelId;
  final BoxDecoration? containerStyle;
  final bool isMuted;
  final bool showSnackBar;
  final String? testID;

  MuteBox({
    required this.channelId,
    this.containerStyle,
    required this.isMuted,
    this.showSnackBar = false,
    this.testID,
  });

  @override
  Widget build(BuildContext context) {
    final intl = Intl.message;
    final serverUrl = useServerUrl(context);

    Future<void> handleOnPress() async {
      await dismissBottomSheet();
      toggleMuteChannel(serverUrl, channelId, showSnackBar);
    }

    final muteActionTestId = isMuted ? '\${testID}.unmute.action' : '\${testID}.mute.action';

    return OptionBox(
      activeIconName: Icons.notifications_off,
      activeText: intl('channel_info.muted', name: 'Muted'),
      containerStyle: containerStyle,
      iconName: Icons.notifications,
      isActive: isMuted,
      onPress: handleOnPress,
      testID: muteActionTestId,
      text: intl('channel_info.mute', name: 'Mute'),
    );
  }
}
