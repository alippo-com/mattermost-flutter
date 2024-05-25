
// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:mattermost_flutter/components/option_item.dart';
import 'package:mattermost_flutter/constants/notification_level.dart';
import 'package:mattermost_flutter/constants/screens.dart';
import 'package:mattermost_flutter/types/channel_type.dart';
import 'package:mattermost_flutter/utils/channel.dart';
import 'package:mattermost_flutter/utils/tap.dart';
import 'package:mattermost_flutter/utils/theme.dart';
import 'package:provider/provider.dart';
import 'package:internationalization/internationalization.dart';

class NotificationPreference extends StatelessWidget {
  final String channelId;
  final String displayName;
  final NotificationLevel notifyLevel;
  final NotificationLevel userNotifyLevel;
  final ChannelType channelType;
  final bool hasGMasDMFeature;

  const NotificationPreference({
    Key? key,
    required this.channelId,
    required this.displayName,
    required this.notifyLevel,
    required this.userNotifyLevel,
    required this.channelType,
    required this.hasGMasDMFeature,
  }) : super(key: key);

  Map<String, String> notificationLevel(NotificationLevel notifyLevel) {
    String id = '';
    String defaultMessage = '';
    switch (notifyLevel) {
      case NotificationLevel.ALL:
        id = 'channel_info.notification.all';
        defaultMessage = 'All';
        break;
      case NotificationLevel.MENTION:
        id = 'channel_info.notification.mention';
        defaultMessage = 'Mentions';
        break;
      case NotificationLevel.NONE:
        id = 'channel_info.notification.none';
        defaultMessage = 'Never';
        break;
      default:
        id = 'channel_info.notification.default';
        defaultMessage = 'Default';
        break;
    }
    return {'id': id, 'defaultMessage': defaultMessage};
  }

  @override
  Widget build(BuildContext context) {
    final formatMessage = Provider.of<Internationalization>(context);
    final theme = Provider.of<ThemeProvider>(context).theme;
    final title = formatMessage.translate('channel_info.mobile_notifications', 'Mobile Notifications');

    final goToChannelNotificationPreferences = preventDoubleTap(() {
      final options = {
        'topBar': {
          'title': {'text': title},
          'subtitle': {'color': changeOpacity(theme.sidebarHeaderTextColor, 0.72), 'text': displayName},
          'backButton': {'popStackOnPress': false},
        },
      };
      goToScreen(context, Screens.CHANNEL_NOTIFICATION_PREFERENCES, title, {'channelId': channelId}, options);
    });

    String notificationLevelToText() {
      var notifyLevelToUse = notifyLevel;
      if (notifyLevelToUse == NotificationLevel.DEFAULT) {
        notifyLevelToUse = userNotifyLevel;
      }

      if (hasGMasDMFeature) {
        if (notifyLevel == NotificationLevel.DEFAULT &&
            notifyLevelToUse == NotificationLevel.MENTION &&
            isTypeDMorGM(channelType)) {
          notifyLevelToUse = NotificationLevel.ALL;
        }
      }

      final messageDescriptor = notificationLevel(notifyLevelToUse);
      return formatMessage.translate(messageDescriptor['id']!, messageDescriptor['defaultMessage']!);
    }

    return OptionItem(
      action: goToChannelNotificationPreferences,
      label: title,
      icon: Icons.smartphone,
      type: Platform.isIOS ? 'arrow' : 'default',
      info: notificationLevelToText(),
      testID: 'channel_info.options.notification_preference.option',
    );
  }
}
