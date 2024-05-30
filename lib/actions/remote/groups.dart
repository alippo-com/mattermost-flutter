import 'package:mattermost_flutter/database/manager.dart';
import 'package:mattermost_flutter/queries/servers/channel.dart';
import 'package:mattermost_flutter/utils/errors.dart';
import 'package:mattermost_flutter/utils/log.dart';


import '../types/client.dart';

Future<List<dynamic>> fetchGroupsForAutocomplete(String serverUrl, String query, {bool fetchOnly = false}) async {
  try {
    final databaseManager = DatabaseManager.getServerDatabaseAndOperator(serverUrl);
    final license = await getLicense(databaseManager.database);
    if (license == null || license.isLicensed != 'true') {
      return [];
    }

    final client = NetworkManager.getClient(serverUrl);
    final response = await client.getGroups(query: query, includeMemberCount: true);

    if (response.isEmpty) {
      return [];
    }

    return databaseManager.operator.handleGroups(groups: response, prepareRecordsOnly: fetchOnly);
  } catch (error) {
    logDebug('error on fetchGroupsForAutocomplete', getFullErrorMessage(error));
    forceLogoutIfNecessary(serverUrl, error);
    return {'error': error};
  }
}

Future<List<dynamic>> fetchGroupsByNames(String serverUrl, List<String> names, {bool fetchOnly = false}) async {
  try {
    final databaseManager = DatabaseManager.getServerDatabaseAndOperator(serverUrl);
    final license = await getLicense(databaseManager.database);
    if (license == null || license.isLicensed != 'true') {
      return [];
    }

    final client = NetworkManager.getClient(serverUrl);
    final responseFutures = names.map((name) => client.getGroups(query: name)).toList();
    final groups = (await Future.wait(responseFutures)).expand((group) => group).toList();

    if (groups.isEmpty) {
      return [];
    }

    return databaseManager.operator.handleGroups(groups: groups, prepareRecordsOnly: fetchOnly);
  } catch (error) {
    logDebug('error on fetchGroupsByNames', getFullErrorMessage(error));
    forceLogoutIfNecessary(serverUrl, error);
    return {'error': error};
  }
}

Future<Map<String, dynamic>> fetchGroupsForChannel(String serverUrl, String channelId, {bool fetchOnly = false}) async {
  try {
    final databaseManager = DatabaseManager.getServerDatabaseAndOperator(serverUrl);
    final license = await getLicense(databaseManager.database);
    if (license == null || license.isLicensed != 'true') {
      return {'groups': [], 'groupChannels': []};
    }

    final client = NetworkManager.getClient(serverUrl);
    final response = await client.getAllGroupsAssociatedToChannel(channelId);

    if (response['groups'].isEmpty) {
      return {'groups': [], 'groupChannels': []};
    }

    final groups = await databaseManager.operator.handleGroups(groups: response['groups'], prepareRecordsOnly: true);
    final groupChannels = await databaseManager.operator.handleGroupChannelsForChannel(groups: response['groups'], channelId: channelId, prepareRecordsOnly: true);

    if (!fetchOnly) {
      await databaseManager.operator.batchRecords([...groups, ...groupChannels], 'fetchGroupsForChannel');
    }

    return {'groups': groups, 'groupChannels': groupChannels};
  } catch (error) {
    logDebug('error on fetchGroupsForChannel', getFullErrorMessage(error));
    forceLogoutIfNecessary(serverUrl, error);
    return {'error': error};
  }
}

