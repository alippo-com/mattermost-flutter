
// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:mattermost_flutter/components/server_icon.dart';
import 'package:mattermost_flutter/context/server.dart';
import 'package:mattermost_flutter/context/theme.dart';
import 'package:mattermost_flutter/database/subscription/servers.dart';
import 'package:mattermost_flutter/screens/bottom_sheet.dart';
import 'package:mattermost_flutter/utils/server.dart';
import 'package:mattermost_flutter/types/screens/servers_list.dart';
import 'package:mattermost_flutter/types/database/models/app/servers.dart';
import 'package:mattermost_flutter/types/database/subscriptions.dart';
import 'package:mattermost_flutter/utils/types.dart';

const SERVER_ITEM_HEIGHT = 75.0;
const PUSH_ALERT_TEXT_HEIGHT = 42.0;
final subscriptions = <String, UnreadSubscription>{};

class ServersRef {
  void openServers() {}
}

class Servers extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final intl = Intl.defaultLocale;
    final total = useState(UnreadMessages(mentions: 0, unread: false));
    final registeredServers = useRef<List<ServersModel>>();
    final currentServerUrl = context.select((ServerContext s) => s.serverUrl);
    final isTablet = useIsTablet();
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    final theme = Theme.of(context);

    void updateTotal() {
      var unread = false;
      var mentions = 0;
      subscriptions.forEach((key, value) {
        unread = unread || value.unread;
        mentions += value.mentions;
      });
      total.value = UnreadMessages(mentions: mentions, unread: unread);
    }

    void unreadsSubscription(String serverUrl, UnreadObserverArgs args) {
      final unreads = subscriptions[serverUrl];
      if (unreads != null) {
        var mentions = 0;
        var unread = args.threadUnreads != 0;
        for (var myChannel in args.myChannels) {
          final isMuted = args.settings?[myChannel.id]?.markUnread == 'mention';
          mentions += isMuted ? 0 : myChannel.mentionsCount;
          unread = unread || (myChannel.isUnread && !isMuted);
        }

        unreads.mentions = mentions + args.threadMentionCount;
        unreads.unread = unread;
        subscriptions[serverUrl] = unreads;
        updateTotal();
      }
    }

    void serversObserver(List<ServersModel> servers) {
      registeredServers.current = sortServersByDisplayName(servers, intl);

      final allUrls = servers.map((s) => s.url).toSet();
      final subscriptionsToRemove = subscriptions.keys.where((key) => !allUrls.contains(key)).toList();
      for (var key in subscriptionsToRemove) {
        subscriptions[key]?.subscription?.cancel();
        subscriptions.remove(key);
        updateTotal();
      }

      for (var server in servers) {
        final lastActiveAt = server.lastActiveAt;
        final url = server.url;
        if (url != currentServerUrl && !subscriptions.containsKey(url)) {
          final unreads = UnreadSubscription(mentions: 0, unread: false);
          subscriptions[url] = unreads;
          unreads.subscription = subscribeUnreadAndMentionsByServer(url, unreadsSubscription);
        } else if ((url == currentServerUrl) && subscriptions.containsKey(url)) {
          subscriptions[url]?.subscription?.cancel();
          subscriptions.remove(url);
          updateTotal();
        }
      }
    }

    void onPress() {
      if (registeredServers.current?.isNotEmpty ?? false) {
        void renderContent() {
          return ServerList(servers: registeredServers.current!);
        }

        final maxScreenHeight = (0.6 * MediaQuery.of(context).size.height).ceil();
        final maxSnapPoint = min(
          maxScreenHeight,
          bottomSheetSnapPoint(
            registeredServers.current!.length,
            SERVER_ITEM_HEIGHT,
            bottom,
          ) +
              TITLE_HEIGHT +
              BUTTON_HEIGHT +
              (registeredServers.current!
                      .where((s) => s.lastActiveAt != null)
                      .length *
                  PUSH_ALERT_TEXT_HEIGHT),
        );

        final snapPoints = [
          1,
          maxSnapPoint,
        ];
        if (maxSnapPoint == maxScreenHeight) {
          snapPoints.add('80%');
        }

        bottomSheet(
          context: context,
          closeButtonId: 'close-your-servers',
          renderContent: renderContent,
          footerComponent: AddServerButton(),
          snapPoints: snapPoints,
          theme: theme,
          title: intl.formatMessage(id: 'your.servers', defaultMessage: 'Your servers'),
        );
      }
    }

    useEffect(() {
      final subscription = subscribeAllServers(serversObserver);

      return () {
        subscription?.cancel();
        subscriptions.values.forEach((unreads) => unreads.subscription?.cancel());
        subscriptions.clear();
      };
    }, []);

    return ServerIcon(
      hasUnreads: total.value.unread,
      mentionCount: total.value.mentions,
      onPress: onPress,
      style: styles.icon,
      testID: 'channel_list.servers.server_icon',
      badgeBorderColor: theme.sidebarBg,
      badgeBackgroundColor: theme.mentionBg,
      badgeColor: theme.mentionColor,
    );
  }
}

const styles = {
  'icon': {
    'alignItems': 'center',
    'justifyContent': 'center',
    'position': 'absolute',
    'zIndex': 10,
    'top': 10,
    'left': 16,
    'width': 40.0,
    'height': 40.0,
  },
};
