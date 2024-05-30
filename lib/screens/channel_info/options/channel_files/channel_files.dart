// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mattermost_flutter/constants.dart';
import 'package:mattermost_flutter/utils/theme.dart';
import 'package:mattermost_flutter/widgets/option_item.dart';
import 'package:mattermost_flutter/utils/tap.dart';

class ChannelFiles extends StatelessWidget {
  final String channelId;
  final int count;
  final String displayName;

  ChannelFiles({
    required this.channelId,
    required this.count,
    required this.displayName,
  });

  @override
  Widget build(BuildContext context) {
    final theme = useTheme(context);
    final title = Intl.message('Files', name: 'channel_info.channel_files');

    void goToChannelFiles() {
      final options = {
        'topBar': {
          'title': {
            'text': title,
          },
          'subtitle': {
            'color': changeOpacity(theme.sidebarHeaderTextColor, 0.72),
            'text': displayName,
          },
        },
      };
      goToScreen(context, Screens.CHANNEL_FILES, title, {'channelId': channelId}, options);
    }

    return OptionItem(
      action: preventDoubleTap(goToChannelFiles),
      label: title,
      icon: Icons.insert_drive_file,  // Example replacement icon
      type: Platform.isIOS ? 'arrow' : 'default',
      info: count.toString(),
      testID: 'channel_info.options.channel_files.option',
    );
  }
}
