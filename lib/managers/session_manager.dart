import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fast_image/fast_image.dart';
import 'package:sqflite/sqflite.dart';

import '../actions/local/user.dart';
import '../actions/remote/session.dart';
import '../constants.dart';
import '../database/manager.dart';
import '../init/credentials.dart';
import '../init/push_notifications.dart';
import '../managers/network_manager.dart';
import '../managers/websocket_manager.dart';
import '../queries/servers/user.dart';
import '../store/ephemeral_store.dart';
import '../utils/file.dart';
import '../utils/security.dart';
import '../utils/server.dart';
import '../i18n.dart';

typedef LogoutCallbackArg = Map<String, dynamic>;

class SessionManager {
  AppLifecycleState? previousAppState;
  bool scheduling = false;
  final Set<String> terminatingSessionUrl = {};

  SessionManager() {
    if (Platform.isAndroid) {
      SystemChannels.lifecycle.setMessageHandler((message) async {
        if (message == 'AppLifecycleState.inactive') {
          onAppStateChange(AppLifecycleState.inactive);
        } else if (message == 'AppLifecycleState.resumed') {
          onAppStateChange(AppLifecycleState.resumed);
        }
        return;
      });
    } else {
      WidgetsBinding.instance.addObserver(
        LifecycleEventHandler(
          detachedCallBack: () async => onAppStateChange(AppLifecycleState.detached),
          resumedCallBack: () async => onAppStateChange(AppLifecycleState.resumed),
        ),
      );
    }

    // Registering event listeners
    EventBus.on(Events.SERVER_LOGOUT, onLogout);
    EventBus.on(Events.SESSION_EXPIRED, onSessionExpired);

    previousAppState = WidgetsBinding.instance.lifecycleState;
  }

  void init() {
    cancelAllSessionNotifications();
  }

  Future<void> cancelAllSessionNotifications() async {
    final serverCredentials = await getAllServerCredentials();
    for (var credential in serverCredentials) {
      cancelSessionNotification(credential.serverUrl);
    }
  }

  Future<void> clearCookies(String serverUrl, bool webKit) async {
    try {
      final cookies = await CookieManager.get(serverUrl, webKit);
      for (var cookie in cookies.values) {
        CookieManager.clearByName(serverUrl, cookie.name, webKit);
      }
    } catch (error) {
      // Nothing to clear
    }
  }

  Future<void> clearCookiesForServer(String serverUrl) async {
    if (Platform.isIOS) {
      await clearCookies(serverUrl, false);
      await clearCookies(serverUrl, true);
    } else if (Platform.isAndroid) {
      await CookieManager.flush();
    }
  }

  Future<void> scheduleAllSessionNotifications() async {
    if (!scheduling) {
      scheduling = true;
      final serverCredentials = await getAllServerCredentials();
      final promises = serverCredentials.map((credential) => scheduleSessionNotification(credential.serverUrl));
      await Future.wait(promises);
      scheduling = false;
    }
  }

  Future<void> resetLocale() async {
    if (DatabaseManager.serverDatabases.isNotEmpty) {
      final serverDatabase = await DatabaseManager.getActiveServerDatabase();
      final user = await getCurrentUser(serverDatabase!);
      resetMomentLocale(user?.locale);
    } else {
      resetMomentLocale();
    }
  }

  Future<void> terminateSession(String serverUrl, bool removeServer) async {
    cancelSessionNotification(serverUrl);
    await removeServerCredentials(serverUrl);
    PushNotifications.removeServerNotifications(serverUrl);

    NetworkManager.invalidateClient(serverUrl);
    WebsocketManager.invalidateClient(serverUrl);

    if (removeServer) {
      await removePushDisabledInServerAcknowledged(urlSafeBase64Encode(serverUrl));
      await DatabaseManager.destroyServerDatabase(serverUrl);
    } else {
      await DatabaseManager.deleteServerDatabase(serverUrl);
    }

    final analyticsClient = analytics.get(serverUrl);
    if (analyticsClient != null) {
      analyticsClient.reset();
      analytics.invalidate(serverUrl);
    }

    await resetLocale();
    await clearCookiesForServer(serverUrl);
    await FastImage.clearDiskCache();
    await deleteFileCache(serverUrl);
    await deleteFileCacheByDir('mmPasteInput');
    await deleteFileCacheByDir('thumbnails');
    if (Platform.isAndroid) {
      await deleteFileCacheByDir('image_cache');
    }
  }

  Future<void> onAppStateChange(AppLifecycleState state) async {
    if (state == previousAppState || !isMainActivity()) {
      return;
    }

    previousAppState = state;
    if (state == AppLifecycleState.resumed) {
      await Future.delayed(Duration(milliseconds: 750), cancelAllSessionNotifications);
    } else if (state == AppLifecycleState.inactive) {
      await scheduleAllSessionNotifications();
    }
  }

  Future<void> onLogout(LogoutCallbackArg args) async {
    final serverUrl = args['serverUrl'] as String;
    final removeServer = args['removeServer'] as bool;

    if (terminatingSessionUrl.contains(serverUrl)) {
      return;
    }

    terminatingSessionUrl.add(serverUrl);

    final activeServerUrl = await DatabaseManager.getActiveServerUrl();
    final activeServerDisplayName = await DatabaseManager.getActiveServerDisplayName();

    await terminateSession(serverUrl, removeServer);

    if (activeServerUrl == serverUrl) {
      var displayName = '';
      var launchType = LaunchType.addServer;
      if (DatabaseManager.serverDatabases.isEmpty) {
        EphemeralStore.theme = null;
        launchType = LaunchType.normal;

        if (activeServerDisplayName != null) {
          displayName = activeServerDisplayName;
        }
      }

      final servers = await getAllServers();
      if (servers.isEmpty) {
        await storeOnboardingViewedValue(false);
      }

      await relaunchApp(launchType: launchType, serverUrl: serverUrl, displayName: displayName);
    }

    terminatingSessionUrl.remove(serverUrl);
  }

  Future<void> onSessionExpired(String serverUrl) async {
    terminatingSessionUrl.add(serverUrl);
    await logout(serverUrl, false, false, true);
    await terminateSession(serverUrl, false);

    final activeServerUrl = await DatabaseManager.getActiveServerUrl();
    final serverDisplayName = await getServerDisplayName(serverUrl);

    await relaunchApp(launchType: LaunchType.normal, serverUrl: serverUrl, displayName: serverDisplayName);
    if (activeServerUrl != null) {
      await addNewServer(getThemeFromState(), serverUrl, serverDisplayName);
    } else {
      EphemeralStore.theme = null;
    }

    terminatingSessionUrl.remove(serverUrl);
  }
}

class LifecycleEventHandler extends WidgetsBindingObserver {
  final AsyncCallback? detachedCallBack;
  final AsyncCallback? resumedCallBack;

  LifecycleEventHandler({this.detachedCallBack, this.resumedCallBack});

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.detached && detachedCallBack != null) {
      await detachedCallBack!();
    } else if (state == AppLifecycleState.resumed && resumedCallBack != null) {
      await resumedCallBack!();
    }
  }
}

enum WebsocketConnectedState { connected, not_connected, connecting }

class ServerCredential {
  final String serverUrl;
  final String token;

  ServerCredential({required this.serverUrl, required this.token});
}