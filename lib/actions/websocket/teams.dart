import 'dart:convert';

import 'package:mattermost_flutter/actions/local/team.dart';
import 'package:mattermost_flutter/actions/remote/channel.dart';
import 'package:mattermost_flutter/actions/remote/role.dart';
import 'package:mattermost_flutter/actions/remote/team.dart';
import 'package:mattermost_flutter/database/manager.dart';
import 'package:mattermost_flutter/queries/servers/categories.dart';
import 'package:mattermost_flutter/queries/servers/channel.dart';
import 'package:mattermost_flutter/queries/servers/user.dart';
import 'package:mattermost_flutter/store/ephemeral_store.dart';
import 'package:mattermost_flutter/store/team_load_store.dart';
import 'package:mattermost_flutter/utils/errors.dart';
import 'package:mattermost_flutter/utils/log.dart';

// Assuming WebSocketMessage and other types are defined here

import 'package:types/types.dart'; // Assuming Team, TeamMembership, ServerDataOperator, WebSocketMessage, and Model are defined here

Future<void> handleTeamArchived(String serverUrl, WebSocketMessage msg) async {
  try {
    final database = DatabaseManager.getServerDatabaseAndOperator(serverUrl).database;
    final team = Team.fromJson(jsonDecode(msg.data['team']));
    
    final membership = (await queryMyTeamsByIds(database, [team.id]).fetch())[0];
    if (membership != null) {
      final currentTeam = await getCurrentTeam(database);
      if (currentTeam?.id == team.id) {
        await handleKickFromTeam(serverUrl, team.id);
      }

      await removeUserFromTeam(serverUrl, team.id);

      final user = await getCurrentUser(database);
      if (user?.isGuest ?? false) {
        updateUsersNoLongerVisible(serverUrl);
      }
    }
    updateCanJoinTeams(serverUrl);
  } catch (error) {
    logDebug('cannot handle archive team websocket event', error);
  }
}

Future<void> handleTeamRestored(String serverUrl, WebSocketMessage msg) async {
  bool markedAsLoading = false;
  try {
    final client = NetworkManager.getClient(serverUrl);
    final operator = DatabaseManager.getServerDatabaseAndOperator(serverUrl).operator;
    final team = Team.fromJson(jsonDecode(msg.data['team']));

    final teamMembership = await client.getTeamMember(team.id, 'me');
    if (teamMembership != null && teamMembership.deleteAt == 0) {
      // Ignore duplicated team join events sent by the server
      if (EphemeralStore.isAddingToTeam(team.id)) {
        return;
      }
      EphemeralStore.startAddingToTeam(team.id);

      setTeamLoading(serverUrl, true);
      markedAsLoading = true;
      await fetchAndStoreJoinedTeamInfo(serverUrl, operator, team.id, [team], [teamMembership]);
      setTeamLoading(serverUrl, false);
      markedAsLoading = false;

      EphemeralStore.finishAddingToTeam(team.id);
    }

    updateCanJoinTeams(serverUrl);
  } catch (error) {
    if (markedAsLoading) {
      setTeamLoading(serverUrl, false);
    }
    logDebug('cannot handle restore team websocket event', getFullErrorMessage(error));
  }
}

Future<void> handleLeaveTeamEvent(String serverUrl, WebSocketMessage msg) async {
  try {
    final database = DatabaseManager.getServerDatabaseAndOperator(serverUrl).database;

    final user = await getCurrentUser(database);
    if (user == null) {
      return;
    }

    final userId = msg.data['user_id'];
    final teamId = msg.data['team_id'];
    if (user.id == userId) {
      final currentTeam = await getCurrentTeam(database);
      if (currentTeam?.id == teamId) {
        await handleKickFromTeam(serverUrl, teamId);
      }

      await removeUserFromTeam(serverUrl, teamId);
      updateCanJoinTeams(serverUrl);

      if (user.isGuest) {
        updateUsersNoLongerVisible(serverUrl);
      }
    }
  } catch (error) {
    logDebug('cannot handle leave team websocket event', error);
  }
}

Future<void> handleUpdateTeamEvent(String serverUrl, WebSocketMessage msg) async {
  try {
    final operator = DatabaseManager.getServerDatabaseAndOperator(serverUrl).operator;

    final team = Team.fromJson(jsonDecode(msg.data['team']));
    operator.handleTeam({
      'teams': [team],
      'prepareRecordsOnly': false,
    });
  } catch (err) {
    // Do nothing
  }
}

Future<void> handleUserAddedToTeamEvent(String serverUrl, WebSocketMessage msg) async {
  final teamId = msg.data['team_id'];

  // Ignore duplicated team join events sent by the server
  if (EphemeralStore.isAddingToTeam(teamId)) {
    return;
  }
  EphemeralStore.startAddingToTeam(teamId);

  try {
    setTeamLoading(serverUrl, true);
    final operator = DatabaseManager.getServerDatabaseAndOperator(serverUrl).operator;
    final response = await fetchMyTeam(serverUrl, teamId, true);
    final teams = response.teams;
    final teamMemberships = response.memberships;

    await fetchAndStoreJoinedTeamInfo(serverUrl, operator, teamId, teams, teamMemberships);
  } catch (error) {
    logDebug('could not handle user added to team websocket event');
  }
  setTeamLoading(serverUrl, false);
  EphemeralStore.finishAddingToTeam(teamId);
}

Future<void> fetchAndStoreJoinedTeamInfo(String serverUrl, ServerDataOperator operator, String teamId, List<Team> teams, List<TeamMembership> teamMemberships) async {
  final modelPromises = <Future<List<Model>>>[];
  if (teams.isNotEmpty && teamMemberships.isNotEmpty) {
    final response = await fetchMyChannelsForTeam(serverUrl, teamId, false, 0, true);
    final channels = response.channels;
    final memberships = response.memberships;
    final categories = response.categories;
    modelPromises.add(prepareCategoriesAndCategoriesChannels(operator, categories, true));
    modelPromises.addAll(await prepareMyChannelsForTeam(operator, teamId, channels, memberships));

    final roles = await fetchRoles(serverUrl, teamMemberships, memberships, null, true);
    if (roles.isNotEmpty) {
      modelPromises.add(operator.handleRole({'roles': roles, 'prepareRecordsOnly': true}));
    }
  }

  if (teams.isNotEmpty && teamMemberships.isNotEmpty) {
    modelPromises.addAll(await prepareMyTeams(operator, teams, teamMemberships));
  }

  final models = await Future.wait(modelPromises);
  await operator.batchRecords(models.expand((element) => element).toList(), 'fetchAndStoreJoinedTeamInfo');
}
