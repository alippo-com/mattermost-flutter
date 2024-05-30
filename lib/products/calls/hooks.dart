
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:mattermost_flutter/actions/calls.dart';
import 'package:mattermost_flutter/constants.dart';
import 'package:mattermost_flutter/database/manager.dart';
import 'package:mattermost_flutter/queries/servers/user.dart';
import 'package:mattermost_flutter/utils/errors.dart';
import 'package:mattermost_flutter/state/calls_state.dart';

class TryCallsFunction {
  final Function() fn;
  final BuildContext context;

  TryCallsFunction(this.fn, this.context);

  Future<void> tryCallsFunction() async {
    final serverUrl = useServerUrl();
    final intl = AppLocalizations.of(context);
    String msgPostfix = '';
    String clientError = '';

    NetworkManager client;
    try {
      client = NetworkManager.getClient(serverUrl);
    } catch (error) {
      clientError = getFullErrorMessage(error);
    }

    try {
      final enabled = await client.getEnabled();
      if (enabled) {
        msgPostfix = '';
        fn();
        return;
      }
    } catch (error) {
      errorAlert(getFullErrorMessage(error), context);
      return;
    }

    if (clientError.isNotEmpty) {
      errorAlert(clientError, context);
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(intl.callsNotAvailableTitle),
          content: Text(intl.callsNotAvailableMsg),
          actions: <Widget>[
            TextButton(
              child: Text(intl.ok),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
    msgPostfix += ' ${intl.notAvailable}';
  }
}

const micPermission = Platform.isIOS ? Permission.microphone : Permission.microphone;

class PermissionsChecker {
  final bool micPermissionsGranted;
  PermissionsChecker(this.micPermissionsGranted);

  void checkPermissions() {
    final appState = useAppState();

    if (appState == AppLifecycleState.resumed) {
      _asyncFn();
    }
  }

  Future<void> _asyncFn() async {
    if (appState == AppLifecycleState.resumed) {
      final hasPermission = await micPermission.isGranted;
      if (hasPermission) {
        initializeVoiceTrack();
        setMicPermissionsGranted(hasPermission);
      }
    }
  }
}

double useCallsAdjustment(String serverUrl, String channelId) {
  final incomingCalls = useIncomingCalls().incomingCalls;
  final channelsWithCalls = useChannelsWithCalls(serverUrl);
  final callsState = useCallsState(serverUrl);
  final globalCallsState = useGlobalCallsState();
  final currentCall = useCurrentCall();
  int numServers = 1;
  final dismissed = callsState.calls[channelId]?.dismissed[callsState.myUserId] ?? false;
  final inCurrentCall = currentCall?.id == channelId;
  final joinCallBannerVisible = channelsWithCalls[channelId] != null && !dismissed && !inCurrentCall;

  useEffect(() {
    _getNumServers();
  }, []);

  Future<void> _getNumServers() async {
    final query = await queryAllActiveServers().fetch();
    numServers = query?.length ?? 0;
  }

  final currentCallBarVisible = currentCall != null;
  final micPermissionsError = !globalCallsState.micPermissionsGranted && (currentCall != null && !currentCall.micPermissionsErrorDismissed);
  final callQualityAlert = currentCall?.callQualityAlert ?? false;
  final incomingCallsShowing = incomingCalls.where((ic) => ic.channelID != channelId).toList();
  final notificationBarHeight = CALL_NOTIFICATION_BAR_HEIGHT + (numServers > 1 ? 8 : 0);
  final callsIncomingAdjustment = (incomingCallsShowing.length * notificationBarHeight) + (incomingCallsShowing.length * 8);
  return (currentCallBarVisible ? CURRENT_CALL_BAR_HEIGHT + 8 : 0) +
      (micPermissionsError ? CALL_ERROR_BAR_HEIGHT + 8 : 0) +
      (callQualityAlert ? CALL_ERROR_BAR_HEIGHT + 8 : 0) +
      (joinCallBannerVisible ? JOIN_CALL_BAR_HEIGHT + 8 : 0) +
      callsIncomingAdjustment;
}

class HostControlsAvailable {
  bool isAdmin = false;
  String? serverUrl;
  Call? currentCall;
  CallsConfig? config;
  bool allowed = false;

  HostControlsAvailable() {
    _getUser();
  }

  Future<void> _getUser() async {
    serverUrl = currentCall?.serverUrl ?? '';
    config = getCallsConfig(serverUrl!);
    allowed = isHostControlsAllowed(config!);

    final database = DatabaseManager.serverDatabases[serverUrl!]?.database;
    if (database == null) return;

    final user = await getCurrentUser(database);
    isAdmin = isSystemAdmin(user?.roles ?? '');
  }

  bool isHost() {
    return currentCall?.hostId == currentCall?.myUserId;
  }

  bool get hostControlsAvailable {
    return allowed && (isHost() || isAdmin);
  }
}

class HostMenus {
  final BuildContext context;
  HostMenus(this.context);

  void openHostControl(CallSession session) {
    final intl = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final currentCall = useCurrentCall();
    final hostControlsAvailable = useHostControlsAvailable();
    final isHost = currentCall?.hostId == currentCall?.myUserId;

    if (hostControlsAvailable && !(session.userId == currentCall?.myUserId && isHost)) {
      openAsBottomSheet(
        context: context,
        screen: Screens.CALL_HOST_CONTROLS,
        title: intl.hostControls,
        theme: theme,
        closeButtonId: 'close-host-controls',
        props: {'closeButtonId': 'close-host-controls', 'session': session},
      );
    } else {
      openUserProfile(session);
    }
  }

  void openUserProfile(CallSession session) {
    final intl = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final currentCall = useCurrentCall();

    openAsBottomSheet(
      context: context,
      screen: Screens.USER_PROFILE,
      title: intl.profile,
      theme: theme,
      closeButtonId: 'close-user-profile',
      props: {'closeButtonId': 'close-user-profile', 'location': '', 'userId': session.userId},
    );
  }

  void onPress(CallSession session) {
    final currentCall = useCurrentCall();
    final hostControlsAvailable = useHostControlsAvailable();
    final isHost = currentCall?.hostId == currentCall?.myUserId;

    if (hostControlsAvailable && !(session.userId == currentCall?.myUserId && isHost)) {
      openHostControl(session);
    } else {
      openUserProfile(session);
    }
  }
}
