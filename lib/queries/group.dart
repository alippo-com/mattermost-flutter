import 'package:nozbe_watermelondb/database.dart';
import 'package:nozbe_watermelondb/query.dart';
import 'package:mattermost_flutter/constants/database.dart';
import 'package:mattermost_flutter/helpers/database.dart';

import 'package:mattermost_flutter/types/group.dart';
import 'package:mattermost_flutter/types/group_channel.dart';
import 'package:mattermost_flutter/types/group_membership.dart';
import 'package:mattermost_flutter/types/group_team.dart';

class GroupQueries {
  static queryGroupsByName(Database database, String name) {
    return database.collections.get<GroupModel>(MM_TABLES.SERVER.GROUP).query(
      Q.where('name', Q.like('%${sanitizeLikeString(name)}%')),
    );
  }

  static queryGroupsByNames(Database database, List<String> names) {
    return database.collections.get<GroupModel>(MM_TABLES.SERVER.GROUP).query(
      Q.where('name', Q.oneOf(names)),
    );
  }

  static queryGroupsByNameInTeam(Database database, String name, String teamId) {
    return database.collections.get<GroupModel>(MM_TABLES.SERVER.GROUP).query(
      Q.on(MM_TABLES.SERVER.GROUP_TEAM, 'team_id', teamId),
      Q.where('name', Q.like('%${sanitizeLikeString(name)}%')),
    );
  }

  static queryGroupsByNameInChannel(Database database, String name, String channelId) {
    return database.collections.get<GroupModel>(MM_TABLES.SERVER.GROUP).query(
      Q.on(MM_TABLES.SERVER.GROUP_CHANNEL, 'channel_id', channelId),
      Q.where('name', Q.like('%${sanitizeLikeString(name)}%')),
    );
  }

  static queryGroupChannelForChannel(Database database, String channelId) {
    return database.collections.get<GroupChannelModel>(MM_TABLES.SERVER.GROUP_CHANNEL).query(
      Q.where('channel_id', channelId),
    );
  }

  static queryGroupMembershipForMember(Database database, String userId) {
    return database.collections.get<GroupMembershipModel>(MM_TABLES.SERVER.GROUP_MEMBERSHIP).query(
      Q.where('user_id', userId),
    );
  }

  static queryGroupTeamForTeam(Database database, String teamId) {
    return database.collections.get<GroupTeamModel>(MM_TABLES.SERVER.GROUP_TEAM).query(
      Q.where('team_id', teamId),
    );
  }

  static deleteGroupMembershipById(Database database, String id) {
    return database.collections.get<GroupMembershipModel>(MM_TABLES.SERVER.GROUP_MEMBERSHIP).find(id).then((model) => model.destroyPermanently());
  }

  static deleteGroupTeamById(Database database, String id) {
    return database.collections.get<GroupTeamModel>(MM_TABLES.SERVER.GROUP_TEAM).find(id).then((model) => model.destroyPermanently());
  }

  static deleteGroupChannelById(Database database, String id) {
    return database.collections.get<GroupChannelModel>(MM_TABLES.SERVER.GROUP_CHANNEL).find(id).then((model) => model.destroyPermanently());
  }
}
