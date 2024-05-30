
import 'package:flutter/material.dart';
import 'package:mattermost_flutter/context/server.dart';
import 'package:mattermost_flutter/components/connection_banner/connection_banner.dart';

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
