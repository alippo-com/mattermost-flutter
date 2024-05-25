// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

import 'package:mattermost_flutter/types.dart'; // Assuming the types are defined here
import 'package:mattermost_flutter/i18n.dart'; // Assuming localization setup
import 'package:mattermost_flutter/components/settings/block.dart';
import 'package:mattermost_flutter/components/settings/option.dart';
import 'package:mattermost_flutter/components/settings/separator.dart';

class ReplySettings extends StatelessWidget {
  final String replyNotificationType;
  final ValueChanged<String> setReplyNotificationType;

  ReplySettings({required this.replyNotificationType, required this.setReplyNotificationType});

  @override
  Widget build(BuildContext context) {
    final intl = Intl.of(context);

    return SettingBlock(
      headerText: Text(intl.message("Send reply notifications for", name: "notification_settings.mention.reply")),
      children: [
        SettingOption(
          action: setReplyNotificationType,
          label: intl.message("Threads that I start or participate in", name: "notification_settings.threads_start_participate"),
          selected: replyNotificationType == 'any',
          testID: 'mention_notification_settings.threads_start_participate.option',
          type: 'select',
          value: 'any',
        ),
        SettingSeparator(),
        SettingOption(
          action: setReplyNotificationType,
          label: intl.message("Threads that I start", name: "notification_settings.threads_start"),
          selected: replyNotificationType == 'root',
          testID: 'mention_notification_settings.threads_start.option',
          type: 'select',
          value: 'root',
        ),
        SettingSeparator(),
        SettingOption(
          action: setReplyNotificationType,
          label: intl.message("Mentions in threads", name: "notification_settings.threads_mentions"),
          selected: replyNotificationType == 'never',
          testID: 'mention_notification_settings.threads_mentions.option',
          type: 'select',
          value: 'never',
        ),
      ],
    );
  }
}
