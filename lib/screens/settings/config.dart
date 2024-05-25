// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:mattermost_flutter/intl.dart';
import 'package:mattermost_flutter/screens/navigation.dart';
import 'package:mattermost_flutter/utils/typography.dart';

import 'package:mattermost_flutter/types/screens/navigation.dart';
import 'package:mattermost_flutter/types/react_intl.dart';

Map<String, dynamic> getSaveButton(String buttonId, IntlShape intl, String color) {
  return {
    'color': color,
    'enabled': false,
    'id': buttonId,
    'showAsAction': 'always',
    'testID': 'notification_settings.mentions.save.button',
    'text': intl.formatMessage({'id': 'settings.save', 'defaultMessage': 'Save'}),
    ...typography('Body', 100, 'SemiBold'),
  };
}

void gotoSettingsScreen(AvailableScreens screen, String title) {
  final passProps = {};
  final options = {
    'topBar': {
      'backButton': {
        'popStackOnPress': false,
      },
    },
  };
  goToScreen(screen, title, passProps, options);
}

class SettingConfigDetails {
  final String? defaultMessage;
  final String? i18nId;
  final String? icon;
  final String? testID;

  SettingConfigDetails({this.defaultMessage, this.i18nId, this.icon, this.testID});
}

final Map<String, SettingConfigDetails> SettingOptionConfig = {
  'notification': SettingConfigDetails(
    defaultMessage: 'Notifications',
    i18nId: t('general_settings.notifications'),
    icon: 'bell-outline',
    testID: 'general_settings.notifications',
  ),
  'display': SettingConfigDetails(
    defaultMessage: 'Display',
    i18nId: t('general_settings.display'),
    icon: 'layers-outline',
    testID: 'general_settings.display',
  ),
  'advanced_settings': SettingConfigDetails(
    defaultMessage: 'Advanced Settings',
    i18nId: t('general_settings.advanced_settings'),
    icon: 'tune',
    testID: 'general_settings.advanced',
  ),
  'about': SettingConfigDetails(
    defaultMessage: 'About {appTitle}',
    i18nId: t('general_settings.about'),
    icon: 'information-outline',
    testID: 'general_settings.about',
  ),
  'help': SettingConfigDetails(
    defaultMessage: 'Help',
    i18nId: t('general_settings.help'),
    testID: 'general_settings.help',
  ),
  'report_problem': SettingConfigDetails(
    defaultMessage: 'Report a Problem',
    i18nId: t('general_settings.report_problem'),
    testID: 'general_settings.report_problem',
  ),
};

final Map<String, SettingConfigDetails> NotificationsOptionConfig = {
  'mentions': SettingConfigDetails(
    icon: 'at',
    testID: 'notification_settings.mentions_replies',
  ),
  'push_notification': SettingConfigDetails(
    defaultMessage: 'Push Notifications',
    i18nId: t('notification_settings.mobile'),
    icon: 'cellphone',
    testID: 'notification_settings.push_notification',
  ),
  'email': SettingConfigDetails(
    defaultMessage: 'Email',
    i18nId: t('notification_settings.email'),
    icon: 'email-outline',
    testID: 'notification_settings.email',
  ),
  'automatic_dm_replies': SettingConfigDetails(
    defaultMessage: 'Automatic replies',
    i18nId: t('notification_settings.ooo_auto_responder'),
    icon: 'reply-outline',
    testID: 'notification_settings.automatic_dm_replies',
  ),
};

final Map<String, SettingConfigDetails> DisplayOptionConfig = {
  'clock': SettingConfigDetails(
    defaultMessage: 'Clock Display',
    i18nId: t('mobile.display_settings.clockDisplay'),
    icon: 'clock-outline',
    testID: 'display_settings.clock',
  ),
  'crt': SettingConfigDetails(
    defaultMessage: 'Collapsed Reply Threads',
    i18nId: t('mobile.display_settings.crt'),
    icon: 'message-text-outline',
    testID: 'display_settings.crt',
  ),
  'theme': SettingConfigDetails(
    defaultMessage: 'Theme',
    i18nId: t('mobile.display_settings.theme'),
    icon: 'palette-outline',
    testID: 'display_settings.theme',
  ),
  'timezone': SettingConfigDetails(
    defaultMessage: 'Timezone',
    i18nId: t('mobile.display_settings.timezone'),
    icon: 'globe',
    testID: 'display_settings.timezone',
  ),
};

final Map<String, SettingConfigDetails> Config = {
  ...SettingOptionConfig,
  ...NotificationsOptionConfig,
  ...DisplayOptionConfig,
};
