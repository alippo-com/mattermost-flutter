// Dart (Flutter)
import 'package:watermelondb/watermelondb.dart';
import 'package:watermelondb/decorators.dart';
import 'package:mattermost_flutter/types/database/models/servers/team.dart';
import 'package:mattermost_flutter/types/database/models/servers/user.dart';
import 'package:mattermost_flutter/constants/database.dart';
import 'package:mattermost_flutter/utils/helpers.dart';
import 'package:mattermost_flutter/types/database/models/servers/team_membership_interface.dart';

const TEAM = MM_TABLES.SERVER.TEAM;
const TEAM_MEMBERSHIP = MM_TABLES.SERVER.TEAM_MEMBERSHIP;
const USER = MM_TABLES.SERVER.USER;

/// The TeamMembership model represents the 'association table' where many teams have users and many users are in
/// teams (relationship type N:N)
class TeamMembershipModel extends Model implements TeamMembershipModelInterface {
  static String table = TEAM_MEMBERSHIP;

  static final Map<String, Association> associations = {
    TEAM: Association.belongsTo(TEAM, 'team_id'),
    USER: Association.belongsTo(USER, 'user_id'),
  };

  @Field('team_id')
  String teamId;

  @Field('user_id')
  String userId;

  @Field('scheme_admin')
  bool schemeAdmin;

  @immutableRelation(USER, 'user_id')
  final memberUser = HasOne<UserModel>();

  @immutableRelation(TEAM, 'team_id')
  final memberTeam = HasOne<TeamModel>();

  @lazy
  Query<TeamModel> get getAllTeamsForUser =>
      collections.get<TeamModel>(TEAM).query(Q.on(USER, 'id', userId));

  @lazy
  Query<UserModel> get getAllUsersInTeam =>
      collections.get<UserModel>(USER).query(Q.on(TEAM, 'id', teamId));
}
