// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/material.dart';
import 'package:watermelondb/watermelondb.dart';
import 'package:rxdart/rxdart.dart';

import 'package:mattermost_flutter/constants.dart';
import 'package:mattermost_flutter/constants/categories.dart';
import 'package:mattermost_flutter/helpers/api/preference.dart';
import 'package:mattermost_flutter/queries/servers/channel.dart';
import 'package:mattermost_flutter/queries/servers/preference.dart';
import 'package:mattermost_flutter/queries/servers/user.dart';
import 'package:mattermost_flutter/components/category_body.dart';

class EnhanceProps {
  final CategoryModel category;
  final String locale;
  final String currentUserId;
  final bool isTablet;
  final Database database;

  EnhanceProps({
    required this.category,
    required this.locale,
    required this.currentUserId,
    required this.isTablet,
    required this.database,
  });
}

Stream<String> observeCurrentUserId(Database database) {
  // Implement observeCurrentUserId
}

Stream<List<ChannelModel>> observeCategoryChannels(CategoryModel category, Observable<List<MyChannelModel>> myChannels) {
  final channels = category.channels.observeWithColumns(['create_at', 'display_name']);
  final manualSort = category.categoryChannelsBySortOrder.observeWithColumns(['sort_order']);
  return myChannels.switchMap(
    (my) {
      final channelMap = {for (var c in channels) c.id: c};
      final categoryChannelMap = {for (var s in manualSort) s.channelId: s.sortOrder};
      return Stream.value(
        my.map((myChannel) {
          final channel = channelMap[myChannel.id];
          if (channel != null) {
            return ChannelWithMyChannel(
              channel: channel,
              myChannel: myChannel,
              sortOrder: categoryChannelMap[myChannel.id] ?? 0,
            );
          }
          return null;
        }).where((element) => element != null).toList(),
      );
    },
  );
}

class Enhanced extends StatelessWidget {
  final EnhanceProps props;

  Enhanced(this.props);

  @override
  Widget build(BuildContext context) {
    final categoryMyChannels = props.category.myChannels.observeWithColumns(['last_post_at', 'is_unread']);
    final channelsWithMyChannel = observeCategoryChannels(props.category, categoryMyChannels);
    final currentChannelId = props.isTablet ? observeCurrentChannelId(props.database) : Stream.value('');
    final lastUnreadId = props.isTablet ? observeLastUnreadChannelId(props.database) : Stream.value(null);

    final unreadsOnTop = querySidebarPreferences(props.database, Preferences.CHANNEL_SIDEBAR_GROUP_UNREADS)
        .observeWithColumns(['value'])
        .switchMap((prefs) => Stream.value(getSidebarPreferenceAsBool(prefs, Preferences.CHANNEL_SIDEBAR_GROUP_UNREADS)));

    var limit = Stream.value(Preferences.CHANNEL_SIDEBAR_LIMIT_DMS_DEFAULT);
    if (props.category.type == DMS_CATEGORY) {
      limit = querySidebarPreferences(props.database, Preferences.CHANNEL_SIDEBAR_LIMIT_DMS)
          .observeWithColumns(['value'])
          .switchMap((val) => Stream.value(int.parse(val[0]?.value ?? '10')));
    }

    final notifyPropsPerChannel = categoryMyChannels.switchMap((mc) => observeNotifyPropsByChannels(props.database, mc));

    final hiddenDmPrefs = queryPreferencesByCategoryAndName(props.database, Preferences.CATEGORIES.DIRECT_CHANNEL_SHOW, value: 'false')
        .observeWithColumns(['value']);
    final hiddenGmPrefs = queryPreferencesByCategoryAndName(props.database, Preferences.CATEGORIES.GROUP_CHANNEL_SHOW, value: 'false')
        .observeWithColumns(['value']);
    final manuallyClosedPrefs = CombineLatestStream.combine2(hiddenDmPrefs, hiddenGmPrefs, (dms, gms) => dms + gms);

    final approxViewTimePrefs = queryPreferencesByCategoryAndName(props.database, Preferences.CATEGORIES.CHANNEL_APPROXIMATE_VIEW_TIME)
        .observeWithColumns(['value']);
    final openTimePrefs = queryPreferencesByCategoryAndName(props.database, Preferences.CATEGORIES.CHANNEL_OPEN_TIME)
        .observeWithColumns(['value']);
    final autoclosePrefs = CombineLatestStream.combine2(approxViewTimePrefs, openTimePrefs, (viewTimes, openTimes) => viewTimes + openTimes);

    final categorySorting = props.category.observe().switchMap((c) => Stream.value(c.sorting)).distinctUnique();

    final deactivated = props.category.type == DMS_CATEGORY ? observeDeactivatedUsers(props.database) : Stream.value(null);

    final sortedChannels = CombineLatestStream.combine9(
      channelsWithMyChannel,
      categorySorting,
      currentChannelId,
      lastUnreadId,
      notifyPropsPerChannel,
      manuallyClosedPrefs,
      autoclosePrefs,
      deactivated,
      limit,
      (
        cwms,
        sorting,
        channelId,
        unreadId,
        notifyProps,
        manuallyClosedDms,
        autoclose,
        deactivatedUsers,
        maxDms,
      ) {
        var channelsW = filterArchivedChannels(cwms, channelId);
        channelsW = filterManuallyClosedDms(channelsW, notifyProps, manuallyClosedDms, props.currentUserId, unreadId);
        channelsW = filterAutoclosedDMs(props.category.type, maxDms, props.currentUserId, channelId, channelsW, autoclose, notifyProps, deactivatedUsers, unreadId);

        return sortChannels(sorting, channelsW, notifyProps, props.locale);
      },
    );

    final unreadIds = CombineLatestStream.combine3(
      channelsWithMyChannel,
      notifyPropsPerChannel,
      lastUnreadId,
      (cwms, notifyProps, unreadId) => getUnreadIds(cwms, notifyProps, unreadId),
    );

    return CategoryBody(
      category: props.category,
      sortedChannels: sortedChannels,
      unreadIds: unreadIds,
      unreadsOnTop: unreadsOnTop,
    );
  }
}
