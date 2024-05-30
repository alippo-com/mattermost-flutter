// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:mattermost_flutter/components/settings/container.dart';
import 'package:mattermost_flutter/components/settings/separator.dart';
import 'package:mattermost_flutter/context/server.dart';
import './push_send.dart';
import './push_status.dart';
import './push_thread.dart';
import 'package:mattermost_flutter/types/screens/navigation.dart';

class NotificationPush extends HookWidget {
  final AvailableScreens componentId;
  final UserModel? currentUser;
  final bool isCRTEnabled;
  final bool sendPushNotifications;

  NotificationPush({
    required this.componentId,
    this.currentUser,
    required this.isCRTEnabled,
    required this.sendPushNotifications,
  });

  @override
  Widget build(BuildContext context) {
    final serverUrl = useServerUrl();
    final notifyProps = useMemo(
      () => getNotificationProps(currentUser),
      [currentUser?.notifyProps],
    );

    final pushSend = useState<String>(notifyProps.push);
    final pushStatus = useState<String>(notifyProps.push_status);
    final pushThread = useState<String>(notifyProps?.push_threads ?? 'all');

    final onMobilePushThreadChanged = useCallback(() {
      pushThread.value = pushThread.value == 'all' ? 'mention' : 'all';
    }, [pushThread.value]);

    final close = () => popTopScreen(componentId);

    final canSaveSettings = useCallback(() {
      final p = pushSend.value != notifyProps.push;
      final pT = pushThread.value != notifyProps.push_threads;
      final pS = pushStatus.value != notifyProps.push_status;
      return p || pT || pS;
    }, [notifyProps, pushSend.value, pushStatus.value, pushThread.value]);

    final saveNotificationSettings = useCallback(() {
      final canSave = canSaveSettings();
      if (canSave) {
        final notify_props = {
          ...notifyProps,
          'push': pushSend.value,
          'push_status': pushStatus.value,
          'push_threads': pushThread.value,
        };
        updateMe(serverUrl, {'notify_props': notify_props});
      }
      close();
    }, [canSaveSettings, close, notifyProps, pushSend.value, pushStatus.value, pushThread.value, serverUrl]);

    useBackNavigation(saveNotificationSettings);

    useAndroidHardwareBackHandler(componentId, saveNotificationSettings);

    return SettingContainer(
      testID: 'push_notification_settings',
      child: Column(
        children: [
          MobileSendPush(
            pushStatus: pushSend.value,
            sendPushNotifications: sendPushNotifications,
            setMobilePushPref: pushSend.value,
          ),
          if (isCRTEnabled && pushSend.value == 'mention') ...[
            if (Theme.of(context).platform == TargetPlatform.android) SettingSeparator(isGroupSeparator: true),
            MobilePushThread(
              pushThread: pushThread.value,
              onMobilePushThreadChanged: onMobilePushThreadChanged,
            ),
          ],
          if (sendPushNotifications && pushSend.value != 'none') ...[
            if (Theme.of(context).platform == TargetPlatform.android) SettingSeparator(isGroupSeparator: true),
            MobilePushStatus(
              pushStatus: pushStatus.value,
              setMobilePushStatus: pushStatus.value,
            ),
          ],
        ],
      ),
    );
  }
}
