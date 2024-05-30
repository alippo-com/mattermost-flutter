// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:mattermost_flutter/constants/general.dart';
import 'package:mattermost_flutter/database/database_manager.dart';
import 'package:mattermost_flutter/utils/errors.dart';
import 'package:mattermost_flutter/utils/log.dart';


class RolesRequest {
  final dynamic error;
  final List<Role>? roles;

  RolesRequest({this.error, this.roles});
}

Future<RolesRequest> fetchRolesIfNeeded(
  String serverUrl, 
  List<String> updatedRoles, 
  {bool fetchOnly = false, bool force = false}
) async {
  if (updatedRoles.isEmpty) {
    return RolesRequest(roles: []);
  }

  try {
    final client = NetworkManager.getClient(serverUrl);
    final databaseManager = DatabaseManager.getServerDatabaseAndOperator(serverUrl);

    List<String> newRoles;
    if (force) {
      newRoles = updatedRoles;
    } else {
      final existingRoles = await queryRoles(databaseManager.database).fetch();

      final roleNames = Set.from(existingRoles.map((role) => role.name));

      newRoles = updatedRoles.where((newRole) => !roleNames.contains(newRole)).toList();
    }

    if (newRoles.isEmpty) {
      return RolesRequest(roles: []);
    }

    final getRolesRequests = <Future<List<Role>>>[];
    for (var i = 0; i < newRoles.length; i += General.MAX_GET_ROLES_BY_NAMES) {
      final chunk = newRoles.sublist(i, i + General.MAX_GET_ROLES_BY_NAMES);
      getRolesRequests.add(client.getRolesByNames(chunk));
    }

    final roles = (await Future.wait(getRolesRequests)).expand((x) => x).toList();
    if (!fetchOnly) {
      await databaseManager.operator.handleRole(roles: roles, prepareRecordsOnly: false);
    }

    return RolesRequest(roles: roles);
  } catch (error) {
    logDebug('Error on fetchRolesIfNeeded', getFullErrorMessage(error));
    forceLogoutIfNecessary(serverUrl, error);
    return RolesRequest(error: error);
  }
}

Future<RolesRequest> fetchRoles(
  String serverUrl, 
  {List<TeamMembership>? teamMembership, 
  List<ChannelMembership>? channelMembership, 
  UserProfile? user, 
  bool fetchOnly = false, 
  bool force = false}
) async {
  final rolesToFetch = <String>{...user?.roles.split(' ') ?? []};

  if (teamMembership?.isNotEmpty ?? false) {
    final teamRoles = teamMembership!.expand((tm) => tm.roles.split(' ')).toList();
    rolesToFetch.addAll(teamRoles);
  }

  if (channelMembership?.isNotEmpty ?? false) {
    for (var member in channelMembership!) {
      rolesToFetch.addAll(member.roles.split(' '));
    }
  }

  rolesToFetch.remove('');
  if (rolesToFetch.isNotEmpty) {
    return await fetchRolesIfNeeded(serverUrl, rolesToFetch.toList(), fetchOnly: fetchOnly, force: force);
  }

  return RolesRequest(roles: []);
}
