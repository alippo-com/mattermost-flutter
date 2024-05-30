
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:mattermost_flutter/components/settings/container.dart';
import 'package:mattermost_flutter/components/settings/item.dart';
import 'package:mattermost_flutter/constants/general.dart';
import 'package:mattermost_flutter/i18n.dart';
import 'package:mattermost_flutter/screens/settings/config.dart';
import 'package:mattermost_flutter/types/screens/navigation.dart';

class Notifications extends HookWidget {
  final AvailableScreens componentId;
  final UserModel? currentUser;
  final String emailInterval;
  final bool enableAutoResponder;
  final bool enableEmailBatching;
  final bool isCRTEnabled;
  final bool sendEmailNotifications;

  Notifications({
    required this.componentId,
    this.currentUser,
    required this.emailInterval,
    required this.enableAutoResponder,
    required this.enableEmailBatching,
    required this.isCRTEnabled,
    required this.sendEmailNotifications,
  });

  @override
  Widget build(BuildContext context) {
    final intl = useIntl();
    final notifyProps = useMemo(() => getNotificationProps(currentUser), [currentUser?.notifyProps]);

    final emailIntervalPref = useMemo(() {
      return getEmailInterval(
        sendEmailNotifications && notifyProps.email == 'true',
        enableEmailBatching,
        int.parse(emailInterval),
      ).toString();
    }, [emailInterval, enableEmailBatching, notifyProps, sendEmailNotifications]);

    final goToNotificationSettingsMentions = useCallback(() {
      final screen = Screens.SETTINGS_NOTIFICATION_MENTION;

      final id = isCRTEnabled ? t('notification_settings.mentions') : t('notification_settings.mentions_replies');
      final defaultMessage = isCRTEnabled ? 'Mentions' : 'Mentions and Replies';
      final title = intl.formatMessage(id, defaultMessage);
      gotoSettingsScreen(screen, title);
    }, [isCRTEnabled]);

    final goToNotificationSettingsPush = useCallback(() {
      final screen = Screens.SETTINGS_NOTIFICATION_PUSH;
      final title = intl.formatMessage(
        id: 'notification_settings.push_notification',
        defaultMessage: 'Push Notifications',
      );

      gotoSettingsScreen(screen, title);
    }, []);

    final goToNotificationAutoResponder = useCallback(() {
      final screen = Screens.SETTINGS_NOTIFICATION_AUTO_RESPONDER;
      final title = intl.formatMessage(
        id: 'notification_settings.auto_responder',
        defaultMessage: 'Automatic Replies',
      );
      gotoSettingsScreen(screen, title);
    }, []);

    final goToEmailSettings = useCallback(() {
      final screen = Screens.SETTINGS_NOTIFICATION_EMAIL;
      final title = intl.formatMessage(
        id: 'notification_settings.email',
        defaultMessage: 'Email Notifications',
      );
      gotoSettingsScreen(screen, title);
    }, []);

    final close = useCallback(() {
      popTopScreen(componentId);
    }, [componentId]);

    useAndroidHardwareBackHandler(componentId, close);

    return SettingContainer(
      testID: 'notification_settings',
      children: [
        SettingItem(
          onPress: goToNotificationSettingsMentions,
          optionName: 'mentions',
          label: intl.formatMessage(
            id: isCRTEnabled ? t('notification_settings.mentions') : t('notification_settings.mentions_replies'),
            defaultMessage: isCRTEnabled ? 'Mentions' : 'Mentions and Replies',
          ),
          testID: 'notification_settings.mentions.option',
        ),
        SettingItem(
          optionName: 'push_notification',
          onPress: goToNotificationSettingsPush,
          testID: 'notification_settings.push_notifications.option',
        ),
        SettingItem(
          optionName: 'email',
          onPress: goToEmailSettings,
          info: intl.formatMessage(getEmailIntervalTexts(emailIntervalPref)),
          testID: 'notification_settings.email_notifications.option',
        ),
        if (enableAutoResponder)
          SettingItem(
            onPress: goToNotificationAutoResponder,
            optionName: 'automatic_dm_replies',
            info: currentUser?.status == General.OUT_OF_OFFICE && notifyProps.auto_responder_active == 'true' ? 'On' : 'Off',
            testID: 'notification_settings.automatic_replies.option',
          ),
      ],
    );
  }
}
