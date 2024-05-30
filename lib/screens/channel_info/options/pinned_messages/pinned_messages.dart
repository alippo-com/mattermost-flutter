// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mattermost_flutter/constants.dart';
import 'package:mattermost_flutter/types/user_custom_status.dart';
import 'package:mattermost_flutter/utils/theme.dart';
import 'package:mattermost_flutter/widgets/custom_status/clear_button.dart';
import 'package:mattermost_flutter/widgets/custom_status/custom_status_expiry.dart';
import 'package:mattermost_flutter/widgets/formatted_text.dart';
import 'package:mattermost_flutter/widgets/custom_status/custom_status_text.dart';
import 'package:mattermost_flutter/widgets/option_item.dart';
import 'package:mattermost_flutter/utils/tap.dart';

class PinnedMessages extends StatelessWidget {
  final String channelId;
  final int count;
  final String displayName;

  PinnedMessages({
    required this.channelId,
    required this.count,
    required this.displayName,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final intl = Intl.message;
    final title = intl('channel_info.pinned_messages', name: 'Pinned Messages');

    void goToPinnedMessages() {
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
      goToScreen(Screens.PINNED_MESSAGES, title, {'channelId': channelId}, options);
    }

    return OptionItem(
      action: preventDoubleTap(goToPinnedMessages),
      label: title,
      icon: Icons.pin_outlined,
      type: Platform.isIOS ? 'arrow' : 'default',
      info: count.toString(),
      testID: 'channel_info.options.pinned_messages.option',
    );
  }
}
