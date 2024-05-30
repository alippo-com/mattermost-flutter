import 'package:mattermost_flutter/constants/database.dart';
import 'package:mattermost_flutter/utils/log.dart';
import 'package:mattermost_flutter/types/database/models/servers/channel.dart';
import 'package:mattermost_flutter/types/database/models/servers/channel_info.dart';
import 'package:mattermost_flutter/types/database/models/servers/channel_membership.dart';
import 'package:mattermost_flutter/types/database/models/servers/my_channel.dart';
import 'package:mattermost_flutter/types/database/models/servers/my_channel_settings.dart';

const CHANNEL = MM_TABLES.SERVER.CHANNEL;
const CHANNEL_INFO = MM_TABLES.SERVER.CHANNEL_INFO;
const CHANNEL_MEMBERSHIP = MM_TABLES.SERVER.CHANNEL_MEMBERSHIP;
const MY_CHANNEL = MM_TABLES.SERVER.MY_CHANNEL;
const MY_CHANNEL_SETTINGS = MM_TABLES.SERVER.MY_CHANNEL_SETTINGS;

mixin ChannelHandlerMix {
  Future<List<ChannelModel>> handleChannel({
    required List<ChannelModel> channels,
    bool prepareRecordsOnly = true,
  });

  Future<List<ChannelMembershipModel>> handleChannelMembership({
    required List<ChannelMembershipModel> channelMemberships,
    bool prepareRecordsOnly = true,
  });

  Future<List<MyChannelSettingsModel>> handleMyChannelSettings({
    required List<MyChannelSettingsModel> settings,
    bool prepareRecordsOnly = true,
  });

  Future<List<ChannelInfoModel>> handleChannelInfo({
    required List<ChannelInfoModel> channelInfos,
    bool prepareRecordsOnly = true,
  });

  Future<List<MyChannelModel>> handleMyChannel({
    required List<ChannelModel> channels,
    required List<MyChannelModel> myChannels,
    required bool isCRTEnabled,
    bool prepareRecordsOnly = true,
  });
}

