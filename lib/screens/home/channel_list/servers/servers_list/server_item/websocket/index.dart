// Converted Dart code from React Native TypeScript
// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mattermost_flutter/managers/websocket_manager.dart';
import 'websocket.dart';

class WebSocketState extends ChangeNotifier {
  final String serverUrl;
  WebSocketState(this.serverUrl) {
    observeWebsocketState();
  }

  void observeWebsocketState() {
    WebsocketManager.observeWebsocketState(serverUrl).listen((state) {
      // Handle websocket state changes
      notifyListeners();
    });
  }
}

class EnhancedWebSocket extends StatelessWidget {
  final String serverUrl;

  EnhancedWebSocket({required this.serverUrl});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => WebSocketState(serverUrl),
      child: WebSocket(), // Assuming WebSocket is the Dart equivalent of the React component
    );
  }
}
