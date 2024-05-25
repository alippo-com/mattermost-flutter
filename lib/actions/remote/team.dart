
  Future<Map<String, dynamic>> addUsersToTeam(String serverUrl, String teamId, List<String> userIds, {bool fetchOnly = false}) async {
    try {
      final client = NetworkManager.getClient(serverUrl);
      final operator = DatabaseManager.getServerDatabaseAndOperator(serverUrl).operator;

      EphemeralStore.startAddingToTeam(teamId);

      final members = await client.addUsersToTeamGracefully(teamId, userIds);

      if (!fetchOnly) {
        final teamMemberships = [];
        final roles = [];

        for (final member in members) {
          teamMemberships.add(member);
          roles.addAll(member.roles.split(' '));
        }

        fetchRolesIfNeeded(serverUrl, roles.toSet().toList());

        if (operator != null) {
          await operator.handleTeamMemberships(teamMemberships: teamMemberships, prepareRecordsOnly: true);
        }
      }

      EphemeralStore.finishAddingToTeam(teamId);
      return {"members": members};
    } catch (error) {
      logDebug('error on addUsersToTeam', getFullErrorMessage(error));
      if (EphemeralStore.isAddingToTeam(teamId)) {
        EphemeralStore.finishAddingToTeam(teamId);
      }

      forceLogoutIfNecessary(serverUrl, error);
      return {"error": error};
    }
  }

  Future<Map<String, dynamic>> sendEmailInvitesToTeam(String serverUrl, String teamId, List<String> emails) async {
    try {
      final client = NetworkManager.getClient(serverUrl);
      final members = await client.sendEmailInvitesToTeamGracefully(teamId, emails);

      return {"members": members};
    } catch (error) {
      logDebug('error on sendEmailInvitesToTeam', getFullErrorMessage(error));
      forceLogoutIfNecessary(serverUrl, error);
      return {"error": error};
    }
  }

  Future<Map<String, dynamic>> fetchMyTeams(String serverUrl, {bool fetchOnly = false}) async {
    try {
      final client = NetworkManager.getClient(serverUrl);
      final database = DatabaseManager.getServerDatabaseAndOperator(serverUrl).database;
      final operator = DatabaseManager.getServerDatabaseAndOperator(serverUrl).operator;

      final teamsAndMemberships = await Future.wait([
        client.getMyTeams(),
        client.getMyTeamMembers(),
      ]);

      final teams = teamsAndMemberships[0];
      final memberships = teamsAndMemberships[1];

      if (!fetchOnly) {
        final modelPromises = [];

        if (operator != null) {
          final removeTeamIds = memberships.where((m) => m.deleteAt > 0).map((m) => m.teamId).toSet();
          final remainingTeams = teams.where((t) => !removeTeamIds.contains(t.id)).toList();
          final prepare = prepareMyTeams(operator, remainingTeams, memberships);
          if (prepare != null) {
            modelPromises.addAll(prepare);
          }

          if (removeTeamIds.isNotEmpty) {
            final removeTeams = await queryTeamsById(database, removeTeamIds.toList()).fetch();
            for (final team in removeTeams) {
              modelPromises.add(prepareDeleteTeam(team));
            }
          }

          if (modelPromises.isNotEmpty) {
            final models = await Future.wait(modelPromises);
            final flattenedModels = models.expand((element) => element).toList();
            if (flattenedModels.isNotEmpty) {
              await operator.batchRecords(flattenedModels, 'fetchMyTeams');
            }
          }
        }
      }

      return {"teams": teams, "memberships": memberships};
    } catch (error) {
      logDebug('error on fetchMyTeams', getFullErrorMessage(error));
      forceLogoutIfNecessary(serverUrl, error);
      return {"error": error};
    }
  }

  Future<Map<String, dynamic>> fetchMyTeam(String serverUrl, String teamId, {bool fetchOnly = false}) async {
    try {
      final client = NetworkManager.getClient(serverUrl);
      final operator = DatabaseManager.getServerDatabaseAndOperator(serverUrl).operator;

      final teamAndMembership = await Future.wait([
        client.getTeam(teamId),
        client.getTeamMember(teamId, 'me'),
      ]);
      final team = teamAndMembership[0];
      final membership = teamAndMembership[1];

      if (!fetchOnly) {
        final modelPromises = prepareMyTeams(operator, [team], [membership]);
        if (modelPromises.isNotEmpty) {
          final models = await Future.wait(modelPromises);
          final flattenedModels = models.expand((element) => element).toList();
          if (flattenedModels.isNotEmpty) {
            await operator.batchRecords(flattenedModels, 'fetchMyTeam');
          }
        }
      }

      return {"teams": [team], "memberships": [membership]};
    } catch (error) {
      logDebug('error on fetchMyTeam', getFullErrorMessage(error));
      forceLogoutIfNecessary(serverUrl, error);
      return {"error": error};
    }
  }

  Future<Map<String, dynamic>> fetchAllTeams(String serverUrl, {int page = 0, int perPage = PER_PAGE_DEFAULT}) async {
    try {
      final client = NetworkManager.getClient(serverUrl);
      final teams = await client.getTeams(page, perPage);
      return {"teams": teams};
    } catch (error) {
      logDebug('error on fetchAllTeams', getFullErrorMessage(error));
      forceLogoutIfNecessary(serverUrl, error);
      return {"error": error};
    }
  }

  Future<bool> recCanJoinTeams(Client client, Set<String> myTeamsIds, int page) async {
    final fetchedTeams = await client.getTeams(page, PER_PAGE_DEFAULT);
    if (fetchedTeams.any((team) => !myTeamsIds contains(team.id) && team.deleteAt == 0)) {
      return true;
    }

    if (fetchedTeams.length == PER_PAGE_DEFAULT) {
      return recCanJoinTeams(client, myTeamsIds, page + 1);
    }

    return false;
  }

  Future<Map<String, dynamic>> fetchTeamsForComponent(String serverUrl, int page, {Set<String>? joinedIds, List<Team> alreadyLoaded = const []}) async {
    bool hasMore = true;
    final result = await fetchAllTeams(serverUrl, page: page, perPage: PER_PAGE_DEFAULT);
    final teams = result["teams"];
    final error = result["error"];

    if (error != null || teams == null || teams.length < PER_PAGE_DEFAULT) {
      hasMore = false;
    }

    if (error != null) {
      return {"teams": alreadyLoaded, "hasMore": hasMore, "page": page};
    }

    if (teams.isNotEmpty) {
      final notJoinedTeams = joinedIds != null ? teams.where((team) => !joinedIds.contains(team.id)).toList() : teams;
      alreadyLoaded.addAll(notJoinedTeams);

      if (teams.length < PER_PAGE_DEFAULT) {
        hasMore = false;
      }

      if (hasMore && alreadyLoaded.length > LOAD_MORE_THRESHOLD) {
        return fetchTeamsForComponent(serverUrl, page + 1, joinedIds: joinedIds, alreadyLoaded: alreadyLoaded);
      }

      return {"teams": alreadyLoaded, "hasMore": hasMore, "page": page + 1};
    }

    return {"teams": alreadyLoaded, "hasMore": false, "page": page};
  }

  Future<void> updateCanJoinTeams(String serverUrl) async {
    try {
      final client = NetworkManager.getClient(serverUrl);
      final database = DatabaseManager.getServerDatabaseAndOperator(serverUrl).database;

      final myTeams = await queryMyTeams(database).fetch();
      final myTeamsIds = myTeams.map((m) => m.id).toSet();

      final canJoin = await recCanJoinTeams(client, myTeamsIds, 0);

      EphemeralStore.setCanJoinOtherTeams(serverUrl, canJoin);
    } catch (error) {
      logDebug('error on updateCanJoinTeams', getFullErrorMessage(error));
      EphemeralStore.setCanJoinOtherTeams(serverUrl, false);
      forceLogoutIfNecessary(serverUrl, error);
    }
  }

  Future<Map<String, dynamic>> fetchTeamsChannelsAndUnreadPosts(String serverUrl, int since, List<Team> teams, List<TeamMembership> memberships, {String? excludeTeamId}) async {
    final database = DatabaseManager.serverDatabases[serverUrl]?.database;
    if (database == null) {
      return {"error": "$serverUrl database not found"};
    }

    final membershipSet = memberships.map((m) => m.teamId).toSet();
    final myTeams = teams.where((team) => membershipSet.contains(team.id) && team.id != excludeTeamId).toList();

    for (final team in myTeams) {
      final channelsAndMemberships = await fetchMyChannelsForTeam(serverUrl, team.id, true, since, false, true);

      if (channelsAndMemberships.channels.isNotEmpty && channelsAndMemberships.memberships.isNotEmpty) {
        fetchPostsForUnreadChannels(serverUrl, channelsAndMemberships.channels, channelsAndMemberships.memberships);
      }
    }

    return {};
  }

  Future<Map<String, dynamic>> fetchTeamByName(String serverUrl, String teamName, {bool fetchOnly = false}) async {
    try {
      final client = NetworkManager.getClient(serverUrl);
      final operator = DatabaseManager.getServerDatabaseAndOperator(serverUrl).operator;

      final team = await client.getTeamByName(teamName);

      if (!fetchOnly) {
        final models = await operator.handleTeam(teams: [team], prepareRecordsOnly: true);
        await operator.batchRecords(models, 'fetchTeamByName');
      }

      return {"team": team};
    } catch (error) {
      logDebug('error on fetchTeamByName', getFullErrorMessage(error));
      forceLogoutIfNecessary(serverUrl, error);
      return {"error": error};
    }
  }

  Future<Map<String, dynamic>> removeCurrentUserFromTeam(String serverUrl, String teamId, {bool fetchOnly = false}) async {
    try {
      final database = DatabaseManager.getServerDatabaseAndOperator(serverUrl).database;
      final userId = await getCurrentUserId(database);
      return removeUserFromTeam(serverUrl, teamId, userId, fetchOnly: fetchOnly);
    } catch (error) {
      return {"error": error};
    }
  }

  Future<Map<String, dynamic>> removeUserFromTeam(String serverUrl, String teamId, String userId, {bool fetchOnly = false}) async {
    try {
      final client = NetworkManager.getClient(serverUrl);
      await client.removeFromTeam(teamId, userId);

      if (!fetchOnly) {
        local_team.removeUserFromTeam(serverUrl, teamId);
        updateCanJoinTeams(serverUrl);
      }

      return {};
    } catch (error) {
      logDebug('error on removeUserFromTeam', getFullErrorMessage(error));
      forceLogoutIfNecessary(serverUrl, error);
      return {"error": error};
    }
  }

  Future<void> handleTeamChange(String serverUrl, String teamId) async {
    final operator = DatabaseManager.serverDatabases[serverUrl]?.operator;
    if (operator == null) {
      return;
    }
    final database = operator.database;

    final currentTeamId = await getCurrentTeamId(database);

    if (currentTeamId == teamId) {
      return;
    }

    String channelId = '';
    SystemChannels.platform.invokeMethod('SystemSound.play');
    if (isTablet()) {
      channelId = await getNthLastChannelFromTeam(database, teamId);
      if (channelId.isNotEmpty) {
        await switchToChannelById(serverUrl, channelId, teamId);
        SystemChannels.platform.invokeMethod('SystemSound.play');
        return;
      }
    }

    final models = [];
    final system = await prepareCommonSystemValues(operator, currentChannelId: channelId, currentTeamId: teamId, lastUnreadChannelId: '');
    if (system.isNotEmpty) {
      models.addAll(system);
    }
    final history = await addTeamToTeamHistory(operator, teamId, true);
    if (history.isNotEmpty) {
      models.addAll(history);
    }

    if (models.isNotEmpty) {
      await operator.batchRecords(models, 'handleTeamChange');
    }
    SystemChannels.platform.invokeMethod('SystemSound.play');

    // Fetch Groups + GroupTeams
    fetchGroupsForTeamIfConstrained(serverUrl, teamId);
  }

  Future<void> handleKickFromTeam(String serverUrl, String teamId) async {
    try {
      final operator = DatabaseManager.getServerDatabaseAndOperator(serverUrl).operator;
      final database = operator.database;
      final currentTeamId = await getCurrentTeamId(database);
      if (currentTeamId != teamId) {
        return;
      }

      final currentServer = await getActiveServerUrl();
      if (currentServer == serverUrl) {
        final team = await getTeamById(database, teamId);
        SystemChannels.platform.invokeMethod('SystemSound.play');
        await dismissAllModalsAndPopToRoot();
      }

      await removeTeamFromTeamHistory(operator, teamId);
      final teamToJumpTo = await getLastTeam(database, teamId);
      if (teamToJumpTo != null) {
        await handleTeamChange(serverUrl, teamToJumpTo);
      }

      // Resetting to team select handled by the home screen
    } catch (error) {
      logDebug('Failed to kick user from team', error);
    }
  }

  Future<Map<String, dynamic>> getTeamMembersByIds(String serverUrl, String teamId, List<String> userIds, {bool fetchOnly = false}) async {
    try {
      final client = NetworkManager.getClient(serverUrl);
      final operator = DatabaseManager.getServerDatabaseAndOperator(serverUrl).operator;
      final members = await client.getTeamMembersByIds(teamId, userIds);

      if (!fetchOnly) {
        final roles = [];

        for (final member in members) {
          roles.addAll(member.roles.split(' '));
        }

        fetchRolesIfNeeded(serverUrl, roles.toSet().toList());

        await operator.handleTeamMemberships(teamMemberships: members, prepareRecordsOnly: true);
      }

      return {"members": members};
    } catch (error) {
      logDebug('error on getTeamMembersByIds', getFullErrorMessage(error));
      forceLogoutIfNecessary(serverUrl, error);
      return {"error": error};
    }
  }
}
