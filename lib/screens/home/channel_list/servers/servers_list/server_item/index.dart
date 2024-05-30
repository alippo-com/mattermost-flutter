// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/material.dart';
import 'package:mattermost_flutter/constants.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';

import 'server_item.dart';
import 'package:mattermost_flutter/types/database/models/app/servers.dart';

class ServerItemWrapper extends StatelessWidget {
  final bool highlight;
  final ServersModel server;

  ServerItemWrapper({required this.highlight, required this.server});

  @override
  Widget build(BuildContext context) {
    final database = Provider.of<Database>(context);

    final tutorialWatched = highlight 
        ? observeTutorialWatched(Tutorial.MULTI_SERVER) 
        : BehaviorSubject<bool>.seeded(false);

    final serverDatabase = DatabaseManager.serverDatabases[server.url]?.database;

    final pushProxyStatus = serverDatabase != null
        ? observePushVerificationStatus(serverDatabase)
        : BehaviorSubject<String>.seeded(PUSH_PROXY_STATUS_UNKNOWN);

    return MultiProvider(
      providers: [
        StreamProvider<ServersModel>(
          initialData: server,
          create: (_) => server.observe(),
        ),
        StreamProvider<bool>(
          initialData: false,
          create: (_) => tutorialWatched,
        ),
        StreamProvider<String>(
          initialData: PUSH_PROXY_STATUS_UNKNOWN,
          create: (_) => pushProxyStatus,
        ),
      ],
      child: ServerItem(),
    );
  }
}
