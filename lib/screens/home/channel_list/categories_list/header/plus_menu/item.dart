// Converted Dart code from React Native TypeScript
// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/material.dart';
import 'package:mattermost_flutter/types/theme.dart';
import 'package:mattermost_flutter/components/slide_up_panel_item.dart';
import 'package:intl/intl.dart';

class PlusMenuItem extends StatelessWidget {
  final String pickerAction;
  final VoidCallback onPress;

  PlusMenuItem({
    required this.pickerAction,
    required this.onPress,
  });

  @override
  Widget build(BuildContext context) {
    final intl = Intl();

    final Map<String, dynamic> menuItems = {
      'browseChannels': {
        'leftIcon': Icons.public,
        'text': intl.message('plus_menu.browse_channels.title', name: 'Browse Channels'),
        'testID': 'plus_menu_item.browse_channels',
      },
      'createNewChannel': {
        'leftIcon': Icons.add,
        'text': intl.message('plus_menu.create_new_channel.title', name: 'Create New Channel'),
        'testID': 'plus_menu_item.create_new_channel',
      },
      'openDirectMessage': {
        'leftIcon': Icons.account_circle_outlined,
        'text': intl.message('plus_menu.open_direct_message.title', name: 'Open a Direct Message'),
        'testID': 'plus_menu_item.open_direct_message',
      },
      'invitePeopleToTeam': {
        'leftIcon': Icons.group_add_outlined,
        'text': intl.message('plus_menu.invite_people_to_team.title', name: 'Invite people to the team'),
        'testID': 'plus_menu_item.invite_people_to_team',
      },
    };

    final itemType = menuItems[pickerAction];

    return SlideUpPanelItem(
      leftIcon: itemType['leftIcon'],
      text: itemType['text'],
      testID: itemType['testID'],
      onPress: onPress,
    );
  }
}
