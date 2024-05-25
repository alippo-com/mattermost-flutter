// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

enum ChannelType { O, P, D, G }

class ChannelStats {
  final String channelId;
  final int guestCount;
  final int memberCount;
  final int pinnedPostCount;
  final int filesCount;

  ChannelStats({
    required this.channelId,
    required this.guestCount,
    required this.memberCount,
    required this.pinnedPostCount,
    required this.filesCount,
  });
}

enum NotificationLevel { defaultLevel, all, mention, none }

class ChannelNotifyProps {
  final NotificationLevel desktop;
  final NotificationLevel email;
  final String markUnread;
  final NotificationLevel push;
  final String ignoreChannelMentions;
  final String channelAutoFollowThreads;
  final String pushThreads;

  ChannelNotifyProps({
    required this.desktop,
    required this.email,
    required this.markUnread,
    required this.push,
    required this.ignoreChannelMentions,
    required this.channelAutoFollowThreads,
    required this.pushThreads,
  });
}

class Channel {
  final String id;
  final int createAt;
  final int updateAt;
  final int deleteAt;
  final String teamId;
  final ChannelType type;
  final String displayName;
  final String name;
  final String header;
  final String purpose;
  final int lastPostAt;
  final int? lastRootPostAt;
  final int totalMsgCount;
  final int? totalMsgCountRoot;
  final int extraUpdateAt;
  final String creatorId;
  final String? schemeId;
  final bool? isCurrent;
  final String? teammateId;
  final String? status;
  final bool? fake;
  final bool? groupConstrained;
  final bool shared;

  Channel({
    required this.id,
    required this.createAt,
    required this.updateAt,
    required this.deleteAt,
    required this.teamId,
    required this.type,
    required this.displayName,
    required this.name,
    required this.header,
    required this.purpose,
    required this.lastPostAt,
    this.lastRootPostAt,
    required this.totalMsgCount,
    this.totalMsgCountRoot,
    required this.extraUpdateAt,
    required this.creatorId,
    this.schemeId,
    this.isCurrent,
    this.teammateId,
    this.status,
    this.fake,
    this.groupConstrained,
    required this.shared,
  });
}

class ChannelPatch {
  final String? name;
  final String? displayName;
  final String? header;
  final String? purpose;
  final bool? groupConstrained;

  ChannelPatch({
    this.name,
    this.displayName,
    this.header,
    this.purpose,
    this.groupConstrained,
  });
}

class ChannelWithTeamData extends Channel {
  final String teamDisplayName;
  final String teamName;
  final int teamUpdateAt;

  ChannelWithTeamData({
    required String id,
    required int createAt,
    required int updateAt,
    required int deleteAt,
    required String teamId,
    required ChannelType type,
    required String displayName,
    required String name,
    required String header,
    required String purpose,
    required int lastPostAt,
    int? lastRootPostAt,
    required int totalMsgCount,
    int? totalMsgCountRoot,
    required int extraUpdateAt,
    required String creatorId,
    String? schemeId,
    bool? isCurrent,
    String? teammateId,
    String? status,
    bool? fake,
    bool? groupConstrained,
    required bool shared,
    required this.teamDisplayName,
    required this.teamName,
    required this.teamUpdateAt,
  }) : super(
    id: id,
    createAt: createAt,
    updateAt: updateAt,
    deleteAt: deleteAt,
    teamId: teamId,
    type: type,
    displayName: displayName,
    name: name,
    header: header,
    purpose: purpose,
    lastPostAt: lastPostAt,
    lastRootPostAt: lastRootPostAt,
    totalMsgCount: totalMsgCount,
    totalMsgCountRoot: totalMsgCountRoot,
    extraUpdateAt: extraUpdateAt,
    creatorId: creatorId,
    schemeId: schemeId,
    isCurrent: isCurrent,
    teammateId: teammateId,
    status: status,
    fake: fake,
    groupConstrained: groupConstrained,
    shared: shared,
  );
}

class ChannelMember {
  final String? id;
  final String channelId;
  final String userId;
  final bool? schemeAdmin;

  ChannelMember({
    this.id,
    required this.channelId,
    required this.userId,
    this.schemeAdmin,
  });
}

class ChannelMembership {
  final String? id;
  final String channelId;
  final String userId;
  final String roles;
  final int lastViewedAt;
  final int msgCount;
  final int? msgCountRoot;
  final int mentionCount;
  final int? mentionCountRoot;
  final ChannelNotifyProps notifyProps;
  final int? lastPostAt;
  final int? lastRootPostAt;
  final int lastUpdateAt;
  final bool? schemeUser;
  final bool? schemeAdmin;
  final String? postRootId;
  final bool? isUnread;
  final bool? manuallyUnread;

  ChannelMembership({
    this.id,
    required this.channelId,
    required this.userId,
    required this.roles,
    required this.lastViewedAt,
    required this.msgCount,
    this.msgCountRoot,
    required this.mentionCount,
    this.mentionCountRoot,
    required this.notifyProps,
    this.lastPostAt,
    this.lastRootPostAt,
    required this.lastUpdateAt,
    this.schemeUser,
    this.schemeAdmin,
    this.postRootId,
    this.isUnread,
    this.manuallyUnread,
  });
}

class ChannelUnread {
  final String channelId;
  final String userId;
  final String teamId;
  final int msgCount;
  final int mentionCount;
  final int lastViewedAt;
  final int deltaMsgs;

  ChannelUnread({
    required this.channelId,
    required this.userId,
    required this.teamId,
    required this.msgCount,
    required this.mentionCount,
    required this.lastViewedAt,
    required this.deltaMsgs,
  });
}

class ChannelModeration {
  final String name;
  final Map<String, bool> roles;

  ChannelModeration({
    required this.name,
    required this.roles,
  });
}

class ChannelModerationPatch {
  final String name;
  final Map<String, bool> roles;

  ChannelModerationPatch({
    required this.name,
    required this.roles,
  });
}

class ChannelMemberCountByGroup {
  final String groupId;
  final int channelMemberCount;
  final int channelMemberTimezonesCount;

  ChannelMemberCountByGroup({
    required this.groupId,
    required this.channelMemberCount,
    required this.channelMemberTimezonesCount,
  });
}

typedef ChannelMemberCountsByGroup = Map<String, ChannelMemberCountByGroup>;