// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:mattermost_flutter/constants/general.dart';
import 'package:mattermost_flutter/constants/preferences.dart';
import 'package:mattermost_flutter/constants/categories.dart';
import 'package:mattermost_flutter/helpers/api/preference.dart';
import 'package:mattermost_flutter/utils/channel.dart';
import 'package:mattermost_flutter/utils/user.dart';
import 'package:mattermost_flutter/types/channel.dart';
import 'package:mattermost_flutter/types/my_channel.dart';
import 'package:mattermost_flutter/types/preference.dart';
import 'package:mattermost_flutter/types/user.dart';

class ChannelWithMyChannel {
  final Channel channel;
  final MyChannel myChannel;
  final int sortOrder;

  ChannelWithMyChannel({
    required this.channel,
    required this.myChannel,
    required this.sortOrder,
  });
}

String makeCategoryChannelId(String teamId, String channelId) {
  return '${teamId}_$channelId';
}

bool isUnreadChannel(MyChannel myChannel, {Map<String, dynamic>? notifyProps, String? lastUnreadChannelId}) {
  final isMuted = notifyProps?['mark_unread'] == General.MENTION;
  return myChannel.mentionsCount > 0 || (!isMuted && myChannel.isUnread) || (myChannel.id == lastUnreadChannelId);
}

List<ChannelWithMyChannel> filterArchivedChannels(List<ChannelWithMyChannel> channelsWithMyChannel, String currentChannelId) {
  return channelsWithMyChannel.where((cwm) => cwm.channel.deleteAt == 0 || cwm.channel.id == currentChannelId).toList();
}

List<ChannelWithMyChannel> filterAutoclosedDMs(
    String categoryType,
    int limit,
    String currentUserId,
    String currentChannelId,
    List<ChannelWithMyChannel> channelsWithMyChannel,
    List<Preference> preferences,
    Map<String, Map<String, dynamic>> notifyPropsPerChannel, {
      Map<String, User>? deactivatedUsers,
      String? lastUnreadChannelId,
    }) {
  if (categoryType != DMS_CATEGORY) {
    return channelsWithMyChannel;
  }

  final prefMap = Map<String, int>();
  for (var v in preferences) {
    final existing = prefMap[v.name] ?? 0;
    prefMap[v.name] = (v.value as int? ?? 0).compareTo(existing);
  }

  int getLastViewedAt(ChannelWithMyChannel cwm) {
    final id = cwm.channel.id;
    return cwm.myChannel.lastViewedAt.compareTo(prefMap[id] ?? 0);
  }

  int unreadCount = 0;
  var visibleChannels = channelsWithMyChannel.where((cwm) {
    final channel = cwm.channel;
    final myChannel = cwm.myChannel;

    if (myChannel.isUnread) {
      unreadCount++;
      return true;
    }

    if (channel.id == currentChannelId) {
      return true;
    }

    final lastViewedAt = getLastViewedAt(cwm);

    if (channel.type == General.DM_CHANNEL) {
      final teammateId = getUserIdFromChannelName(currentUserId, channel.name);
      final teammate = deactivatedUsers?[teammateId];
      if (teammate != null && teammate.deleteAt > lastViewedAt) {
        return false;
      }
    }

    if (isDMorGM(channel) && lastViewedAt == 0) {
      return false;
    }

    return true;
  }).toList();

  visibleChannels.sort((cwmA, cwmB) {
    final channelA = cwmA.channel;
    final channelB = cwmB.channel;
    final myChannelA = cwmA.myChannel;
    final myChannelB = cwmB.myChannel;

    if (channelA.id == currentChannelId) {
      return -1;
    } else if (channelB.id == currentChannelId) {
      return 1;
    }

    final isUnreadA = isUnreadChannel(myChannelA, notifyProps: notifyPropsPerChannel[myChannelA.id], lastUnreadChannelId: lastUnreadChannelId);
    final isUnreadB = isUnreadChannel(myChannelB, notifyProps: notifyPropsPerChannel[myChannelB.id], lastUnreadChannelId: lastUnreadChannelId);
    if (isUnreadA && !isUnreadB) {
      return -1;
    } else if (!isUnreadA && isUnreadB) {
      return 1;
    }

    final channelAlastViewed = getLastViewedAt(cwmA);
    final channelBlastViewed = getLastViewedAt(cwmB);

    return channelAlastViewed.compareTo(channelBlastViewed);
  });

  final remaining = limit.compareTo(unreadCount);
  visibleChannels = visibleChannels.take(remaining).toList();

  return visibleChannels;
}

