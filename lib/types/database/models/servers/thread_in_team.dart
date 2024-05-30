import 'package:watermelondb/watermelondb.dart';
import 'package:watermelondb/decorators.dart';
import 'package:mattermost_flutter/types/database/models/servers/thread.dart';
import 'package:mattermost_flutter/constants/database.dart';
import 'package:mattermost_flutter/types/database/models/servers/thread_in_team_interface.dart';

const TEAM = MM_TABLES.SERVER.TEAM;
const THREAD = MM_TABLES.SERVER.THREAD;
const THREADS_IN_TEAM = MM_TABLES.SERVER.THREADS_IN_TEAM;

/// The ThreadInTeam model helps us to combine adjacent threads together without leaving
/// gaps in between for an efficient user reading experience for threads.
class ThreadInTeamModel extends Model implements ThreadInTeamModelInterface {
  static String table = THREADS_IN_TEAM;

  static final Map<String, Association> associations = {
    TEAM: Association.belongsTo(TEAM, 'team_id'),
    THREAD: Association.belongsTo(THREAD, 'thread_id'),
  };

  @Field('thread_id')
  String threadId;

  @Field('team_id')
  String teamId;

  @immutableRelation(THREAD, 'thread_id')
  final thread = HasOne<ThreadModel>();

  @immutableRelation(TEAM, 'team_id')
  final team = HasOne<TeamModel>();
}
