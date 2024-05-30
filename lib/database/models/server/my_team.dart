// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:watermelondb/watermelondb.dart';
import 'package:watermelondb/decorators.dart';
import 'package:mattermost_flutter/constants/database.dart';
import 'package:mattermost_flutter/types/database/models/servers/my_team.dart';

const TEAM = MM_TABLES.SERVER['TEAM'];
const MY_TEAM = MM_TABLES.SERVER['MY_TEAM'];

/**
 * MyTeam represents only the teams that the current user belongs to
 */
class MyTeamModel extends Model with MyTeamModelInterface {
  /** table (name) : MyTeam */
  static final String tableName = MY_TEAM;

  /** associations : Describes every relationship to this table. */
  static final Map<String, Association> associations = {
    TEAM: Association(type: AssociationType.belongsTo, key: 'id'),
  };

  /** roles : The different permissions that this user has in the team, concatenated together with comma to form a single string. */
  @Field('roles')
  late String roles;

  /** team : The relation to the TEAM, that this user belongs to  */
  @ImmutableRelation(TEAM, 'id')
  late Relation<TeamModel> team;
}
