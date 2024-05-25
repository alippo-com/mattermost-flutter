
import 'package:flutter/material.dart';
import 'package:mattermost_flutter/context/server.dart';
import 'package:mattermost_flutter/managers/websocket_manager.dart';
import 'package:mattermost_flutter/components/connection_banner/connection_banner.dart';
import 'package:rxdart/rxdart.dart';

class ConnectionBannerContainer extends StatelessWidget {
  final String serverUrl;

  ConnectionBannerContainer({required this.serverUrl});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: websocketManager.observeWebsocketState(serverUrl),
      builder: (context, snapshot) {
        return ConnectionBanner(websocketState: snapshot.data);
      },
    );
  }
}
