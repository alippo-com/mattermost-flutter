// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:watermelondb/watermelondb.dart';
import 'package:watermelondb/relations.dart';
import 'package:mattermost_flutter/types/team.dart';
import 'package:mattermost_flutter/types/user.dart';

/**
 * The TeamMembership model represents the 'association table' where many teams have users and many users are in
 * teams (relationship type N:N)
 */
class TeamMembershipModel extends Model {
  /** table (name) : TeamMembership */
  static const String table = 'team_memberships';

  /** associations : Describes every relationship to this table. */
  static final Map<String, Associations> associations = {
    'teams': Associations.belongsTo('teams', 'team_id'),
    'users': Associations.belongsTo('users', 'user_id'),
  };

  /** team_id : The foreign key to the related Team record */
  final String teamId;

  /** user_id : The foreign key to the related User record */
  final String userId;

  /** scheme_admin : Determines if the user is an admin of the team */
  final bool schemeAdmin;

  /** memberUser : The related user in the team */
  Relation<UserModel> get memberUser => relation('user_id');

  /** memberTeam : The related team of users */
  Relation<TeamModel> get memberTeam => relation('team_id');

  /** getAllTeamsForUser - Retrieves all the teams that the user is part of */
  Query<TeamModel> get getAllTeamsForUser => (database.collections.get<TeamModel>('teams') as Query<TeamModel>).query();

  /** getAllUsersInTeam - Retrieves all the users who are part of this team */
  Query<UserModel> get getAllUsersInTeam => (database.collections.get<UserModel>('users') as Query<UserModel>).query();

  TeamMembershipModel({
    required this.teamId,
    required this.userId,
    required this.schemeAdmin,
  });
}
