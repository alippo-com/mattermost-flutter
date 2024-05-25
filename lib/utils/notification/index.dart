import 'package:flutter/material.dart';
import 'package:momentum/momentum.dart';
import 'package:mattermost_flutter/constants.dart';
import 'package:mattermost_flutter/i18n.dart';
import 'package:mattermost_flutter/init/push_notifications.dart';
import 'package:mattermost_flutter/screens/navigation.dart';
import 'package:mattermost_flutter/utils/helpers.dart';
import 'package:mattermost_flutter/types.dart';

class NotificationUtils {
  static NotificationWithData convertToNotificationData(Notification notification, {bool tapped = true}) {
    if (notification.payload == null) {
      return NotificationWithData.fromNotification(notification);
    }

    final payload = notification.payload;
    final notificationData = NotificationWithData(
      ackId: payload.ackId,
      channelId: payload.channelId,
      channelName: payload.channelName,
      identifier: payload.identifier ?? notification.identifier,
      fromWebhook: payload.fromWebhook,
      message: (payload.type == NOTIFICATION_TYPE.MESSAGE) ? (payload.message ?? notification.body) : payload.body,
      overrideIconUrl: payload.overrideIconUrl,
      overrideUsername: payload.overrideUsername,
      postId: payload.postId,
      rootId: payload.rootId,
      senderId: payload.senderId,
      senderName: payload.senderName,
      serverId: payload.serverId,
      serverUrl: payload.serverUrl,
      teamId: payload.teamId,
      type: payload.type,
      subType: payload.subType,
      useUserIcon: payload.useUserIcon,
      version: payload.version,
      isCRTEnabled: payload.isCRTEnabled is String ? payload.isCRTEnabled == 'true' : payload.isCRTEnabled,
      data: payload.data,
      userInteraction: tapped,
      foreground: false,
    );

    return notificationData;
  }

  static void notificationError(BuildContext context, String type) {
    final intl = createIntl(context, DEFAULT_LOCALE);
    final title = intl.formatMessage('notification.message_not_found', defaultMessage: 'Message not found');
    String message;
    switch (type) {
      case 'Channel':
        message = intl.formatMessage('notification.not_channel_member', defaultMessage: 'This message belongs to a channel where you are not a member.');
        break;
      case 'Team':
        message = intl.formatMessage('notification.not_team_member', defaultMessage: 'This message belongs to a team where you are not a member.');
        break;
      case 'Post':
        message = intl.formatMessage('notification.no_post', defaultMessage: 'The message has not been found.');
        break;
      case 'Connection':
        message = intl.formatMessage('notification.no_connection', defaultMessage: 'The server is unreachable and it was not possible to retrieve the specific message information for the notification.');
        break;
      default:
        message = '';
        break;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigation.popToRoot();
            },
            child: Text(intl.formatMessage('common.ok', defaultMessage: 'OK')),
          ),
        ],
      ),
    );
  }

  static void emitNotificationError(String type) {
    Future.delayed(Duration(milliseconds: 500), () {
      EventBus().emit(Events.NOTIFICATION_ERROR, type);
    });
  }

  static int scheduleExpiredNotification(String serverUrl, Session session, String serverName, {String locale = DEFAULT_LOCALE}) {
    final expiresAt = session?.expiresAt ?? 0;
    final expiresInHours = (DateTime.now().difference(DateTime.fromMillisecondsSinceEpoch(expiresAt)).inHours).abs();
    final expiresInDays = expiresInHours ~/ 24;
    final remainingHours = expiresInHours % 24;
    final intl = createIntl(locale, getTranslations(locale));
    String body;
    if (expiresInDays == 0) {
      body = intl.formatMessage(
        'mobile.session_expired_hrs',
        defaultMessage: 'Please log in to continue receiving notifications. Sessions for {siteName} are configured to expire every {hoursCount, number} {hoursCount, plural, one {hour} other {hours}}.',
        params: {'siteName': serverName, 'hoursCount': remainingHours},
      );
    } else if (expiresInHours == 0) {
      body = intl.formatMessage(
        'mobile.session_expired_days',
        defaultMessage: 'Please log in to continue receiving notifications. Sessions for {siteName} are configured to expire every {daysCount, number} {daysCount, plural, one {day} other {days}}.',
        params: {'siteName': serverName, 'daysCount': expiresInDays},
      );
    } else {
      body = intl.formatMessage(
        'mobile.session_expired_days_hrs',
        defaultMessage: 'Please log in to continue receiving notifications. Sessions for {siteName} are configured to expire every {daysCount, number} {daysCount, plural, one {day} other {days}} and {hoursCount, number} {hoursCount, plural, one {hour} other {hours}}.',
        params: {'siteName': serverName, 'daysCount': expiresInDays, 'hoursCount': remainingHours},
      );
    }
    final title = intl.formatMessage('mobile.session_expired.title', defaultMessage: 'Session Expired');

    if (expiresAt != 0) {
      return PushNotifications.scheduleNotification(
        fireDate: expiresAt,
        body: body,
        title: title,
        ackId: serverUrl,
        serverUrl: serverUrl,
        type: 'session',
      );
    }

    return 0;
  }
}
