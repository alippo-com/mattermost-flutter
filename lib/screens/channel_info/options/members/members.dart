// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import 'option_item.dart';
import 'screens.dart';
import 'theme.dart';
import 'navigation.dart';
import 'tap.dart';
import 'theme_utils.dart';

class Members extends StatelessWidget {
  final String channelId;
  final String displayName;
  final int count;

  const Members({
    required this.channelId,
    required this.displayName,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    final theme = useTheme(context);
    final formatMessage = intl.Intl.message;
    final title = formatMessage('Members', name: 'channel_info.members');

    void goToChannelMembers() {
      final options = {
        'topBar': {
          'subtitle': {
            'color': changeOpacity(theme.sidebarHeaderTextColor, 0.72),
            'text': displayName,
          },
        },
      };
      goToScreen(
        context,
        Screens.MANAGE_CHANNEL_MEMBERS,
        title,
        {'channelId': channelId},
        options,
      );
    }

    return OptionItem(
      action: () => preventDoubleTap(goToChannelMembers),
      label: title,
      icon: Icons.account_circle, // Use a suitable icon for 'account-multiple-outline'
      type: Platform.isIOS ? OptionItemType.arrow : OptionItemType.defaultType,
      info: count.toString(),
      testID: 'channel_info.options.members.option',
    );
  }
}

ThemeData useTheme(BuildContext context) {
  // Implement your useTheme function here, or replace with your theme provider logic
  return Theme.of(context);
}

double changeOpacity(Color color, double opacity) {
  return color.withOpacity(opacity).opacity;
}
