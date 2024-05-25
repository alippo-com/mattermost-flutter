
// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:mattermost_flutter/constants/deep_link.dart';
import 'package:mattermost_flutter/database/manager.dart';
import 'package:mattermost_flutter/queries/servers/team.dart';
import 'package:mattermost_flutter/utils/permalink.dart';
import 'package:mattermost_flutter/types/database/models/servers/team.dart';

Future<Map<String, dynamic>> showPermalink(String serverUrl, String teamName, String postId, {bool openAsPermalink = true}) async {
  try {
    final databaseOperator = DatabaseManager.getServerDatabaseAndOperator(serverUrl);
    final database = databaseOperator.database;

    String name = teamName;
    TeamModel? team;

    if (name.isEmpty || name == DeepLink.redirect) {
      team = await getCurrentTeam(database);
      if (team != null) {
        name = team.name;
      }
    }

    await displayPermalink(name, postId, openAsPermalink);

    return {};
  } catch (error) {
    return {'error': error.toString()};
  }
}
