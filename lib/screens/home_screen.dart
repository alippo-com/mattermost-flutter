// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:mattermost_flutter/components/server_version.dart';
import 'package:mattermost_flutter/constants.dart';
import 'package:mattermost_flutter/context/theme.dart';
import 'package:mattermost_flutter/utils/deep_link.dart';
import 'package:mattermost_flutter/utils/log.dart';
import 'package:mattermost_flutter/utils/navigation.dart';
import 'package:mattermost_flutter/utils/notification.dart';

import 'account.dart';
import 'channel_list.dart';
import 'recent_mentions.dart';
import 'saved_messages.dart';
import 'search.dart';
import 'tab_bar.dart';

import 'types/launch.dart';

class HomeScreen extends StatefulWidget {
  final LaunchProps launchProps;
  final String componentId;

  HomeScreen({required this.launchProps, required this.componentId});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Theme theme;
  late AppState appState;

  @override
  void initState() {
    super.initState();
    theme = useTheme();
    appState = useAppState();

    SystemChannels.lifecycle.setMessageHandler((msg) async {
      if (msg == 'AppLifecycleState.resumed') {
        await updateTimezoneIfNeeded();
      }
      return;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setupListeners();
    });
  }

  Future<void> updateTimezoneIfNeeded() async {
    try {
      final servers = await getAllServers();
      for (var server in servers) {
        if (server.url.isNotEmpty && server.lastActiveAt > 0) {
          autoUpdateTimezone(server.url);
        }
      }
    } catch (e) {
      logError('Localize change', e);
    }
  }

  void _setupListeners() {
    EventChannel('events/notification_error').receiveBroadcastStream().listen((value) {
      notificationError(value as String);
    });

    EventChannel('events/leave_team').receiveBroadcastStream().listen((displayName) {
      alertTeamRemove(displayName as String, theme);
    });

    EventChannel('events/leave_channel').receiveBroadcastStream().listen((displayName) {
      alertChannelRemove(displayName as String, theme);
    });

    EventChannel('events/channel_archived').receiveBroadcastStream().listen((displayName) {
      alertChannelArchived(displayName as String, theme);
    });

    EventChannel('events/crt_toggled').receiveBroadcastStream().listen((isSameServer) {
      if (isSameServer as bool) {
        popToRoot();
      }
    });

    EventChannel('events/hw_key_pressed').receiveBroadcastStream().listen((keyEvent) {
      final pressedKey = keyEvent as Map<dynamic, dynamic>;
      if (!NavigationStore.getScreensInStack().contains(Screens.FIND_CHANNELS) && pressedKey['pressedKey'] == 'find-channels') {
        findChannels('Find Channels', theme);
      }
    });

    if (widget.launchProps.launchType == 'deeplink') {
      if (widget.launchProps.launchError) {
        alertInvalidDeepLink();
      } else {
        final deepLink = widget.launchProps.extra as DeepLinkWithData;
        if (deepLink.url.isNotEmpty) {
          handleDeepLink(deepLink.url).then((result) {
            if (result.error) {
              alertInvalidDeepLink();
            }
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Navigator(
        onGenerateRoute: (settings) {
          WidgetBuilder builder;
          switch (settings.name) {
            case Screens.HOME:
              builder = (BuildContext _) => ChannelList();
              break;
            case Screens.SEARCH:
              builder = (BuildContext _) => Search();
              break;
            case Screens.MENTIONS:
              builder = (BuildContext _) => RecentMentions();
              break;
            case Screens.SAVED_MESSAGES:
              builder = (BuildContext _) => SavedMessages();
              break;
            case Screens.ACCOUNT:
              builder = (BuildContext _) => Account();
              break;
            default:
              throw Exception('Invalid route: ${settings.name}');
          }
          return MaterialPageRoute(builder: builder, settings: settings);
        },
      ),
      bottomNavigationBar: TabBar(theme: theme),
    );
  }
}
