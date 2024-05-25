// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:watermelondb/watermelondb.dart';
import 'package:watermelondb/associations.dart';
import 'package:mattermost_flutter/types/team.dart';

/**
 * MyTeam represents only the teams that the current user belongs to
 */
class MyTeamModel extends Model {
  /** table (name) : MyTeam */
  static const String tableName = 'MyTeam';

  /** roles : The different permissions that this user has in the team, concatenated together with comma to form a single string. */
  String roles;

  /** team : The relation to the TEAM table, that this user belongs to */
  final team = HasOne<TeamModel>();

  MyTeamModel({
    required this.roles,
  });
}
