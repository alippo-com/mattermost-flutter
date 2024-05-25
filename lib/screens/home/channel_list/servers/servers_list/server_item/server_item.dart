// Converted from server_item.tsx

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:mattermost_flutter/components/compass_icon.dart';
import 'package:mattermost_flutter/components/loading.dart';
import 'package:mattermost_flutter/components/server_icon.dart';
import 'package:mattermost_flutter/components/tutorial_highlight.dart';
import 'package:mattermost_flutter/components/tutorial_highlight/swipe_left.dart';
import 'package:mattermost_flutter/constants.dart';
import 'package:mattermost_flutter/database/manager.dart';
import 'package:mattermost_flutter/database/subscription/unreads.dart';
import 'package:mattermost_flutter/hooks/device.dart';
import 'package:mattermost_flutter/managers/websocket_manager.dart';
import 'package:mattermost_flutter/navigation.dart';
import 'package:mattermost_flutter/screens/navigation.dart';
import 'package:mattermost_flutter/utils/push_proxy.dart';
import 'package:mattermost_flutter/utils/server.dart';
import 'package:mattermost_flutter/utils/theme.dart';
import 'package:mattermost_flutter/utils/typography.dart';
import 'package:mattermost_flutter/utils/url.dart';
import 'package:mattermost_flutter/typings/database/models/app/servers.dart';
import 'package:mattermost_flutter/screens/home/channel_list/servers/servers_list/server_item/options.dart';
import 'package:mattermost_flutter/screens/home/channel_list/servers/servers_list/server_item/websocket.dart';
import 'package:provider/provider.dart';

class ServerItem extends StatefulWidget {
  final bool highlight;
  final bool isActive;
  final ServersModel server;
  final bool tutorialWatched;
  final String pushProxyStatus;

  ServerItem({
    required this.highlight,
    required this.isActive,
    required this.server,
    required this.tutorialWatched,
    required this.pushProxyStatus,
  });

  @override
  _ServerItemState createState() => _ServerItemState();
}

class _ServerItemState extends State<ServerItem> {
  late bool switching;
  late BadgeValues badge;
  late bool showTutorial;
  late bool tutorialShown;

  @override
  void initState() {
    super.initState();
    switching = false;
    badge = BadgeValues(isUnread: false, mentions: 0);
    showTutorial = false;
    tutorialShown = false;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!widget.isActive) {
      if (widget.server.lastActiveAt > 0) {
        subscribeServerUnreadAndMentions(widget.server.url, unreadsSubscription);
      } else {
        setState(() {
          badge = BadgeValues(isUnread: false, mentions: 0);
        });
      }
    }
  }

  void unreadsSubscription(UnreadObserverArgs args) {
    int mentions = 0;
    bool isUnread = args.threadUnreads != null && args.threadUnreads!;
    for (var myChannel in args.myChannels) {
      bool isMuted = args.settings?[myChannel.id]?.mark_unread == 'mention';
      mentions += isMuted ? 0 : myChannel.mentionsCount!;
      isUnread = isUnread || (myChannel.isUnread && !isMuted);
    }
    mentions += args.threadMentionCount!;
    setState(() {
      badge = BadgeValues(isUnread: isUnread, mentions: mentions);
    });
  }

  void startTutorial() {
    // Implement tutorial start functionality
  }

  Future<void> logoutServer() async {
    await logout(widget.server.url);
    if (widget.isActive) {
      dismissBottomSheet();
    } else {
      // Handle swipeable close
    }
  }

  Future<void> removeServer() async {
    await dismissBottomSheet();
    await logout(widget.server.url, skipLogoutFromServer: widget.server.lastActiveAt == 0, true);
  }

  Future<void> handleLogin() async {
    setState(() {
      switching = true;
    });
    var result = await doPing(widget.server.url, true);
    if (result.error != null) {
      alertServerError(context, result.error);
      setState(() {
        switching = false;
      });
      return;
    }

    var data = await fetchConfigAndLicense(widget.server.url, true);
    if (data.error != null) {
      alertServerError(context, data.error);
      setState(() {
        switching = false;
      });
      return;
    }

    var existingServer = await getServerByIdentifier(data.config!.DiagnosticId);
    if (existingServer != null && existingServer.lastActiveAt > 0) {
      alertServerAlreadyConnected(context);
      setState(() {
        switching = false;
      });
      return;
    }

    canReceiveNotifications(widget.server.url, result.canReceiveNotifications as String, context);
    loginToServer(widget.server.url, widget.server.displayName, data.config!, data.license!);
  }

  @override
  Widget build(BuildContext context) {
    String displayName = widget.server.displayName;

    if (widget.server.url == widget.server.displayName) {
      displayName = 'Default Server';
    }

    var containerStyle = [
      styles.container,
      if (widget.isActive) styles.active,
    ];

    var serverStyle = [
      styles.row,
      if (widget.server.lastActiveAt == 0) styles.offline,
    ];

    return Slidable(
      actionPane: SlidableDrawerActionPane(),
      actionExtentRatio: 0.25,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: changeOpacity(Provider.of<Theme>(context).centerChannelColor, 0.04),
        ),
        margin: EdgeInsets.only(bottom: 12),
        child: ListTile(
          onTap: handleLogin,
          contentPadding: EdgeInsets.symmetric(horizontal: 18),
          leading: !switching
              ? ServerIcon(
                  badgeBackgroundColor: Provider.of<Theme>(context).mentionColor,
                  badgeBorderColor: Provider.of<Theme>(context).mentionBg,
                  badgeColor: Provider.of<Theme>(context).mentionBg,
                  badgeStyle: styles.badge,
                  iconColor: changeOpacity(Provider.of<Theme>(context).centerChannelColor, 0.56),
                  hasUnreads: badge.isUnread,
                  mentionCount: badge.mentions,
                  size: 36,
                  unreadStyle: styles.unread,
                  style: styles.serverIcon,
                )
              : Loading(
                  containerStyle: styles.switching,
                  color: Provider.of<Theme>(context).buttonBg,
                  size: 'small',
                ),
          title: Text(
            displayName,
            style: styles.name,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            removeProtocol(stripTrailingSlashes(widget.server.url)),
            style: styles.url,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: widget.server.lastActiveAt == 0 && !switching
              ? Icon(Icons.warning, color: changeOpacity(Provider.of<Theme>(context).centerChannelColor, 0.64))
              : null,
        ),
      ),
      secondaryActions: [
        IconSlideAction(
          caption: 'Edit',
          color: Colors.blue,
          icon: Icons.edit,
          onTap: () {
            // Handle edit action
          },
        ),
        IconSlideAction(
          caption: 'Remove',
          color: Colors.red,
          icon: Icons.delete,
          onTap: removeServer,
        ),
      ],
    );
  }
}

class BadgeValues {
  bool isUnread;
  int mentions;

  BadgeValues({required this.isUnread, required this.mentions});
}

final styles = {
  'container': BoxDecoration(),
  'active': BoxDecoration(),
  'row': Row(),
  'offline': BoxDecoration(),
  'badge': BoxDecoration(),
  'button': BoxDecoration(),
  'details': BoxDecoration(),
  'logout': BoxDecoration(),
  'name': TextStyle(),
  'unread': BoxDecoration(),
  'serverIcon': BoxDecoration(),
  'switching': BoxDecoration(),
  'url': TextStyle(),
};