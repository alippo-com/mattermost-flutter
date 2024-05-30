// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:watermelondb/watermelondb.dart';
import 'package:mattermost_flutter/constants/database.dart';
import 'package:mattermost_flutter/database/operator/server_data_operator/comparators.dart';
import 'package:mattermost_flutter/database/operator/server_data_operator/transformers/team.dart';
import 'package:mattermost_flutter/database/operator/utils/general.dart';
import 'package:mattermost_flutter/utils/log.dart';
import 'package:mattermost_flutter/types/database/models/servers/my_team.dart';
import 'package:mattermost_flutter/types/database/models/servers/team_channel_history.dart';
import 'package:mattermost_flutter/types/database/models/servers/team_membership.dart';
import 'package:mattermost_flutter/types/database/models/servers/team_search_history.dart';

const {
  MY_TEAM,
  TEAM,
  TEAM_CHANNEL_HISTORY,
  TEAM_MEMBERSHIP,
  TEAM_SEARCH_HISTORY,
} = MM_TABLES_SERVER;

abstract class TeamHandlerMix {
  Future<List<TeamMembershipModel>> handleTeamMemberships({required List<TeamMembership> teamMemberships, bool prepareRecordsOnly = true});
  Future<List<TeamModel>> handleTeam({required List<Team> teams, bool prepareRecordsOnly = true});
  Future<List<TeamChannelHistoryModel>> handleTeamChannelHistory({required List<TeamChannelHistory> teamChannelHistories, bool prepareRecordsOnly = true});
  Future<List<TeamSearchHistoryModel>> handleTeamSearchHistory({required List<TeamSearchHistory> teamSearchHistories, bool prepareRecordsOnly = true});
  Future<List<MyTeamModel>> handleMyTeam({required List<MyTeam> myTeams, bool prepareRecordsOnly = true});
}

