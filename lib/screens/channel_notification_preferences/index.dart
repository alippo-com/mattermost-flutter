
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';

import 'package:mattermost_flutter/constants/notification_level.dart';
import 'package:mattermost_flutter/queries/servers/channel.dart';
import 'package:mattermost_flutter/queries/servers/features.dart';
import 'package:mattermost_flutter/queries/servers/thread.dart';
import 'package:mattermost_flutter/queries/servers/user.dart';
import 'package:mattermost_flutter/utils/channel.dart';
import 'package:mattermost_flutter/utils/user.dart';
import 'package:mattermost_flutter/types/database.dart';

import './channel_notification_preferences.dart';

class EnhancedProps {
  final String channelId;
  final Database database;

  EnhancedProps({required this.channelId, required this.database});
}

Stream<EnhancedProps> enhanced(EnhancedProps props) {
  final settings = observeChannelSettings(props.database, props.channelId);
  final isCRTEnabled = observeIsCRTEnabled(props.database);
  final isMuted = observeIsMutedSetting(props.database, props.channelId);
  final notifyProps = observeCurrentUser(props.database).switchMap((u) => Stream.fromFuture(getNotificationProps(u)));
  final channelType = observeChannel(props.database, props.channelId).switchMap((c) => Stream.value(c?.type));
  final hasGMasDMFeature = observeHasGMasDMFeature(props.database);

  final notifyLevel = settings.switchMap((s) => Stream.value(s?.notifyProps.push ?? NotificationLevel.DEFAULT));

  final notifyThreadReplies = settings.switchMap((s) => Stream.value(s?.notifyProps.push_threads));

  final defaultLevel = notifyProps
      .switchMap((n) => Stream.value(n?.push))
      .combineLatestWith([hasGMasDMFeature, channelType], (v, hasFeature, cType) {
    final shouldShowwithGMasDMBehavior = hasFeature && isTypeDMorGM(cType);

    var defaultLevelToUse = v;
    if (shouldShowwithGMasDMBehavior) {
      if (v == NotificationLevel.MENTION) {
        defaultLevelToUse = NotificationLevel.ALL;
      }
    }

    return defaultLevelToUse;
  });

  final defaultThreadReplies = notifyProps.switchMap((n) => Stream.value(n?.push_threads));

  return Stream.value(EnhancedProps(
    channelId: props.channelId,
    database: props.database,
  ));
}

class ChannelNotificationPreferences extends StatelessWidget {
  final String channelId;
  final Database database;

  ChannelNotificationPreferences({required this.channelId, required this.database});

  @override
  Widget build(BuildContext context) {
    return StreamProvider<EnhancedProps>(
      create: (context) => enhanced(EnhancedProps(channelId: channelId, database: database)),
      initialData: EnhancedProps(channelId: channelId, database: database),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Channel Notification Preferences'),
        ),
        body: Consumer<EnhancedProps>(
          builder: (context, props, child) {
            // Add your channel notification preferences UI here
            return Container();
          },
        ),
      ),
    );
  }
}
