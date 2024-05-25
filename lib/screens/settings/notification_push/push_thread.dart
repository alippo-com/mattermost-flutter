
// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/material.dart';
import 'package:mattermost_flutter/components/setting_block.dart';
import 'package:mattermost_flutter/components/setting_option.dart';
import 'package:mattermost_flutter/components/setting_separator.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:mattermost_flutter/types.dart'; // Assuming the types are defined here

class MobilePushThread extends StatelessWidget {
  final Function(String) onMobilePushThreadChanged;
  final UserNotifyPropsPushThreads pushThread;

  MobilePushThread({required this.onMobilePushThreadChanged, required this.pushThread});

  @override
  Widget build(BuildContext context) {
    final headerText = {
      'id': t('notification_settings.push_threads.replies'),
      'defaultMessage': 'Thread replies',
    };

    return SettingBlock(
      headerText: headerText,
      children: <Widget>[
        SettingOption(
          action: onMobilePushThreadChanged,
          label: translate('notification_settings.push_threads.following', args: {'defaultMessage': 'Notify me about replies to threads I'm following in this channel'}),
          selected: pushThread == 'all',
          testID: 'push_notification_settings.push_threads_following.option',
          type: 'toggle',
        ),
        SettingSeparator(),
      ],
    );
  }
}
