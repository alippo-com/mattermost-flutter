import 'package:watermelondb/watermelondb.dart';
import 'package:watermelondb/decorators.dart';
import 'package:mattermost_flutter/types/database/models/servers/group.dart';
import 'package:mattermost_flutter/constants/database.dart';
import 'package:mattermost_flutter/types/database/models/servers/group_team_interface.dart';

const GROUP = MM_TABLES.SERVER.GROUP;
const TEAM = MM_TABLES.SERVER.TEAM;
const GROUP_TEAM = MM_TABLES.SERVER.GROUP_TEAM;

/// The GroupTeam model represents the 'association table' where many groups have teams and many teams are in
/// groups (relationship type N:N)
class GroupTeamModel extends Model implements GroupTeamInterface {
  static String table = GROUP_TEAM;

  static final Map<String, Association> associations = {
    GROUP: Association.belongsTo(GROUP, 'group_id'),
    TEAM: Association.belongsTo(TEAM, 'team_id'),
  };

  @Field('group_id')
  String groupId;

  @Field('team_id')
  String teamId;

  @Field('created_at')
  int createdAt;

  @Field('updated_at')
  int updatedAt;

  @Field('deleted_at')
  int deletedAt;

  @immutableRelation(GROUP, 'group_id')
  final group = HasOne<GroupModel>();

  @immutableRelation(TEAM, 'team_id')
  final team = HasOne<TeamModel>();
}
