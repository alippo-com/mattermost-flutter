// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:watermelondb/watermelondb.dart';
import 'package:watermelondb/relations.dart';
import 'package:mattermost_flutter/types/group.dart';
import 'package:mattermost_flutter/types/team.dart';

/**
 * The GroupTeam model represents the 'association table' where many groups have teams and many teams are in
 * groups (relationship type N:N)
 */
class GroupTeamModel extends Model {
  /** table (name) : GroupTeam */
  static const String table = 'group_teams';

  /** associations : Describes every relationship to this table. */
  static final Map<String, Associations> associations = {
    'groups': Associations.belongsTo('groups', 'group_id'),
    'teams': Associations.belongsTo('teams', 'team_id'),
  };

  /** group_id : The foreign key to the related Group record */
  final String groupId;

  /** team_id : The foreign key to the related Team record */
  final String teamId;

  /** created_at : The timestamp for when it was created */
  final int createdAt;

  /** updated_at : The timestamp for when it was updated */
  final int updatedAt;

  /** deleted_at : The timestamp for when it was deleted */
  final int deletedAt;

  /** group : The related group */
  Relation<GroupModel> get group => relation('group_id');

  /** team : The related team */
  Relation<TeamModel> get team => relation('team_id');

  GroupTeamModel({
    required this.groupId,
    required this.teamId,
    required this.createdAt,
    required this.updatedAt,
    required this.deletedAt,
  });
}
