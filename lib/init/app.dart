// Converted Dart code from TypeScript

import 'package:mattermost_flutter/database/manager.dart';
import 'package:mattermost_flutter/init/credentials.dart';
import 'package:mattermost_flutter/init/launch.dart';
import 'package:mattermost_flutter/init/managed_app.dart';
import 'package:mattermost_flutter/init/push_notifications.dart';
import 'package:mattermost_flutter/managers/global_event_handler.dart';
import 'package:mattermost_flutter/managers/network_manager.dart';
import 'package:mattermost_flutter/managers/session_manager.dart';
import 'package:mattermost_flutter/managers/websocket_manager.dart';
import 'package:mattermost_flutter/screens/index.dart';
import 'package:mattermost_flutter/screens/navigation.dart';
import 'package:mattermost_flutter/store/ephemeral_store.dart';
import 'package:mattermost_flutter/store/navigation_store.dart';

bool baseAppInitialized = false;

List<ServerCredential> serverCredentials = [];

Future<void> initialize() async {
  if (!baseAppInitialized) {
    baseAppInitialized = true;
    serverCredentials = await getAllServerCredentials();
    final serverUrls = serverCredentials.map((credential) => credential.serverUrl).toList();

    await DatabaseManager.init(serverUrls);
    await NetworkManager.init(serverCredentials);

    GlobalEventHandler.init();
    ManagedApp.init();
    SessionManager.init();
  }
}

Future<void> start() async {
  NavigationStore.reset();
  EphemeralStore.setCurrentThreadId('');
  EphemeralStore.setProcessingNotification('');

  await initialize();

  PushNotifications.init(serverCredentials.isNotEmpty);

  registerNavigationListeners();
  registerScreens();

  await WebsocketManager.init(serverCredentials);

  initialLaunch();
}
