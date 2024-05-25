// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:xregexp/xregexp.dart';
import 'package:mattermost_flutter/constants/general.dart';
import 'package:mattermost_flutter/types/channel_model.dart';
import 'package:mattermost_flutter/types/my_channel_model.dart';

typedef NotifyProps = Map<String, Partial<ChannelNotifyProps>>;

/**
 * Filtering / Sorting:
 *
 * Unreads, Mentions, and Muted Mentions Only
 * Mentions on top, then unreads, then muted channels with mentions.
 */

 typedef FilterAndSortMyChannelsArgs = List<dynamic>;

String extractChannelDisplayName(Map<String, dynamic> raw, [ChannelModel? record]) {
  String displayName = '';
  switch (raw['type']) {
    case General.DM_CHANNEL:
      displayName = raw['display_name'].trim() ?? record?.displayName ?? '';
      break;
    case General.GM_CHANNEL:
      if (raw['fake']) {
        displayName = raw['display_name'];
      } else {
        displayName = record?.displayName ?? raw['display_name'];
      }
      break;
    default:
      displayName = raw['display_name'];
      break;
  }

  return displayName;
}

Map<String, ChannelModel> makeChannelsMap(List<ChannelModel> channels) {
  return channels.fold<Map<String, ChannelModel>>({}, (result, c) {
    result[c.id] = c;
    return result;
  });
}

List<ChannelModel> filterAndSortMyChannels(FilterAndSortMyChannelsArgs args) {
  List<ChannelModel> mentions = [];
  List<ChannelModel> unreads = [];
  List<ChannelModel> mutedMentions = [];

  List<MyChannelModel> myChannels = args[0];
  Map<String, ChannelModel> channels = args[1];
  NotifyProps notifyProps = args[2];

  bool isMuted(String id) {
    return notifyProps[id]?.mark_unread == 'mention';
  }

  for (final myChannel in myChannels) {
    final id = myChannel.id;

    // is it a mention?
    if (!isMuted(id) && myChannel.mentionsCount > 0 && channels.containsKey(id)) {
      mentions.add(channels[id]!);
      continue;
    }

    // is it unread?
    if (!isMuted(id) && myChannel.isUnread && channels.containsKey(id)) {
      unreads.add(channels[id]!);
      continue;
    }

    // is it a muted mention?
    if (isMuted(id) && myChannel.mentionsCount > 0 && channels.containsKey(id)) {
      mutedMentions.add(channels[id]!);
      continue;
    }
  }

  return [...mentions, ...unreads, ...mutedMentions];
}

// Matches letters from any alphabet and numbers
final RegExp sqliteLikeStringRegex = xRegExp(r'[^\p{L}\p{Nd}]', 'g');
String sanitizeLikeString(String value) {
  return value.replaceAll(sqliteLikeStringRegex, '_');
}
