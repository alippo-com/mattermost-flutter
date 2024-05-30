// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/material.dart';

import 'package:mattermost_flutter/constants/general.dart';
import 'package:mattermost_flutter/queries/servers/channel.dart';
import 'package:mattermost_flutter/queries/servers/user.dart';
import 'header.dart';

class ChannelHeaderContainer extends StatefulWidget {
  final String channelId;

  ChannelHeaderContainer({required this.channelId});

  @override
  _ChannelHeaderContainerState createState() => _ChannelHeaderContainerState();
}

class _ChannelHeaderContainerState extends State<ChannelHeaderContainer> {
  late Stream<String?> channelType;
  late Stream<String?> displayName;
  late Stream<bool> isOwnDirectMessage;
  late Stream<dynamic> customStatus;
  late Stream<bool> isCustomStatusExpired;
  late Stream<bool> isCustomStatusEnabled;
  late Stream<String?> searchTerm;
  late Stream<int?> memberCount;
  late Stream<String> teamId;

  @override
  void initState() {
    super.initState();
    final database = Database(); // Replace with actual database instance

    final currentUserId = observeCurrentUserId(database);
    final teamIdStream = observeCurrentTeamId(database);

    final channel = observeChannel(database, widget.channelId);

    channelType = channel.switchMap((c) => Stream.value(c?.type));
    final channelInfo = observeChannelInfo(database, widget.channelId);

    final dmUser = currentUserId
        .combineLatest(channel, (userId, c) => c?.type == General.DM_CHANNEL ? getUserIdFromChannelName(userId, c.name) : null)
        .switchMap((teammateId) => teammateId != null ? observeUser(database, teammateId) : Stream.value(null));

    isOwnDirectMessage = currentUserId.combineLatest(dmUser, (userId, dm) => userId == dm?.id);

    customStatus = dmUser.switchMap((dm) => Stream.value(getUserCustomStatus(dm)));

    isCustomStatusExpired = dmUser.switchMap((dm) => Stream.value(checkCustomStatusIsExpired(dm)));

    isCustomStatusEnabled = observeConfigBooleanValue(database, 'EnableCustomUserStatuses');

    searchTerm = channel.combineLatest(dmUser, (c, dm) {
      if (c?.type == General.DM_CHANNEL) {
        return Stream.value(dm != null ? '@${dm.username}' : '');
      } else if (c?.type == General.GM_CHANNEL) {
        return Stream.value('@${c.name}');
      }
      return Stream.value(c?.name);
    });

    displayName = channel.switchMap((c) => Stream.value(c?.displayName));
    memberCount = channelInfo.combineLatest(dmUser, (ci, dm) => dm != null ? null : ci?.memberCount);

    teamId = teamIdStream;
  }

  @override
  Widget build(BuildContext context) {
    return ChannelHeader(
      channelId: widget.channelId,
      channelType: channelType,
      customStatus: customStatus,
      displayName: displayName,
      isCustomStatusEnabled: isCustomStatusEnabled,
      isCustomStatusExpired: isCustomStatusExpired,
      isOwnDirectMessage: isOwnDirectMessage,
      memberCount: memberCount,
      searchTerm: searchTerm,
      teamId: teamId,
    );
  }
}
