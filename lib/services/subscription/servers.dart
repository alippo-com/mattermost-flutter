// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:watermelondb/watermelondb.dart';
import 'package:mattermost_flutter/constants/database.dart';
import 'package:mattermost_flutter/database/manager.dart';
import 'package:mattermost_flutter/types/database/models/app/servers.dart';

class SubscriptionService {
  static Stream<List<ServersModel>> subscribeActiveServers(void Function(List<ServersModel>) observer) {
    final db = DatabaseManager.appDatabase?.database;
    return db
        ?.get<ServersModel>(MM_TABLES.APP.SERVERS)
        .query(Q.where('identifier', Q.notEq('')))
        .observeWithColumns(['display_name', 'last_active_at'])
        .listen(observer);
  }

  static Stream<List<ServersModel>> subscribeAllServers(void Function(List<ServersModel>) observer) {
    final db = DatabaseManager.appDatabase?.database;
    return db
        ?.get<ServersModel>(MM_TABLES.APP.SERVERS)
        .query()
        .observeWithColumns(['last_active_at'])
        .listen(observer);
  }
}
