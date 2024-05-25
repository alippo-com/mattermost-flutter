// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mattermost_flutter/actions/remote/preference.dart';
import 'package:mattermost_flutter/actions/remote/user.dart';
import 'package:mattermost_flutter/components/settings/block.dart';
import 'package:mattermost_flutter/components/settings/container.dart';
import 'package:mattermost_flutter/components/settings/option.dart';
import 'package:mattermost_flutter/components/settings/separator.dart';
import 'package:mattermost_flutter/constants.dart';
import 'package:mattermost_flutter/context/server.dart';
import 'package:mattermost_flutter/context/theme.dart';
import 'package:mattermost_flutter/hooks/android_back_handler.dart';
import 'package:mattermost_flutter/hooks/navigate_back.dart';
import 'package:mattermost_flutter/i18n.dart';
import 'package:mattermost_flutter/screens/navigation.dart';
import 'package:mattermost_flutter/types/user_model.dart';
import 'package:mattermost_flutter/utils/theme.dart';
import 'package:mattermost_flutter/utils/typography.dart';
import 'package:mattermost_flutter/utils/user.dart';

const emailHeaderText = {
  'id': 'notification_settings.email.send',
  'defaultMessage': 'Send email notifications',
};
const emailFooterText = {
  'id': 'notification_settings.email.emailInfo',
  'defaultMessage': 'Email notifications are sent for mentions and direct messages when you are offline or away for more than 5 minutes.',
};

const emailHeaderCRTText = {
  'id': 'notification_settings.email.crt.send',
  'defaultMessage': 'Thread reply notifications',
};
const emailFooterCRTText = {
  'id': 'notification_settings.email.crt.emailInfo',
  'defaultMessage': "When enabled, any reply to a thread you're following will send an email notification",
};

class NotificationEmail extends StatefulWidget {
  final String componentId;
  final UserModel? currentUser;
  final String emailInterval;
  final bool enableEmailBatching;
  final bool isCRTEnabled;
  final bool sendEmailNotifications;

  NotificationEmail({
    required this.componentId,
    this.currentUser,
    required this.emailInterval,
    required this.enableEmailBatching,
    required this.isCRTEnabled,
    required this.sendEmailNotifications,
  });

  @override
  _NotificationEmailState createState() => _NotificationEmailState();
}

class _NotificationEmailState extends State<NotificationEmail> {
  late String notifyInterval;
  late bool emailThreads;
  late Map<String, dynamic> notifyProps;

  @override
  void initState() {
    super.initState();
    notifyProps = getNotificationProps(widget.currentUser);
    notifyInterval = getEmailInterval(
      widget.sendEmailNotifications && notifyProps['email'] == 'true',
      widget.enableEmailBatching,
      int.parse(widget.emailInterval),
    ).toString();
    emailThreads = notifyProps['email_threads'] == 'all';
  }