mixin ChannelHandler<TBase extends ServerDataOperatorBase> on TBase implements ChannelHandlerMix {
  @override
  Future<List<ChannelModel>> handleChannel({
    required List<ChannelModel> channels,
    bool prepareRecordsOnly = true,
  }) async {
    if (channels.isEmpty) {
      logWarning('An empty or undefined "channels" array has been passed to the handleChannel method');
      return [];
    }

    final uniqueRaws = getUniqueRawsBy(channels, 'id');
    final keys = uniqueRaws.map((c) => c.id).toList();
    final db = this.database;
    final existing = await db.get<ChannelModel>(CHANNEL).query(Q.where('id', Q.oneOf(keys))).fetch();
    final channelMap = {for (var c in existing) c.id: c};
    final createOrUpdateRawValues = uniqueRaws.where((c) {
      final e = channelMap[c.id];
      return e == null || e.updateAt != c.updateAt || e.deleteAt != c.deleteAt || c.fake;
    }).toList();

    if (createOrUpdateRawValues.isEmpty) {
      return [];
    }

    return this.handleRecords(
      fieldName: 'id',
      transformer: transformChannelRecord,
      prepareRecordsOnly: prepareRecordsOnly,
      createOrUpdateRawValues: createOrUpdateRawValues,
      tableName: CHANNEL,
      functionName: 'handleChannel',
    );
  }

  @override
  Future<List<MyChannelSettingsModel>> handleMyChannelSettings({
    required List<MyChannelSettingsModel> settings,
    bool prepareRecordsOnly = true,
  }) async {
    if (settings.isEmpty) {
      logWarning('An empty or undefined "settings" array has been passed to the handleMyChannelSettings method');
      return [];
    }

    final uniqueRaws = getUniqueRawsBy(settings, 'id');
    final keys = uniqueRaws.map((c) => c.channelId).toList();
    final db = this.database;
    final existing = await db.get<MyChannelSettingsModel>(MY_CHANNEL_SETTINGS).query(Q.where('id', Q.oneOf(keys))).fetch();
    final channelMap = {for (var c in existing) c.id: c};
    final createOrUpdateRawValues = uniqueRaws.where((c) {
      final e = channelMap[c.channelId];
      if (e == null) {
        return true;
      }
      final current = jsonEncode(e.notifyProps);
      final newer = jsonEncode(c.notifyProps);
      return current != newer;
    }).toList();

    if (createOrUpdateRawValues.isEmpty) {
      return [];
    }

    return this.handleRecords(
      fieldName: 'id',
      buildKeyRecordBy: buildMyChannelKey,
      transformer: transformMyChannelSettingsRecord,
      prepareRecordsOnly: prepareRecordsOnly,
      createOrUpdateRawValues: createOrUpdateRawValues,
      tableName: MY_CHANNEL_SETTINGS,
      functionName: 'handleMyChannelSettings',
    );
  }

  @override
  Future<List<ChannelInfoModel>> handleChannelInfo({
    required List<ChannelInfoModel> channelInfos,
    bool prepareRecordsOnly = true,
  }) async {
    if (channelInfos.isEmpty) {
      logWarning('An empty "channelInfos" array has been passed to the handleMyChannelSettings method');
      return [];
    }

    final uniqueRaws = getUniqueRawsBy(channelInfos, 'id');
    final keys = uniqueRaws.map((ci) => ci.id).toList();
    final db = this.database;
    final existing = await db.get<ChannelInfoModel>(CHANNEL_INFO).query(Q.where('id', Q.oneOf(keys))).fetch();
    final channelMap = {for (var ci in existing) ci.id: ci};
    final createOrUpdateRawValues = uniqueRaws.where((ci) {
      final e = channelMap[ci.id];
      return e == null || ci.guestCount != e.guestCount || ci.memberCount != e.memberCount || ci.header != e.header || ci.pinnedPostCount != e.pinnedPostCount || ci.filesCount != e.filesCount || ci.purpose != e.purpose;
    }).toList();

    if (createOrUpdateRawValues.isEmpty) {
      return [];
    }

    return this.handleRecords(
      fieldName: 'id',
      transformer: transformChannelInfoRecord,
      prepareRecordsOnly: prepareRecordsOnly,
      createOrUpdateRawValues: createOrUpdateRawValues,
      tableName: CHANNEL_INFO,
      functionName: 'handleChannelInfo',
    );
  }

  @override
  Future<List<MyChannelModel>> handleMyChannel({
    required List<ChannelModel> channels,
    required List<MyChannelModel> myChannels,
    required bool isCRTEnabled,
    bool prepareRecordsOnly = true,
  }) async {
    if (myChannels.isEmpty) {
      logWarning('An empty or undefined "myChannels" array has been passed to the handleMyChannel method');
      return [];
    }

    if (channels.isEmpty) {
      logWarning('An empty or undefined "channels" array has been passed to the handleMyChannel method');
      return [];
    }

    final isCRT = isCRTEnabled ?? await getIsCRTEnabled(this.database);

    final channelMap = {for (var channel in channels) channel.id: channel};
    for (var my in myChannels) {
      final channel = channelMap[my.channelId];
      if (channel != null) {
        final totalMsg = isCRT ? channel.totalMsgCountRoot : channel.totalMsgCount;
        final myMsgCount = isCRT ? my.msgCountRoot : my.msgCount;
        final msgCount = (totalMsg - myMsgCount).clamp(0, double.infinity).toInt();
        final lastPostAt = isCRT ? (channel.lastRootPostAt ?? channel.lastPostAt) : channel.lastPostAt;
        my.msgCount = msgCount;
        my.mentionCount = isCRT ? my.mentionCountRoot : my.mentionCount;
        my.isUnread = msgCount > 0;
        my.lastPostAt = lastPostAt;
      }
    }

    final uniqueRaws = getUniqueRawsBy(myChannels, 'id');
    final ids = uniqueRaws.map((cm) => cm.channelId).toList();
    final db = this.database;
    final existing = await db.get<MyChannelModel>(MY_CHANNEL).query(Q.where('id', Q.oneOf(ids))).fetch();
    final membershipMap = {for (var member in existing) member.id: member};
    final createOrUpdateRawValues = uniqueRaws.where((my) {
      final e = membershipMap[my.channelId];
      if (e == null) {
        return true;
      }
      final chan = channelMap[my.channelId];
      final lastPostAt = isCRT ? (chan.lastRootPostAt ?? chan.lastPostAt) : chan.lastPostAt;
      return chan != null && (e.lastPostAt < lastPostAt || e.isUnread != my.isUnread || e.lastViewedAt < my.lastViewedAt || e.roles != my.roles);
    }).toList();

    if (createOrUpdateRawValues.isEmpty) {
      return [];
    }

    return this.handleRecords(
      fieldName: 'id',
      buildKeyRecordBy: buildMyChannelKey,
      transformer: transformMyChannelRecord,
      prepareRecordsOnly: prepareRecordsOnly,
      createOrUpdateRawValues: createOrUpdateRawValues,
      tableName: MY_CHANNEL,
      functionName: 'handleMyChannel',
    );
  }

  @override
  Future<List<ChannelMembershipModel>> handleChannelMembership({
    required List<ChannelMembershipModel> channelMemberships,
    bool prepareRecordsOnly = true,
  }) async {
    if (channelMemberships.isEmpty) {
      logWarning('An empty "channelMemberships" array has been passed to the handleChannelMembership method');
      return [];
    }

    final memberships = channelMemberships.map((m) => m.copyWith(id: '${m.channelId}-${m.userId}')).toList();
    final uniqueRaws = getUniqueRawsBy(memberships, 'id');
    final ids = uniqueRaws.map((cm) => '${cm.channelId}-${cm.userId}').toList();
    final db = this.database;
    final existing = await db.get<ChannelMembershipModel>(CHANNEL_MEMBERSHIP).query(Q.where('id', Q.oneOf(ids))).fetch();
    final membershipMap = {for (var member in existing) member.channelId: member};
    final createOrUpdateRawValues = uniqueRaws.where((cm) {
      final e = membershipMap[cm.channelId];
      return e == null || cm.schemeAdmin != e.schemeAdmin;
    }).toList();

    if (createOrUpdateRawValues.isEmpty) {
      return [];
    }

    return this.handleRecords(
      fieldName: 'userId',
      buildKeyRecordBy: buildChannelMembershipKey,
      transformer: transformChannelMembershipRecord,
      prepareRecordsOnly: prepareRecordsOnly,
      createOrUpdateRawValues: createOrUpdateRawValues,
      tableName: CHANNEL_MEMBERSHIP,
      functionName: 'handleChannelMembership',
    );
  }
}
