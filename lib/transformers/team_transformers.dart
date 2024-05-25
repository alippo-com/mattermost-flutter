// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:mattermost_flutter/constants/database.dart';
import 'package:mattermost_flutter/database/transformers/index.dart';
import 'package:mattermost_flutter/types/transformer_args.dart';
import 'package:mattermost_flutter/types/my_team_model.dart';
import 'package:mattermost_flutter/types/team_model.dart';
import 'package:mattermost_flutter/types/team_channel_history_model.dart';
import 'package:mattermost_flutter/types/team_membership_model.dart';
import 'package:mattermost_flutter/types/team_search_history_model.dart';

class TeamTransformers {
  static Future<TeamMembershipModel> transformTeamMembershipRecord(TransformerArgs args) async {
    final raw = args.value.raw as TeamMembership;
    final record = args.value.record as TeamMembershipModel;
    final isCreateAction = args.action == OperationType.CREATE;

    void fieldsMapper(TeamMembershipModel teamMembership) {
      teamMembership.raw.id = isCreateAction ? (raw?.id ?? teamMembership.id) : record.id;
      teamMembership.teamId = raw.teamId;
      teamMembership.userId = raw.userId;
      teamMembership.schemeAdmin = raw.schemeAdmin;
    }

    return prepareBaseRecord(
      action: args.action,
      database: args.database,
      tableName: MM_TABLES.SERVER.TEAM_MEMBERSHIP,
      value: args.value,
      fieldsMapper: fieldsMapper,
    ) as Future<TeamMembershipModel>;
  }

  static Future<TeamModel> transformTeamRecord(TransformerArgs args) async {
    final raw = args.value.raw as Team;
    final record = args.value.record as TeamModel;
    final isCreateAction = args.action == OperationType.CREATE;

    void fieldsMapper(TeamModel team) {
      team.raw.id = isCreateAction ? (raw?.id ?? team.id) : record.id;
      team.isAllowOpenInvite = raw.allowOpenInvite;
      team.description = raw.description;
      team.displayName = raw.displayName;
      team.name = raw.name;
      team.updateAt = raw.updateAt;
      team.type = raw.type;
      team.allowedDomains = raw.allowedDomains;
      team.isGroupConstrained = raw.groupConstrained;
      team.lastTeamIconUpdatedAt = raw.lastTeamIconUpdatedAt;
      team.inviteId = raw.inviteId;
    }

    return prepareBaseRecord(
      action: args.action,
      database: args.database,
      tableName: MM_TABLES.SERVER.TEAM,
      value: args.value,
      fieldsMapper: fieldsMapper,
    ) as Future<TeamModel>;
  }

  static Future<TeamChannelHistoryModel> transformTeamChannelHistoryRecord(TransformerArgs args) async {
    final raw = args.value.raw as TeamChannelHistory;
    final record = args.value.record as TeamChannelHistoryModel;
    final isCreateAction = args.action == OperationType.CREATE;

    void fieldsMapper(TeamChannelHistoryModel teamChannelHistory) {
      teamChannelHistory.raw.id = isCreateAction ? (raw.id ?? teamChannelHistory.id) : record.id;
      teamChannelHistory.channelIds = raw.channelIds;
    }

    return prepareBaseRecord(
      action: args.action,
      database: args.database,
      tableName: MM_TABLES.SERVER.TEAM_CHANNEL_HISTORY,
      value: args.value,
      fieldsMapper: fieldsMapper,
    ) as Future<TeamChannelHistoryModel>;
  }

  static Future<TeamSearchHistoryModel> transformTeamSearchHistoryRecord(TransformerArgs args) async {
    final raw = args.value.raw as TeamSearchHistory;
    final record = args.value.record as TeamSearchHistoryModel;
    final isCreateAction = args.action == OperationType.CREATE;

    void fieldsMapper(TeamSearchHistoryModel teamSearchHistory) {
      teamSearchHistory.raw.id = isCreateAction ? (teamSearchHistory.id) : record.id;
      teamSearchHistory.createdAt = raw.createdAt;
      teamSearchHistory.displayTerm = raw.displayTerm;
      teamSearchHistory.term = raw.term;
      teamSearchHistory.teamId = raw.teamId;
    }

    return prepareBaseRecord(
      action: args.action,
      database: args.database,
      tableName: MM_TABLES.SERVER.TEAM_SEARCH_HISTORY,
      value: args.value,
      fieldsMapper: fieldsMapper,
    ) as Future<TeamSearchHistoryModel>;
  }

  static Future<MyTeamModel> transformMyTeamRecord(TransformerArgs args) async {
    final raw = args.value.raw as MyTeam;
    final record = args.value.record as MyTeamModel;
    final isCreateAction = args.action == OperationType.CREATE;

    void fieldsMapper(MyTeamModel myTeam) {
      myTeam.raw.id = isCreateAction ? (raw.id ?? myTeam.id) : record.id;
      myTeam.roles = raw.roles;
    }

    return prepareBaseRecord(
      action: args.action,
      database: args.database,
      tableName: MM_TABLES.SERVER.MY_TEAM,
      value: args.value,
      fieldsMapper: fieldsMapper,
    ) as Future<MyTeamModel>;
  }
}
