// Converted code for channel_list.tsx to channel_list.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mattermost_flutter/actions/remote/user.dart';
import 'package:mattermost_flutter/components/announcement_banner.dart';
import 'package:mattermost_flutter/components/connection_banner.dart';
import 'package:mattermost_flutter/components/floating_call_container.dart';
import 'package:mattermost_flutter/components/team_sidebar.dart';
import 'package:mattermost_flutter/constants.dart';
import 'package:mattermost_flutter/context/server.dart';
import 'package:mattermost_flutter/context/theme.dart';
import 'package:mattermost_flutter/screens/navigation.dart';
import 'package:mattermost_flutter/store/navigation_store.dart';
import 'package:mattermost_flutter/utils/helpers.dart';
import 'package:mattermost_flutter/utils/reviews.dart';
import 'package:mattermost_flutter/utils/sentry.dart';
import 'package:provider/provider.dart';

import 'additional_tablet_view.dart';
import 'categories_list.dart';
import 'servers.dart';
import '../types/launch.dart';

class ChannelListScreen extends StatefulWidget {
  final bool hasChannels;
  final bool isCRTEnabled;
  final bool hasTeams;
  final bool hasMoreThanOneTeam;
  final bool isLicensed;
  final bool showToS;
  final LaunchType launchType;
  final bool? coldStart;
  final String? currentUserId;
  final bool hasCurrentUser;
  final bool showIncomingCalls;

  ChannelListScreen({
    required this.hasChannels,
    required this.isCRTEnabled,
    required this.hasTeams,
    required this.hasMoreThanOneTeam,
    required this.isLicensed,
    required this.showToS,
    required this.launchType,
    this.coldStart,
    this.currentUserId,
    required this.hasCurrentUser,
    required this.showIncomingCalls,
  });

  @override
  _ChannelListScreenState createState() => _ChannelListScreenState();
}

class _ChannelListScreenState extends State<ChannelListScreen> {
  int backPressedCount = 0;
  bool hasRendered = false;
  late String serverUrl;
  late ThemeData theme;

  @override
  void initState() {
    super.initState();
    theme = Provider.of<ThemeProvider>(context, listen: false).theme;
    serverUrl = Provider.of<ServerProvider>(context, listen: false).serverUrl;
    addSentryContext(serverUrl);

    if (!widget.hasTeams) {
      resetToTeams(context);
    }

    WidgetsBinding.instance?.addPostFrameCallback((_) {
      if (widget.showToS && !NavigationStore().isToSOpen) {
        openToS(context);
      }

      if (!widget.hasCurrentUser || widget.currentUserId == null) {
        refetchCurrentUser(serverUrl, widget.currentUserId);
      }

      if (!hasRendered) {
        hasRendered = true;
        if (!NavigationStore().isToSOpen) {
          tryRunAppReview(widget.launchType, widget.coldStart);
        }
      }
    });

    SystemChannels.platform.setMethodCallHandler((call) async {
      if (call.method == 'SystemSound.play') {
        handleBackPress();
      }
    });
  }

  void handleBackPress() {
    final isHomeScreen = NavigationStore().visibleScreen == Screens.HOME;
    final homeTab = NavigationStore().visibleTab == Screens.HOME;
    final focused = ModalRoute.of(context)?.isCurrent ?? false && isHomeScreen && homeTab;

    if (isMainActivity()) {
      if (backPressedCount == 0 && focused) {
        backPressedCount++;
        Fluttertoast.showToast(
          msg: "Press back again to exit",
          toastLength: Toast.LENGTH_SHORT,
        );
        Future.delayed(Duration(seconds: 2), () {
          backPressedCount = 0;
        });
      } else if (isHomeScreen && !homeTab) {
        // Navigate to home screen
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final insets = MediaQuery.of(context).viewPadding;
    final isTablet = MediaQuery.of(context).size.shortestSide >= 600;
    final canAddOtherServers = true; // Assuming managedConfig.allowOtherServers is true

    return Scaffold(
      body: SafeArea(
        top: false,
        bottom: true,
        left: true,
        right: true,
        child: Column(
          children: [
            Container(height: insets.top, color: theme.backgroundColor),
            ConnectionBanner(),
            if (widget.isLicensed) AnnouncementBanner(),
            Expanded(
              child: Row(
                children: [
                  if (canAddOtherServers) Servers(),
                  Expanded(
                    child: Row(
                      children: [
                        TeamSidebar(
                          iconPad: canAddOtherServers,
                          hasMoreThanOneTeam: widget.hasMoreThanOneTeam,
                        ),
                        CategoriesList(
                          iconPad: canAddOtherServers && !widget.hasMoreThanOneTeam,
                          isCRTEnabled: widget.isCRTEnabled,
                          moreThanOneTeam: widget.hasMoreThanOneTeam,
                          hasChannels: widget.hasChannels,
                        ),
                        if (isTablet) AdditionalTabletView(),
                        if (widget.showIncomingCalls && !isTablet)
                          FloatingCallContainer(
                            showIncomingCalls: widget.showIncomingCalls,
                            channelsScreen: true,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
