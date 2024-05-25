// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:mattermost_flutter/constants/database.dart';
import 'package:mattermost_flutter/database/transformers/index.dart';
import 'package:mattermost_flutter/utils/groups.dart';
import 'package:mattermost_flutter/types/transformer_args.dart';
import 'package:mattermost_flutter/types/group_model.dart';
import 'package:mattermost_flutter/types/group_channel_model.dart';
import 'package:mattermost_flutter/types/group_membership_model.dart';
import 'package:mattermost_flutter/types/group_team_model.dart';

class GroupTransformers {
  static Future<GroupModel> transformGroupRecord(TransformerArgs args) async {
    final raw = args.value.raw as Group;
    final record = args.value.record as GroupModel;
    final isCreateAction = args.action == OperationType.CREATE;

    void fieldsMapper(GroupModel group) {
      group.raw.id = isCreateAction ? (raw?.id ?? group.id) : record.id;
      group.name = raw.name;
      group.displayName = raw.displayName;
      group.source = raw.source;
      group.remoteId = raw.remoteId;
      group.memberCount = raw.memberCount ?? 0;
    }

    return prepareBaseRecord(
      action: args.action,
      database: args.database,
      tableName: MM_TABLES.SERVER.GROUP,
      value: args.value,
      fieldsMapper: fieldsMapper,
    ) as Future<GroupModel>;
  }

  static Future<GroupChannelModel> transformGroupChannelRecord(TransformerArgs args) async {
    final raw = args.value.raw as GroupChannel;

    void fieldsMapper(GroupChannelModel model) {
      model.raw.id = raw.id ?? generateGroupAssociationId(raw.groupId, raw.channelId);
      model.groupId = raw.groupId;
      model.channelId = raw.channelId;
    }

    return prepareBaseRecord(
      action: args.action,
      database: args.database,
      tableName: MM_TABLES.SERVER.GROUP_CHANNEL,
      value: args.value,
      fieldsMapper: fieldsMapper,
    ) as Future<GroupChannelModel>;
  }

  static Future<GroupMembershipModel> transformGroupMembershipRecord(TransformerArgs args) async {
    final raw = args.value.raw as GroupMembership;

    void fieldsMapper(GroupMembershipModel model) {
      model.raw.id = raw.id ?? generateGroupAssociationId(raw.groupId, raw.userId);
      model.groupId = raw.groupId;
      model.userId = raw.userId;
    }

    return prepareBaseRecord(
      action: args.action,
      database: args.database,
      tableName: MM_TABLES.SERVER.GROUP_MEMBERSHIP,
      value: args.value,
      fieldsMapper: fieldsMapper,
    ) as Future<GroupMembershipModel>;
  }

  static Future<GroupTeamModel> transformGroupTeamRecord(TransformerArgs args) async {
    final raw = args.value.raw as GroupTeam;

    void fieldsMapper(GroupTeamModel model) {
      model.raw.id = raw.id ?? generateGroupAssociationId(raw.groupId, raw.teamId);
      model.groupId = raw.groupId;
      model.teamId = raw.teamId;
    }

    return prepareBaseRecord(
      action: args.action,
      database: args.database,
      tableName: MM_TABLES.SERVER.GROUP_TEAM,
      value: args.value,
      fieldsMapper: fieldsMapper,
    ) as Future<GroupTeamModel>;
  }
}
