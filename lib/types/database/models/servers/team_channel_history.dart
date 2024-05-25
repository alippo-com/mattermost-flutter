// Dart (Flutter)
import 'package:watermelondb/watermelondb.dart';
import 'package:watermelondb/decorators.dart';
import 'package:mattermost_flutter/types/database/models/servers/team.dart';
import 'package:mattermost_flutter/constants/database.dart';
import 'package:mattermost_flutter/utils/helpers.dart';
import 'package:mattermost_flutter/types/database/models/servers/team_channel_history_interface.dart';

const TEAM = MM_TABLES.SERVER.TEAM;
const TEAM_CHANNEL_HISTORY = MM_TABLES.SERVER.TEAM_CHANNEL_HISTORY;

/// The TeamChannelHistory model helps keeping track of the last channel visited by the user.
class TeamChannelHistoryModel extends Model implements TeamChannelHistoryModelInterface {
  static String table = TEAM_CHANNEL_HISTORY;

  static final Map<String, Association> associations = {
    TEAM: Association.belongsTo(TEAM, 'id'),
  };

  @Field('channel_ids')
  List<String> get channelIds => safeParseJSON(get('channel_ids') as String).cast<String>();

  @immutableRelation(TEAM, 'id')
  final team = HasOne<TeamModel>();
}
