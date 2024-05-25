// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mattermost_flutter/components/formatted_text.dart';
import 'package:mattermost_flutter/components/settings/block.dart';
import 'package:mattermost_flutter/components/settings/option.dart';
import 'package:mattermost_flutter/components/settings/separator.dart';
import 'package:mattermost_flutter/context/theme.dart';
import 'package:mattermost_flutter/i18n.dart';
import 'package:mattermost_flutter/utils/theme.dart';
import 'package:mattermost_flutter/utils/typography.dart';

class MobileSendPush extends StatelessWidget {
  final bool sendPushNotifications;
  final String pushStatus;
  final Function(String) setMobilePushPref;

  MobileSendPush({
    required this.sendPushNotifications,
    required this.pushStatus,
    required this.setMobilePushPref,
  });

  @override
  Widget build(BuildContext context) {
    final theme = useTheme(context);
    final styles = _getStyleSheet(theme);
    final intl = AppLocalizations.of(context);

    return SettingBlock(
      headerText: Intl.message('Notify me about...', name: 'notification_settings.send_notification.about'),
      children: sendPushNotifications
          ? [
              SettingOption(
                action: setMobilePushPref,
                label: intl.allNewMessages,
                selected: pushStatus == 'all',
                testID: 'push_notification_settings.all_new_messages.option',
                type: 'select',
                value: 'all',
              ),
              SettingSeparator(),
              SettingOption(
                action: setMobilePushPref,
                label: intl.mentionsOnly,
                selected: pushStatus == 'mention',
                testID: 'push_notification_settings.mentions_only.option',
                type: 'select',
                value: 'mention',
              ),
              SettingSeparator(),
              SettingOption(
                action: setMobilePushPref,
                label: intl.nothing,
                selected: pushStatus == 'none',
                testID: 'push_notification_settings.nothing.option',
                type: 'select',
                value: 'none',
              ),
              SettingSeparator(),
            ]
          : [
              FormattedText(
                defaultMessage: 'Push notifications for mobile devices have been disabled by your System Administrator.',
                id: 'notification_settings.pushNotification.disabled_long',
                style: styles['disabled'],
              ),
            ],
    );
  }

  Map<String, TextStyle> _getStyleSheet(ThemeData theme) {
    return {
      'disabled': TextStyle(
        color: theme.colorScheme.onSurface,
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        fontSize: 16,
        fontWeight: FontWeight.normal,
        fontFamily: 'Roboto',
      ),
    };
  }
}