  void saveEmail() {
    if (widget.currentUser == null) {
      return;
    }

    final canSaveSetting = notifyInterval != widget.emailInterval || emailThreads != (notifyProps['email_threads'] == 'all');
    if (canSaveSetting) {
      List<Future> promises = [];
      final updatePromise = updateMe(context.read<ServerUrl>(), {
        'notify_props': {
          ...notifyProps,
          'email': '${widget.sendEmailNotifications && notifyInterval != Preferences.INTERVAL_NEVER.toString()}',
          if (widget.isCRTEnabled) 'email_threads': emailThreads ? 'all' : 'mention',
        },
      });
      promises.add(updatePromise);

      if (notifyInterval != widget.emailInterval) {
        final emailIntervalPreference = {
          'category': Preferences.CATEGORIES.NOTIFICATIONS,
          'name': Preferences.EMAIL_INTERVAL,
          'user_id': widget.currentUser!.id,
          'value': notifyInterval,
        };
        final savePrefPromise = savePreference(context.read<ServerUrl>(), [emailIntervalPreference]);
        promises.add(savePrefPromise);
      }
      Future.wait(promises);
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeContext>().theme;
    final styles = getStyleSheet(theme);
    final intl = AppLocalizations.of(context)!;

    useBackNavigation(saveEmail);
    useAndroidHardwareBackHandler(widget.componentId, saveEmail);

    return Scaffold(
      appBar: AppBar(
        title: Text(intl.translate('notification_settings.email.send')),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SettingContainer(
              testID: 'email_notification_settings',
              children: [
                SettingBlock(
                  disableFooter: !widget.sendEmailNotifications,
                  footerText: emailFooterText,
                  headerText: emailHeaderText,
                  children: [
                    if (widget.sendEmailNotifications) ...[
                      SettingOption(
                        action: () => setState(() => notifyInterval = Preferences.INTERVAL_IMMEDIATE.toString()),
                        label: intl.translate('notification_settings.email.immediately'),
                        selected: notifyInterval == Preferences.INTERVAL_IMMEDIATE.toString(),
                        testID: 'email_notification_settings.immediately.option',
                        type: SettingOptionType.select,
                        value: Preferences.INTERVAL_IMMEDIATE.toString(),
                      ),
                      SettingSeparator(),
                      if (widget.enableEmailBatching) ...[
                        SettingOption(
                          action: () => setState(() => notifyInterval = Preferences.INTERVAL_FIFTEEN_MINUTES.toString()),
                          label: intl.translate('notification_settings.email.fifteenMinutes'),
                          selected: notifyInterval == Preferences.INTERVAL_FIFTEEN_MINUTES.toString(),
                          testID: 'email_notification_settings.every_fifteen_minutes.option',
                          type: SettingOptionType.select,
                          value: Preferences.INTERVAL_FIFTEEN_MINUTES.toString(),
                        ),
                        SettingSeparator(),
                        SettingOption(
                          action: () => setState(() => notifyInterval = Preferences.INTERVAL_HOUR.toString()),
                          label: intl.translate('notification_settings.email.everyHour'),
                          selected: notifyInterval == Preferences.INTERVAL_HOUR.toString(),
                          testID: 'email_notification_settings.every_hour.option',
                          type: SettingOptionType.select,
                          value: Preferences.INTERVAL_HOUR.toString(),
                        ),
                        SettingSeparator(),
                      ],
                      SettingOption(
                        action: () => setState(() => notifyInterval = Preferences.INTERVAL_NEVER.toString()),
                        label: intl.translate('notification_settings.email.never'),
                        selected: notifyInterval == Preferences.INTERVAL_NEVER.toString(),
                        testID: 'email_notification_settings.never.option',
                        type: SettingOptionType.select,
                        value: Preferences.INTERVAL_NEVER.toString(),
                      ),
                    ],
                    if (!widget.sendEmailNotifications)
                      Text(
                        intl.translate('notification_settings.email.emailHelp2'),
                        style: styles['disabled'],
                      ),
                  ],
                ),
                if (widget.isCRTEnabled && notifyInterval != Preferences.INTERVAL_NEVER.toString())
                  SettingBlock(
                    footerText: emailFooterCRTText,
                    headerText: emailHeaderCRTText,
                    children: [
                      SettingOption(
                        action: () => setState(() => emailThreads = !emailThreads),
                        label: intl.translate('user.settings.notifications.email_threads.description'),
                        selected: emailThreads,
                        testID: 'email_notification_settings.email_threads.option',
                        type: SettingOptionType.toggle,
                      ),
                      SettingSeparator(),
                    ],
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Map<String, TextStyle> getStyleSheet(ThemeData theme) {
    return {
      'disabled': TextStyle(
        color: changeOpacity(theme.textTheme.bodyText1?.color, 0.64),
        ...typography('Body', 75, 'Regular'),
        marginHorizontal: 20,
      ),
    };
  }
}
