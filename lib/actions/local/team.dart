// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:mattermost_flutter/database/manager.dart';
import 'package:mattermost_flutter/queries/servers/team.dart';
import 'package:mattermost_flutter/utils/log.dart';
import 'package:watermelondb/watermelondb.dart';

Future<Map<String, dynamic>> removeUserFromTeam(String serverUrl, String teamId) async {
  try {
    final databaseAndOperator = DatabaseManager.getServerDatabaseAndOperator(serverUrl);
    final database = databaseAndOperator.database;
    final operator = databaseAndOperator.operator;

    final myTeam = await getMyTeamById(database, teamId);
    if (myTeam != null) {
      final team = await getTeamById(database, myTeam.id);
      if (team == null) {
        throw Exception('Team not found');
      }
      final models = await prepareDeleteTeam(team);
      final system = await removeTeamFromTeamHistory(operator, team.id, true);
      if (system != null) {
        models.addAll(system);
      }
      if (models.isNotEmpty) {
        await operator.batchRecords(models, 'removeUserFromTeam');
      }
    }

    return {'error': null};
  } catch (error) {
    logError('Failed removeUserFromTeam', error);
    return {'error': error};
  }
}

Future<Map<String, dynamic>> addSearchToTeamSearchHistory(String serverUrl, String teamId, String terms) async {
  const int MAX_TEAM_SEARCHES = 15;
  try {
    final databaseAndOperator = DatabaseManager.getServerDatabaseAndOperator(serverUrl);
    final database = databaseAndOperator.database;
    final operator = databaseAndOperator.operator;

    final newSearch = TeamSearchHistory(
      createdAt: DateTime.now().millisecondsSinceEpoch,
      displayTerm: terms,
      term: terms,
      teamId: teamId,
    );

    final List<Model> models = [];
    final searchModels = await operator.handleTeamSearchHistory({
      'teamSearchHistories': [newSearch],
      'prepareRecordsOnly': true,
    });
    final searchModel = searchModels[0];

    models.add(searchModel);

    // Determine if need to delete the oldest entry
    if (searchModel.raw['_changed'] != 'created_at') {
      final teamSearchHistory = await queryTeamSearchHistoryByTeamId(database, teamId).fetch();
      if (teamSearchHistory.length > MAX_TEAM_SEARCHES) {
        final lastSearches = teamSearchHistory.sublist(MAX_TEAM_SEARCHES);
        for (final lastSearch in lastSearches) {
          models.add(lastSearch.prepareDestroyPermanently());
        }
      }
    }

    await operator.batchRecords(models, 'addSearchToTeamHistory');
    return {'searchModel': searchModel};
  } catch (error) {
    logError('Failed addSearchToTeamSearchHistory', error);
    return {'error': error};
  }
}

Future<Map<String, dynamic>> removeSearchFromTeamSearchHistory(String serverUrl, String id) async {
  try {
    final database = DatabaseManager.getServerDatabaseAndOperator(serverUrl).database;
    final teamSearch = await getTeamSearchHistoryById(database, id);
    if (teamSearch != null) {
      await database.write(() async {
        await teamSearch.destroyPermanently();
      });
    }
    return {'teamSearch': teamSearch};
  } catch (error) {
    logError('Failed removeSearchFromTeamSearchHistory', error);
    return {'error': error};
  }
}