mixin TeamHandler<T extends ServerDataOperatorBase> on T implements TeamHandlerMix {
  @override
  Future<List<TeamMembershipModel>> handleTeamMemberships({required List<TeamMembership> teamMemberships, bool prepareRecordsOnly = true}) async {
    if (teamMemberships.isEmpty) {
      logWarning('An empty or undefined "teamMemberships" array has been passed to the handleTeamMemberships method');
      return [];
    }

    final memberships = teamMemberships.map((m) => m.copyWith(id: '${m.teamId}-${m.userId}')).toList();
    final uniqueRaws = getUniqueRawsBy<TeamMembership>(raws: memberships, key: 'id');
    final ids = uniqueRaws.map((t) => t.id!).toList();
    final db = database;
    final existing = await db.get<TeamMembershipModel>(TEAM_MEMBERSHIP).query(Q.where('id', Q.oneOf(ids))).fetch();
    final membershipMap = Map.fromEntries(existing.map((e) => MapEntry(e.id, e)));
    final createOrUpdateRawValues = uniqueRaws.where((t) {
      final e = membershipMap[t.id!];
      return (e == null && t.deleteAt == null) || (e != null && e.schemeAdmin != t.schemeAdmin);
    }).toList();

    if (createOrUpdateRawValues.isEmpty) {
      return [];
    }

    return handleRecords(
      fieldName: 'user_id',
      buildKeyRecordBy: buildTeamMembershipKey,
      transformer: transformTeamMembershipRecord,
      createOrUpdateRawValues,
      tableName: TEAM_MEMBERSHIP,
      prepareRecordsOnly: prepareRecordsOnly,
      methodName: 'handleTeamMemberships',
    );
  }

  @override
  Future<List<TeamModel>> handleTeam({required List<Team> teams, bool prepareRecordsOnly = true}) async {
    if (teams.isEmpty) {
      logWarning('An empty or undefined "teams" array has been passed to the handleTeam method');
      return [];
    }

    final uniqueRaws = getUniqueRawsBy<Team>(raws: teams, key: 'id');
    final ids = uniqueRaws.map((t) => t.id).toList();
    final db = database;
    final existing = await db.get<TeamModel>(TEAM).query(Q.where('id', Q.oneOf(ids))).fetch();
    final teamMap = Map.fromEntries(existing.map((e) => MapEntry(e.id, e)));
    final createOrUpdateRawValues = uniqueRaws.where((t) {
      final e = teamMap[t.id];
      return (e == null && t.deleteAt == null) || (e != null && e.updateAt != t.updateAt);
    }).toList();

    if (createOrUpdateRawValues.isEmpty) {
      return [];
    }

    return handleRecords(
      fieldName: 'id',
      transformer: transformTeamRecord,
      prepareRecordsOnly: prepareRecordsOnly,
      createOrUpdateRawValues: createOrUpdateRawValues,
      tableName: TEAM,
      methodName: 'handleTeam',
    );
  }

  @override
  Future<List<TeamChannelHistoryModel>> handleTeamChannelHistory({required List<TeamChannelHistory> teamChannelHistories, bool prepareRecordsOnly = true}) async {
    if (teamChannelHistories.isEmpty) {
      logWarning('An empty or undefined "teamChannelHistories" array has been passed to the handleTeamChannelHistory method');
      return [];
    }

    final createOrUpdateRawValues = getUniqueRawsBy<TeamChannelHistory>(raws: teamChannelHistories, key: 'id');

    return handleRecords(
      fieldName: 'id',
      transformer: transformTeamChannelHistoryRecord,
      prepareRecordsOnly: prepareRecordsOnly,
      createOrUpdateRawValues: createOrUpdateRawValues,
      tableName: TEAM_CHANNEL_HISTORY,
      methodName: 'handleTeamChannelHistory',
    );
  }

  @override
  Future<List<TeamSearchHistoryModel>> handleTeamSearchHistory({required List<TeamSearchHistory> teamSearchHistories, bool prepareRecordsOnly = true}) async {
    if (teamSearchHistories.isEmpty) {
      logWarning('An empty or undefined "teamSearchHistories" array has been passed to the handleTeamSearchHistory method');
      return [];
    }

    final createOrUpdateRawValues = getUniqueRawsBy<TeamSearchHistory>(raws: teamSearchHistories, key: 'term');

    return handleRecords(
      fieldName: 'team_id',
      buildKeyRecordBy: buildTeamSearchHistoryKey,
      transformer: transformTeamSearchHistoryRecord,
      prepareRecordsOnly: prepareRecordsOnly,
      createOrUpdateRawValues: createOrUpdateRawValues,
      tableName: TEAM_SEARCH_HISTORY,
      methodName: 'handleTeamSearchHistory',
    );
  }

  @override
  Future<List<MyTeamModel>> handleMyTeam({required List<MyTeam> myTeams, bool prepareRecordsOnly = true}) async {
    if (myTeams.isEmpty) {
      logWarning('An empty or undefined "myTeams" array has been passed to the handleMyTeam method');
      return [];
    }

    final uniqueRaws = getUniqueRawsBy<MyTeam>(raws: myTeams, key: 'id');
    final ids = uniqueRaws.map((t) => t.id).toList();
    final db = database;
    final existing = await db.get<MyTeamModel>(MY_TEAM).query(Q.where('id', Q.oneOf(ids))).fetch();
    final myTeamMap = Map.fromEntries(existing.map((e) => MapEntry(e.id, e)));
    final createOrUpdateRawValues = uniqueRaws.where((mt) {
      final e = myTeamMap[mt.id!];
      return (e == null) || (e != null && e.roles != mt.roles);
    }).toList();

    if (createOrUpdateRawValues.isEmpty) {
      return [];
    }

    return handleRecords(
      fieldName: 'id',
      transformer: transformMyTeamRecord,
      prepareRecordsOnly: prepareRecordsOnly,
      createOrUpdateRawValues: createOrUpdateRawValues,
      tableName: MY_TEAM,
      methodName: 'handleMyTeam',
    );
  }
}
