// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:watermelondb/watermelondb.dart';
import 'package:watermelondb/Relation.dart';
import 'package:mattermost_flutter/types/database/models/servers/team.dart';

/**
 * TeamThreadsSyncModel helps us to sync threads without creating any gaps between the threads
 * by keeping track of the latest and earliest last_replied_at timestamps loaded for a team.
 */
class TeamThreadsSyncModel extends Model {
  static final String table = 'TeamThreadsSync';

  int earliest;
  int latest;
  Relation<TeamModel> team;

  TeamThreadsSyncModel({
    required this.earliest,
    required this.latest,
    required this.team,
  });

  static final Map<String, dynamic> associations = {
    // Define associations if needed
  };
}
