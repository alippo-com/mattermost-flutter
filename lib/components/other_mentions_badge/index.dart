import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mattermost_flutter/components/badge.dart';
import 'package:mattermost_flutter/constants/screens.dart';
import 'package:mattermost_flutter/context/server.dart';
import 'package:mattermost_flutter/database/subscription/servers.dart';
import 'package:mattermost_flutter/database/subscription/unreads.dart';
import 'package:mattermost_flutter/types/database/models/app/servers.dart';
import 'package:mattermost_flutter/types/database/models/servers/my_channel.dart';
import 'package:mattermost_flutter/types/database/subscriptions.dart';

class OtherMentionsBadge extends StatefulWidget {
  final String channelId;

  OtherMentionsBadge({required this.channelId});

  @override
  _OtherMentionsBadgeState createState() => _OtherMentionsBadgeState();
}

class _OtherMentionsBadgeState extends State<OtherMentionsBadge> {
  final Map<String, UnreadSubscription> subscriptions = {};
  int count = 0;

  @override
  void initState() {
    super.initState();
    final currentServerUrl = context.read<ServerUrlProvider>().serverUrl;
    _subscribeAllServers(currentServerUrl);
  }

  void _updateCount() {
    int mentions = 0;
    subscriptions.forEach((_, value) {
      mentions += value.mentions;
    });
    setState(() {
      count = mentions;
    });
  }

  void _unreadsSubscription(String serverUrl, MyChannelModel myChannels, int threadMentionCount) {
    final unreads = subscriptions[serverUrl];
    if (unreads != null) {
      int mentions = 0;
      for (var myChannel in myChannels) {
        if (widget.channelId != myChannel.id) {
          mentions += myChannel.mentionsCount;
        }
      }
      unreads.mentions = mentions;
      if (serverUrl != context.read<ServerUrlProvider>().serverUrl || widget.channelId != Screens.GLOBAL_THREADS) {
        unreads.mentions += threadMentionCount;
      }
      subscriptions[serverUrl] = unreads;
      _updateCount();
    }
  }

  void _serversObserver(List<ServersModel> servers) {
    final allUrls = servers.map((s) => s.url).toSet();
    final subscriptionsToRemove = subscriptions.keys.where((key) => !allUrls.contains(key)).toList();
    for (var key in subscriptionsToRemove) {
      subscriptions[key]?.subscription?.unsubscribe();
      subscriptions.remove(key);
    }

    for (var server in servers) {
      final serverUrl = server.url;
      if (server.lastActiveAt != null && !subscriptions.containsKey(serverUrl)) {
        final unreads = UnreadSubscription(mentions: 0, unread: false);
        subscriptions[serverUrl] = unreads;
        unreads.subscription = subscribeMentionsByServer(serverUrl, (myChannels, threadMentionCount) => _unreadsSubscription(serverUrl, myChannels, threadMentionCount));
      } else if (subscriptions.containsKey(serverUrl)) {
        subscriptions[serverUrl]?.subscription?.unsubscribe();
        subscriptions.remove(serverUrl);
      }
    }
  }

  void _subscribeAllServers(String currentServerUrl) {
    final subscription = subscribeAllServers(_serversObserver);
    setState(() {
      subscriptions.clear();
      subscriptions[currentServerUrl] = subscription;
    });
    subscription.unsubscribe = () {
      subscription.unsubscribe();
      subscriptions.forEach((key, value) {
        value.subscription?.unsubscribe();
      });
      subscriptions.clear();
    };
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        minWidth: 24,
      ),
      child: Badge(
        type: BadgeType.Small,
        visible: count > 0,
        value: count,
        style: BadgeStyle(
          position: BadgePosition(left: 2, top: 0),
          borderColor: Colors.transparent,
        ),
      ),
    );
  }
}
