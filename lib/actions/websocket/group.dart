import 'package:mattermost_flutter/actions/remote/groups.dart';
import 'package:mattermost_flutter/database/manager.dart';
import 'package:mattermost_flutter/queries/servers/group.dart';
import 'package:mattermost_flutter/utils/groups.dart';
import 'package:mattermost_flutter/utils/log.dart';
import 'package:sqflite/sqflite.dart'; // Assuming sqflite is used for database operations

class WebSocketMessage<T> {
  final T? data;
  final String event;
  final Broadcast broadcast;

  WebSocketMessage({this.data, required this.event, required this.broadcast});
}

class Group {
  // Define the properties and methods of Group here
}

class GroupMembership {
  final String group_id;
  final String user_id;

  GroupMembership({required this.group_id, required this.user_id});
}

class GroupTeam {
  final String group_id;
  final String team_id;

  GroupTeam({required this.group_id, required this.team_id});
}

class GroupChannel {
  final String group_id;
  final String channel_id;

  GroupChannel({required this.group_id, required this.channel_id});
}

class Broadcast {
  final String? team_id;
  final String? channel_id;
  final String? user_id;

  Broadcast({this.team_id, this.channel_id, this.user_id});
}

typedef WebsocketGroupMessage = WebSocketMessage<Map<String, dynamic>>;
typedef WebsocketGroupMemberMessage = WebSocketMessage<Map<String, dynamic>>;
typedef WebsocketGroupTeamMessage = WebSocketMessage<Map<String, dynamic>>;
typedef WebsocketGroupChannelMessage = WebSocketMessage<Map<String, dynamic>>;
typedef WSMessage = dynamic; // Union types are not supported in Dart

void handleError(String serverUrl, dynamic e, WSMessage msg) {
  logError('Group WS: \${msg.event}', e, msg);

  final teamId = msg.broadcast.team_id;
  final channelId = msg.broadcast.channel_id;
  final userId = msg.broadcast.user_id;

  if (teamId != null) {
    fetchGroupsForTeam(serverUrl, teamId);
  }
  if (channelId != null) {
    fetchGroupsForChannel(serverUrl, channelId);
  }
  if (userId != null) {
    fetchGroupsForMember(serverUrl, userId);
  }
}

Future<void> handleGroupReceivedEvent(String serverUrl, WebsocketGroupMessage msg) async {
  Group group;

  try {
    if (msg.data?['group'] != null) {
      final operator = DatabaseManager.getServerDatabaseAndOperator(serverUrl).operator;
      group = Group.fromJson(msg.data!['group']);
      operator.handleGroups(groups: [group], prepareRecordsOnly: false);
    }
  } catch (e) {
    handleError(serverUrl, e, msg);
  }
}

Future<void> handleGroupMemberAddEvent(String serverUrl, WebsocketGroupMemberMessage msg) async {
  GroupMembership groupMember;

  try {
    if (msg.data?['group_member'] != null) {
      final operator = DatabaseManager.getServerDatabaseAndOperator(serverUrl).operator;
      groupMember = GroupMembership.fromJson(msg.data!['group_member']);
      final group = Group(id: groupMember.group_id);

      operator.handleGroupMembershipsForMember(userId: groupMember.user_id, groups: [group], prepareRecordsOnly: false);
    }
  } catch (e) {
    handleError(serverUrl, e, msg);
  }
}

Future<void> handleGroupMemberDeleteEvent(String serverUrl, WebsocketGroupMemberMessage msg) async {
  GroupMembership groupMember;

  try {
    if (msg.data?['group_member'] != null) {
      final database = DatabaseManager.getServerDatabaseAndOperator(serverUrl).database;
      groupMember = GroupMembership.fromJson(msg.data!['group_member']);

      await deleteGroupMembershipById(database, generateGroupAssociationId(groupMember.group_id, groupMember.user_id));
    }
  } catch (e) {
    handleError(serverUrl, e, msg);
  }
}

Future<void> handleGroupTeamAssociatedEvent(String serverUrl, WebsocketGroupTeamMessage msg) async {
  GroupTeam groupTeam;

  try {
    if (msg.data?['group_team'] != null) {
      final operator = DatabaseManager.getServerDatabaseAndOperator(serverUrl).operator;
      groupTeam = GroupTeam.fromJson(msg.data!['group_team']);
      final group = Group(id: groupTeam.group_id);

      operator.handleGroupTeamsForTeam(teamId: groupTeam.team_id, groups: [group], prepareRecordsOnly: false);
    }
  } catch (e) {
    handleError(serverUrl, e, msg);
  }
}

Future<void> handleGroupTeamDissociateEvent(String serverUrl, WebsocketGroupTeamMessage msg) async {
  GroupTeam groupTeam;

  try {
    if (msg.data?['group_team'] != null) {
      final database = DatabaseManager.getServerDatabaseAndOperator(serverUrl).database;
      groupTeam = GroupTeam.fromJson(msg.data!['group_team']);

      await deleteGroupTeamById(database, generateGroupAssociationId(groupTeam.group_id, groupTeam.team_id));
    }
  } catch (e) {
    handleError(serverUrl, e, msg);
  }
}

Future<void> handleGroupChannelAssociatedEvent(String serverUrl, WebsocketGroupChannelMessage msg) async {
  GroupChannel groupChannel;

  try {
    if (msg.data?['group_channel'] != null) {
      final operator = DatabaseManager.getServerDatabaseAndOperator(serverUrl).operator;
      groupChannel = GroupChannel.fromJson(msg.data!['group_channel']);
      final group = Group(id: groupChannel.group_id);

      operator.handleGroupChannelsForChannel(channelId: groupChannel.channel_id, groups: [group], prepareRecordsOnly: false);
    }
  } catch (e) {
    handleError(serverUrl, e, msg);
  }
}

Future<void> handleGroupChannelDissociateEvent(String serverUrl, WebsocketGroupChannelMessage msg) async {
  GroupChannel groupChannel;

  try {
    if (msg.data?['group_channel'] != null) {
      final database = DatabaseManager.getServerDatabaseAndOperator(serverUrl).database;
      groupChannel = GroupChannel.fromJson(msg.data!['group_channel']);

      await deleteGroupChannelById(database, generateGroupAssociationId(groupChannel.group_id, groupChannel.channel_id));
    }
  } catch (e) {
    handleError(serverUrl, e, msg);
  }
}
