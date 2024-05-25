// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:watermelondb/watermelondb.dart';
import 'package:mattermost_flutter/types/database/models/team.dart';

/**
 * MyTeamModel represents only the teams that the current user belongs to
 */
class MyTeamModel extends Model {
  static const String table = 'MyTeam';

  // The different permissions that this user has in the team, concatenated together with comma to form a single string.
  String roles;

  // The relation to the TEAM table, that this user belongs to
  Relation<TeamModel> team;

  MyTeamModel({
    required this.roles,
    required this.team,
  });
}
