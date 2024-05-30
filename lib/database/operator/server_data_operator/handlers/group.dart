
import 'package:mattermost_flutter/constants/database.dart';
import 'package:mattermost_flutter/database/operator/server_data_operator/transformers/group.dart';
import 'package:mattermost_flutter/queries/servers/group.dart';
import 'package:mattermost_flutter/utils/groups.dart';
import 'package:mattermost_flutter/utils/log.dart';
import 'package:mattermost_flutter/types/database/models/servers/group.dart';
import 'package:mattermost_flutter/types/database/models/servers/group_channel.dart';
import 'package:mattermost_flutter/types/database/models/servers/group_membership.dart';
import 'package:mattermost_flutter/types/database/models/servers/group_team.dart';

const GROUP = MM_TABLES.SERVER.GROUP;
const GROUP_CHANNEL = MM_TABLES.SERVER.GROUP_CHANNEL;
const GROUP_MEMBERSHIP = MM_TABLES.SERVER.GROUP_MEMBERSHIP;
const GROUP_TEAM = MM_TABLES.SERVER.GROUP_TEAM;

mixin GroupHandlerMix {
  Future<List<GroupModel>> handleGroups({
    required List<GroupModel> groups,
    bool prepareRecordsOnly = true,
  });

  Future<List<GroupChannelModel>> handleGroupChannelsForChannel({
    required String channelId,
    required List<GroupModel> groups,
    bool prepareRecordsOnly = true,
  });

  Future<List<GroupMembershipModel>> handleGroupMembershipsForMember({
    required String userId,
    required List<GroupModel> groups,
    bool prepareRecordsOnly = true,
  });

  Future<List<GroupTeamModel>> handleGroupTeamsForTeam({
    required String teamId,
    required List<GroupModel> groups,
    bool prepareRecordsOnly = true,
  });
}

