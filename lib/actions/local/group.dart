// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:mattermost_flutter/actions/remote/groups.dart';
import 'package:mattermost_flutter/database/manager.dart';
import 'package:mattermost_flutter/queries/servers/group.dart';
import 'package:mattermost_flutter/utils/log.dart';
import 'package:mattermost_flutter/types/database/models/servers/group.dart';

Future<List<GroupModel>> searchGroupsByName(String serverUrl, String name) async {
  var database;

  try {
    database = DatabaseManager.getServerDatabaseAndOperator(serverUrl).database;
  } catch (e) {
    logError('searchGroupsByName - DB Error', e);
    return [];
  }

  try {
    final groups = await fetchGroupsForAutocomplete(serverUrl, name);

    if (groups != null && groups is List) {
      return groups;
    }
    throw groups.error;
  } catch (e) {
    logError('searchGroupsByName - ERROR', e);
    return queryGroupsByName(database, name).fetch();
  }
}

Future<List<GroupModel>> searchGroupsByNameInTeam(String serverUrl, String name, String teamId) async {
  var database;

  try {
    database = DatabaseManager.getServerDatabaseAndOperator(serverUrl).database;
  } catch (e) {
    logError('searchGroupsByNameInTeam - DB Error', e);
    return [];
  }

  try {
    final groups = await fetchFilteredTeamGroups(serverUrl, name, teamId);

    if (groups != null && groups is List) {
      return groups;
    }
    throw groups.error;
  } catch (e) {
    logError('searchGroupsByNameInTeam - ERROR', e);
    return queryGroupsByNameInTeam(database, name, teamId).fetch();
  }
}

Future<List<GroupModel>> searchGroupsByNameInChannel(String serverUrl, String name, String channelId) async {
  var database;

  try {
    database = DatabaseManager.getServerDatabaseAndOperator(serverUrl).database;
  } catch (e) {
    logError('searchGroupsByNameInChannel - DB Error', e);
    return [];
  }

  try {
    final groups = await fetchFilteredChannelGroups(serverUrl, name, channelId);

    if (groups != null && groups is List) {
      return groups;
    }
    throw groups.error;
  } catch (e) {
    logError('searchGroupsByNameInChannel - ERROR', e);
    return queryGroupsByNameInChannel(database, name, channelId).fetch();
  }
}