Future<Map<String, dynamic>> fetchGroupsForTeam(String serverUrl, String teamId, {bool fetchOnly = false}) async {
  try {
    final databaseManager = DatabaseManager.getServerDatabaseAndOperator(serverUrl);
    final license = await getLicense(databaseManager.database);
    if (license == null || license.isLicensed != 'true') {
      return {'groups': [], 'groupTeams': []};
    }

    final client = NetworkManager.getClient(serverUrl);
    final response = await client.getAllGroupsAssociatedToTeam(teamId);

    if (response['groups'].isEmpty) {
      return {'groups': [], 'groupTeams': []};
    }

    final groups = await databaseManager.operator.handleGroups(groups: response['groups'], prepareRecordsOnly: true);
    final groupTeams = await databaseManager.operator.handleGroupTeamsForTeam(groups: response['groups'], teamId: teamId, prepareRecordsOnly: true);

    if (!fetchOnly) {
      await databaseManager.operator.batchRecords([...groups, ...groupTeams], 'fetchGroupsForTeam');
    }

    return {'groups': groups, 'groupTeams': groupTeams};
  } catch (error) {
    logDebug('error on fetchGroupsForTeam', getFullErrorMessage(error));
    return {'error': error};
  }
}

Future<Map<String, dynamic>> fetchGroupsForMember(String serverUrl, String userId, {bool fetchOnly = false}) async {
  try {
    final databaseManager = DatabaseManager.getServerDatabaseAndOperator(serverUrl);
    final license = await getLicense(databaseManager.database);
    if (license == null || license.isLicensed != 'true') {
      return {'groups': [], 'groupMemberships': []};
    }

    final client = NetworkManager.getClient(serverUrl);
    final response = await client.getAllGroupsAssociatedToMembership(userId);

    if (response.isEmpty) {
      return {'groups': [], 'groupMemberships': []};
    }

    final groups = await databaseManager.operator.handleGroups(groups: response, prepareRecordsOnly: true);
    final groupMemberships = await databaseManager.operator.handleGroupMembershipsForMember(groups: response, userId: userId, prepareRecordsOnly: true);

    if (!fetchOnly) {
      await databaseManager.operator.batchRecords([...groups, ...groupMemberships], 'fetchGroupsForMember');
    }

    return {'groups': groups, 'groupMemberships': groupMemberships};
  } catch (error) {
    logDebug('error on fetchGroupsForMember', getFullErrorMessage(error));
    return {'error': error};
  }
}

Future<List<dynamic>> fetchFilteredTeamGroups(String serverUrl, String searchTerm, String teamId) async {
  final res = await fetchGroupsForTeam(serverUrl, teamId);
  if (res.containsKey('error')) {
    return {'error': res['error']};
  }
  return res['groups'].where((g) => g.name.toLowerCase().contains(searchTerm.toLowerCase())).toList();
}

Future<List<dynamic>> fetchFilteredChannelGroups(String serverUrl, String searchTerm, String channelId) async {
  final res = await fetchGroupsForChannel(serverUrl, channelId);
  if (res.containsKey('error')) {
    return {'error': res['error']};
  }
  return res['groups'].where((g) => g.name.toLowerCase().contains(searchTerm.toLowerCase())).toList();
}

Future<Map<String, dynamic>> fetchGroupsForTeamIfConstrained(String serverUrl, String teamId, {bool fetchOnly = false}) async {
  try {
    final databaseManager = DatabaseManager.getServerDatabaseAndOperator(serverUrl);
    final team = await getTeamById(databaseManager.database, teamId);

    if (team?.isGroupConstrained ?? false) {
      return await fetchGroupsForTeam(serverUrl, teamId, fetchOnly: fetchOnly);
    }

    return {};
  } catch (error) {
    return {'error': error};
  }
}

Future<Map<String, dynamic>> fetchGroupsForChannelIfConstrained(String serverUrl, String channelId, {bool fetchOnly = false}) async {
  try {
    final databaseManager = DatabaseManager.getServerDatabaseAndOperator(serverUrl);
    final channel = await getChannelById(databaseManager.database, channelId);

    if (channel?.isGroupConstrained ?? false) {
      return await fetchGroupsForChannel(serverUrl, channelId, fetchOnly: fetchOnly);
    }

    return {};
  } catch (error) {
    return {'error': error};
  }
}
