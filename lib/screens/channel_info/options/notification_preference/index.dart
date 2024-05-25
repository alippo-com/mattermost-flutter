// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:rx_notifier/rx_notifier.dart';

import 'package:mattermost_flutter/constants.dart';
import 'package:mattermost_flutter/queries/servers/channel.dart';
import 'package:mattermost_flutter/queries/servers/features.dart';
import 'package:mattermost_flutter/queries/servers/user.dart';
import 'package:mattermost_flutter/utils/user.dart';
import 'notification_preference.dart';
import 'package:mattermost_flutter/types/database/models/servers/channel.dart';

class NotificationPreferenceContainer extends HookConsumerWidget {
  final String channelId;

  NotificationPreferenceContainer({required this.channelId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final database = ref.read(databaseProvider);
    final channel = useStream(observeChannel(database, channelId));
    final channelType = useStream(channel.stream.map((c) => c?.type));
    final displayName = useStream(channel.stream.map((c) => c?.displayName));
    final settings = useStream(observeChannelSettings(database, channelId));
    final userNotifyLevel = useStream(observeCurrentUser(database).stream.map((u) => getNotificationProps(u).push));
    final notifyLevel = useStream(settings.stream.map((s) => s?.notifyProps.push ?? NotificationLevel.DEFAULT));
    final hasGMasDMFeature = useStream(observeHasGMasDMFeature(database));

    return NotificationPreference(
      displayName: displayName.data,
      notifyLevel: notifyLevel.data,
      userNotifyLevel: userNotifyLevel.data,
      channelType: channelType.data,
      hasGMasDMFeature: hasGMasDMFeature.data,
    );
  }
}
