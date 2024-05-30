import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Equivalent for context
import 'package:mattermost_flutter/components/settings/block.dart';
import 'package:mattermost_flutter/components/settings/option.dart';
import 'package:mattermost_flutter/components/settings/separator.dart';
import 'package:mattermost_flutter/constants.dart';
import 'package:mattermost_flutter/i18n.dart';
import 'package:mattermost_flutter/types.dart'; // Equivalent for @typing directive

const double BLOCK_TITLE_HEIGHT = 13;

const NOTIFY_ABOUT = {'id': 'channel_notification_preferences.notify_about', 'defaultMessage': 'Notify me about...'};

const NOTIFY_OPTIONS = {
  NotificationLevel.ALL: {
    'defaultMessage': 'All new messages',
    'id': 'channel_notification_preferences.notification.all',
    'testID': 'channel_notification_preferences.notification.all',
    'value': NotificationLevel.ALL,
  },
  NotificationLevel.MENTION: {
    'defaultMessage': 'Mentions only',
    'id': 'channel_notification_preferences.notification.mention',
    'testID': 'channel_notification_preferences.notification.mention',
    'value': NotificationLevel.MENTION,
  },
  NotificationLevel.NONE: {
    'defaultMessage': 'Nothing',
    'id': 'channel_notification_preferences.notification.none',
    'testID': 'channel_notification_preferences.notification.none',
    'value': NotificationLevel.NONE,
  },
};

class NotifyAbout extends StatelessWidget {
  final bool isMuted;
  final NotificationLevel defaultLevel;
  final NotificationLevel notifyLevel;
  final ValueNotifier<double> notifyTitleTop;
  final Function(NotificationLevel) onPress;

  NotifyAbout({
    required this.isMuted,
    required this.defaultLevel,
    required this.notifyLevel,
    required this.notifyTitleTop,
    required this.onPress,
  });

  @override
  Widget build(BuildContext context) {
    final intl = Provider.of<Intl>(context);
    final theme = Provider.of<Theme>(context);

    void onLayout(LayoutChangeEvent e) {
      final y = e.nativeEvent.layout.y;
      notifyTitleTop.value = y > 0 ? y + 10 : BLOCK_TITLE_HEIGHT;
    }

    NotificationLevel notifyLevelToUse = notifyLevel;
    if (notifyLevel == NotificationLevel.DEFAULT) {
      notifyLevelToUse = defaultLevel;
    }

    return SettingBlock(
      headerText: NOTIFY_ABOUT,
      headerStyles: {'marginTop': isMuted ? 8.0 : 12.0},
      onLayout: onLayout,
      children: NOTIFY_OPTIONS.keys.map((key) {
        final option = NOTIFY_OPTIONS[key];
        final defaultOption = key == defaultLevel ? intl.formatMessage('channel_notification_preferences.default', defaultMessage: '(default)') : '';
        final label = '${intl.formatMessage(option['id'], defaultMessage: option['defaultMessage'])} $defaultOption';

        return Column(
          key: ValueKey('notif_pref_option$key'),
          children: [
            SettingOption(
              action: onPress,
              label: label,
              selected: notifyLevelToUse == key,
              testID: option['testID'],
              type: 'select',
              value: option['value'],
            ),
            SettingSeparator(),
          ],
        );
      }).toList(),
    );
  }
}
