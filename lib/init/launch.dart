// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import 'database_manager.dart';
import 'utils.dart'; // Utility functions like getLaunchPropsFromDeepLink, convertToNotificationData
import 'notifications_manager.dart';
import 'network_manager.dart';
import 'ephemeral_store.dart';
import 'navigation.dart'; // Functions for navigation like resetToHome, resetToSelectServer, resetToTeams, resetToOnboarding

const List<String> initialNotificationTypes = ['message', 'session'];

Future<void> initialLaunch() async {
  final deepLinkUrl = await getInitialDeepLinkUrl();
  if (deepLinkUrl != null) {
    return launchAppFromDeepLink(deepLinkUrl, true);
  }

  final notification = await NotificationsManager.getInitialNotification();
  bool tapped = Platform.isAndroid;
  if (Platform.isIOS && notification != null) {
    final delivered = await NotificationsManager.getDeliveredNotifications();
    tapped = !delivered.any((d) => d.ackId == notification.ackId);
  }

  if (initialNotificationTypes.contains(notification?.type) && tapped) {
    final notificationData = convertToNotificationData(notification!);
    EphemeralStore.setProcessingNotification(notificationData.identifier);
    return launchAppFromNotification(notificationData, true);
  }

  final coldStart = notification == null || (tapped || AppState.currentState == AppLifecycleState.resumed);
  return launchApp(LaunchProps(launchType: LaunchType.normal, coldStart: coldStart));
}

Future<String?> getInitialDeepLinkUrl() async {
  try {
    final deepLinkUrl = await getInitialUri();
    return deepLinkUrl?.toString();
  } on PlatformException {
    return null;
  }
}

Future<void> launchAppFromDeepLink(String deepLinkUrl, bool coldStart) async {
  final props = getLaunchPropsFromDeepLink(deepLinkUrl, coldStart);
  return launchApp(props);
}

Future<void> launchAppFromNotification(NotificationData notification, bool coldStart) async {
  final props = await getLaunchPropsFromNotification(notification, coldStart);
  return launchApp(props);
}

Future<void> launchApp(LaunchProps props) async {
  String? serverUrl;
  switch (props.launchType) {
    case LaunchType.deepLink:
      if (props.extra?.type != DeepLinkType.invalid) {
        final extra = props.extra as DeepLinkWithData;
        serverUrl = DatabaseManager.searchUrl(extra.data.serverUrl);
        props.serverUrl = serverUrl ?? extra.data.serverUrl;
      }
      break;
    case LaunchType.notification:
      serverUrl = props.serverUrl;
      if (props.extra is NotificationWithData) {
        final extra = props.extra as NotificationWithData;
        if (props.serverUrl != null && extra.type == 'session') {
          DeviceEventEmitter.emit('session_expired', serverUrl);
          return;
        }
      }
      break;
    default:
      serverUrl = await getActiveServerUrl();
      break;
  }

  if (props.launchError && serverUrl == null) {
    serverUrl = await getActiveServerUrl();
  }

  if (serverUrl != null) {
    final credentials = await getServerCredentials(serverUrl);
    if (credentials != null) {
      final database = DatabaseManager.getServerDatabase(serverUrl);
      bool hasCurrentUser = false;
      if (database != null) {
        EphemeralStore.theme = await getThemeForCurrentTeam(database);
        final currentUserId = await getCurrentUserId(database);
        hasCurrentUser = currentUserId != null;
      }

      var launchType = props.launchType;
      if (!hasCurrentUser) {
        if (launchType == LaunchType.normal) {
          launchType = LaunchType.upgrade;
        }

        final result = await upgradeEntry(serverUrl);
        if (result.error != null) {
          await showUpgradeError(result.error, serverUrl);
          return;
        }
      }

      return launchToHome(props..launchType = launchType, serverUrl);
    }
  }

  final onboardingViewed = await getOnboardingViewed();
  if (LocalConfig.showOnboarding && !onboardingViewed) {
    return resetToOnboarding(props);
  }

  return resetToSelectServer(props);
}

Future<void> showUpgradeError(String error, String serverUrl) async {
  await showDialog<void>(
    context: navigatorKey.currentState!.overlay!.context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Error Upgrading'),
        content: Text('An error occurred while upgrading the app to the new version.\n\nDetails: $error\n\nThe app will now quit.'),
        actions: <Widget>[
          TextButton(
            child: Text('OK'),
            onPressed: () async {
              await DatabaseManager.destroyServerDatabase(serverUrl);
              await removeServerCredentials(serverUrl);
              SystemChannels.platform.invokeMethod('SystemNavigator.pop');
            },
          ),
        ],
      );
    },
  );
}

Future<void> launchToHome(LaunchProps props, String serverUrl) async {
  switch (props.launchType) {
    case LaunchType.deepLink:
      appEntry(serverUrl);
      break;
    case LaunchType.notification:
      final extra = props.extra as NotificationWithData;
      if (serverUrl.isNotEmpty && !props.launchError && extra.userInteraction && extra.channelId != null) {
        await resetToHome(props);
        return pushNotificationEntry(serverUrl, extra.payload);
      }
      appEntry(serverUrl);
      break;
    case LaunchType.normal:
      if (props.coldStart) {
        final lastViewedChannel = await getLastViewedChannelIdAndServer();
        final lastViewedThread = await getLastViewedThreadIdAndServer();
        if (lastViewedThread?.serverUrl == serverUrl && lastViewedThread.threadId != null) {
          fetchAndSwitchToThread(serverUrl, lastViewedThread.threadId);
        } else if (lastViewedChannel?.serverUrl == serverUrl && lastViewedChannel.channelId != null) {
          switchToChannelById(serverUrl, lastViewedChannel.channelId);
        }
        appEntry(serverUrl);
      }
      break;
  }

  final database = DatabaseManager.getServerDatabase(serverUrl);
  final nTeams = database != null ? await queryMyTeams(database).fetchCount() : 0;

  if (nTeams > 0) {
    return resetToHome(props);
  }

  return resetToTeams();
}

Future<LaunchProps> getLaunchPropsFromNotification(NotificationData notification, bool coldStart) async {
  final launchProps = LaunchProps(
    launchType: LaunchType.notification,
    coldStart: coldStart,
    extra: notification,
  );

  String? serverUrl;
  try {
    if (notification.serverUrl != null) {
      DatabaseManager.getServerDatabase(notification.serverUrl);
      serverUrl = notification.serverUrl;
    } else if (notification.serverId != null) {
      serverUrl = await DatabaseManager.getServerUrlFromIdentifier(notification.serverId);
    }
  } catch (_) {
    launchProps.launchError = true;
  }

  if (serverUrl != null) {
    launchProps.serverUrl = serverUrl;
  } else {
    launchProps.launchError = true;
  }

  return launchProps;
}