mixin GroupHandler<TBase extends ServerDataOperatorBase> on TBase implements GroupHandlerMix {
  @override
  Future<List<GroupModel>> handleGroups({
    required List<GroupModel> groups,
    bool prepareRecordsOnly = true,
  }) async {
    if (groups.isEmpty) {
      logWarning(
        'An empty or undefined "groups" array has been passed to the handleGroups method',
      );
      return [];
    }

    final createOrUpdateRawValues = getUniqueRawsBy(groups, 'id');

    return this.handleRecords(
      fieldName: 'id',
      transformer: transformGroupRecord,
      createOrUpdateRawValues: createOrUpdateRawValues,
      tableName: GROUP,
      prepareRecordsOnly: prepareRecordsOnly,
      functionName: 'handleGroups',
    );
  }

  @override
  Future<List<GroupChannelModel>> handleGroupChannelsForChannel({
    required String channelId,
    required List<GroupModel> groups,
    bool prepareRecordsOnly = true,
  }) async {
    final existingGroupChannels = await queryGroupChannelForChannel(this.database, channelId).fetch();

    List<GroupChannelModel> records = [];
    List<GroupChannel> rawValues = [];

    if (groups.isEmpty && existingGroupChannels.isEmpty) {
      return records;
    } else if (groups.isEmpty && existingGroupChannels.isNotEmpty) {
      records = existingGroupChannels.map((gt) => gt.prepareDestroyPermanently()).toList();
    } else if (groups.isNotEmpty && existingGroupChannels.isEmpty) {
      rawValues = groups.map((g) => GroupChannel(id: generateGroupAssociationId(g.id, channelId), channelId: channelId, groupId: g.id)).toList();
    } else if (groups.isNotEmpty && existingGroupChannels.isNotEmpty) {
      final groupsSet = <String, GroupChannel>{};

      for (final g in groups) {
        groupsSet[g.id] = GroupChannel(id: generateGroupAssociationId(g.id, channelId), channelId: channelId, groupId: g.id);
      }

      for (final gt in existingGroupChannels) {
        if (groupsSet.containsKey(gt.groupId)) {
          groupsSet.remove(gt.groupId);
        } else {
          records.add(gt.prepareDestroyPermanently());
        }
      }

      rawValues.addAll(groupsSet.values);
    }

    records.addAll(await this.handleRecords(
      fieldName: 'id',
      transformer: transformGroupChannelRecord,
      createOrUpdateRawValues: rawValues,
      tableName: GROUP_CHANNEL,
      prepareRecordsOnly: true,
      functionName: 'handleGroupChannelsForChannel',
    ));

    if (records.isNotEmpty && !prepareRecordsOnly) {
      await this.batchRecords(records, 'handleGroupChannelsForChannel');
    }

    return records;
  }

  @override
  Future<List<GroupMembershipModel>> handleGroupMembershipsForMember({
    required String userId,
    required List<GroupModel> groups,
    bool prepareRecordsOnly = true,
  }) async {
    final existingGroupMemberships = await queryGroupMembershipForMember(this.database, userId).fetch();

    List<GroupMembershipModel> records = [];
    List<GroupMembership> rawValues = [];

    if (groups.isEmpty && existingGroupMemberships.isEmpty) {
      return records;
    } else if (groups.isEmpty && existingGroupMemberships.isNotEmpty) {
      records = existingGroupMemberships.map((gm) => gm.prepareDestroyPermanently()).toList();
    } else if (groups.isNotEmpty && existingGroupMemberships.isEmpty) {
      rawValues = groups.map((g) => GroupMembership(id: generateGroupAssociationId(g.id, userId), userId: userId, groupId: g.id)).toList();
    } else if (groups.isNotEmpty && existingGroupMemberships.isNotEmpty) {
      final groupsSet = <String, GroupMembership>{};

      for (final g in groups) {
        groupsSet[g.id] = GroupMembership(id: generateGroupAssociationId(g.id, userId), userId: userId, groupId: g.id);
      }

      for (final gm in existingGroupMemberships) {
        if (groupsSet.containsKey(gm.groupId)) {
          groupsSet.remove(gm.groupId);
        } else {
          records.add(gm.prepareDestroyPermanently());
        }
      }

      rawValues.addAll(groupsSet.values);
    }

    if (rawValues.isNotEmpty) {
      records.addAll(await this.handleRecords(
        fieldName: 'id',
        transformer: transformGroupMembershipRecord,
        createOrUpdateRawValues: rawValues,
        tableName: GROUP_MEMBERSHIP,
        prepareRecordsOnly: true,
        functionName: 'handleGroupMembershipsForMember',
      ));
    }

    if (records.isNotEmpty && !prepareRecordsOnly) {
      await this.batchRecords(records, 'handleGroupMembershipsForMember');
    }

    return records;
  }

  @override
  Future<List<GroupTeamModel>> handleGroupTeamsForTeam({
    required String teamId,
    required List<GroupModel> groups,
    bool prepareRecordsOnly = true,
  }) async {
    final existingGroupTeams = await queryGroupTeamForTeam(this.database, teamId).fetch();

    List<GroupTeamModel> records = [];
    List<GroupTeam> rawValues = [];

    if (groups.isEmpty && existingGroupTeams.isEmpty) {
      return records;
    } else if (groups.isEmpty && existingGroupTeams.isNotEmpty) {
      records = existingGroupTeams.map((gt) => gt.prepareDestroyPermanently()).toList();
    } else if (groups.isNotEmpty && existingGroupTeams.isEmpty) {
      rawValues = groups.map((g) => GroupTeam(id: generateGroupAssociationId(g.id, teamId), teamId: teamId, groupId: g.id)).toList();
    } else if (groups.isNotEmpty && existingGroupTeams.isNotEmpty) {
      final groupsSet = <String, GroupTeam>{};

      for (final g in groups) {
        groupsSet[g.id] = GroupTeam(id: generateGroupAssociationId(g.id, teamId), teamId: teamId, groupId: g.id);
      }

      for (final gt in existingGroupTeams) {
        if (groupsSet.containsKey(gt.groupId)) {
          groupsSet.remove(gt.groupId);
        } else {
          records.add(gt.prepareDestroyPermanently());
        }
      }

      rawValues.addAll(groupsSet.values);
    }

    records.addAll(await this.handleRecords(
      fieldName: 'id',
      transformer: transformGroupTeamRecord,
      createOrUpdateRawValues: rawValues,
      tableName: GROUP_TEAM,
      prepareRecordsOnly: true,
      functionName: 'handleGroupTeamsForTeam',
    ));

    if (records.isNotEmpty && !prepareRecordsOnly) {
      await this.batchRecords(records, 'handleGroupTeamsForTeam');
    }

    return records;
  }
}