List<ChannelWithMyChannel> filterManuallyClosedDms(
    List<ChannelWithMyChannel> channelsWithMyChannel,
    Map<String, Map<String, dynamic>> notifyPropsPerChannel,
    List<Preference> preferences,
    String currentUserId, {
      String? lastUnreadChannelId,
    }) {
  return channelsWithMyChannel.where((cwm) {
    final channel = cwm.channel;
    final myChannel = cwm.myChannel;

    if (!isDMorGM(channel)) {
      return true;
    }

    if (isUnreadChannel(myChannel, notifyProps: notifyPropsPerChannel[myChannel.id], lastUnreadChannelId: lastUnreadChannelId)) {
      return true;
    }

    if (channel.type == General.DM_CHANNEL) {
      final teammateId = getUserIdFromChannelName(currentUserId, channel.name);
      return getPreferenceAsBool(preferences, Preferences.CATEGORIES.DIRECT_CHANNEL_SHOW, teammateId, true);
    }

    return getPreferenceAsBool(preferences, Preferences.CATEGORIES.GROUP_CHANNEL_SHOW, channel.id, true);
  }).toList();
}

int Function(ChannelWithMyChannel, ChannelWithMyChannel) sortChannelsByName(Map<String, Map<String, dynamic>> notifyPropsPerChannel, String locale) {
  return (a, b) {
    final aMuted = notifyPropsPerChannel[a.channel.id]?['mark_unread'] == General.MENTION;
    final bMuted = notifyPropsPerChannel[b.channel.id]?['mark_unread'] == General.MENTION;

    if (aMuted && !bMuted) {
      return 1;
    } else if (!aMuted && bMuted) {
      return -1;
    }

    return a.channel.displayName.compareTo(b.channel.displayName, locale);
  };
}

List<Channel> sortChannels(
    String sorting,
    List<ChannelWithMyChannel> channelsWithMyChannel,
    Map<String, Map<String, dynamic>> notifyPropsPerChannel,
    String locale,
    ) {
  if (sorting == 'recent') {
    channelsWithMyChannel.sort((cwmA, cwmB) {
      final a = cwmA.myChannel.lastPostAt.compareTo(cwmA.channel.createAt);
      final b = cwmB.myChannel.lastPostAt.compareTo(cwmB.channel.createAt);
      return b.compareTo(a);
    });
  } else if (sorting == 'manual') {
    channelsWithMyChannel.sort((cwmA, cwmB) {
      return cwmA.sortOrder.compareTo(cwmB.sortOrder);
    });
  } else {
    channelsWithMyChannel.sort(sortChannelsByName(notifyPropsPerChannel, locale));
  }

  return channelsWithMyChannel.map((cwm) => cwm.channel).toList();
}

Set<String> getUnreadIds(
    List<ChannelWithMyChannel> cwms,
    Map<String, Map<String, dynamic>> notifyPropsPerChannel, {
      String? lastUnreadId,
    }) {
  return cwms.fold<Set<String>>(<String>{}, (result, cwm) {
    if (isUnreadChannel(cwm.myChannel, notifyProps: notifyPropsPerChannel[cwm.channel.id], lastUnreadId: lastUnreadId)) {
      result.add(cwm.channel.id);
    }
    return result;
  });
}