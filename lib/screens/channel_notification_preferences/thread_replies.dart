import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mattermost_flutter/components/settings/block.dart';
import 'package:mattermost_flutter/components/settings/option.dart';
import 'package:mattermost_flutter/components/settings/separator.dart';
import 'package:mattermost_flutter/constants.dart';
import 'package:mattermost_flutter/i18n.dart';

enum NotificationLevel { NONE, ALL, THREAD }

class NotifyAbout extends StatelessWidget {
  final bool isSelected;
  final NotificationLevel notifyLevel;
  final Function(bool) onPress;

  NotifyAbout({
    required this.isSelected,
    required this.notifyLevel,
    required this.onPress,
  });

  @override
  Widget build(BuildContext context) {
    final formatMessage = AppLocalizations.of(context)!;

    const hiddenStates = [NotificationLevel.NONE, NotificationLevel.ALL];
    if (hiddenStates.contains(notifyLevel)) {
      return SizedBox.shrink();
    }

    return SettingBlock(
      headerText: THREAD_REPLIES,
      children: [
        SettingOption(
          action: onPress,
          label: formatMessage.translate(
              id: NOTIFY_OPTIONS_THREAD.THREAD_REPLIES.id,
              defaultMessage: NOTIFY_OPTIONS_THREAD.THREAD_REPLIES.defaultMessage),
          testID: NOTIFY_OPTIONS_THREAD.THREAD_REPLIES.testID,
          type: 'toggle',
          selected: isSelected,
        ),
        SettingSeparator(),
      ],
    );
  }

  static const THREAD_REPLIES = 'Thread replies';
  static const NOTIFY_OPTIONS_THREAD = {
    'THREAD_REPLIES': {
      'defaultMessage': 'Notify me about replies to threads I’m following in this channel',
      'id': 'channel_notification_preferences.notification.thread_replies',
      'testID': 'channel_notification_preferences.notification.thread_replies',
      'value': 'thread_replies',
    },
  };
}
