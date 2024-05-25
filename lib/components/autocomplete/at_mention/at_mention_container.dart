// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';

import 'package:mattermost_flutter/constants/permissions.dart';
import 'package:mattermost_flutter/data/database.dart';
import 'package:mattermost_flutter/models/team_model.dart';
import 'package:mattermost_flutter/queries/channel.dart';
import 'package:mattermost_flutter/queries/role.dart';
import 'package:mattermost_flutter/queries/system.dart';
import 'package:mattermost_flutter/queries/team.dart';
import 'package:mattermost_flutter/queries/user.dart';
import 'package:mattermost_flutter/components/autocomplete/at_mention.dart';

class AtMentionContainer extends StatelessWidget {
  final String? channelId;
  final String? teamId;

  AtMentionContainer({this.channelId, this.teamId});

  @override
  Widget build(BuildContext context) {
    final database = Provider.of<Database>(context);
    final currentUser = observeCurrentUser(database);

    final hasLicense = observeLicense(database).switchMap((lcs) => Stream.value(lcs?.isLicensed == 'true'));

    Stream<bool> useChannelMentions;
    Stream<bool> useGroupMentions;
    Stream<bool> isChannelConstrained;
    Stream<bool> isTeamConstrained;
    Stream<TeamModel?> team;

    if (channelId != null) {
      final currentChannel = observeChannel(database, channelId!);
      team = currentChannel.switchMap((c) => c?.teamId != null ? observeTeam(database, c.teamId!) : observeCurrentTeam(database));

      isChannelConstrained = currentChannel.switchMap((c) => Stream.value(c?.isGroupConstrained ?? false));
      useChannelMentions = Rx.combineLatest2(currentUser, currentChannel, (u, c) => observePermissionForChannel(database, c, u, Permissions.USE_CHANNEL_MENTIONS, false));
      useGroupMentions = Rx.combineLatest3(currentUser, currentChannel, hasLicense, (u, c, lcs) => lcs ? observePermissionForChannel(database, c, u, Permissions.USE_GROUP_MENTIONS, false) : Stream.value(false));
    } else {
      useChannelMentions = Stream.value(false);
      useGroupMentions = Stream.value(false);
      isChannelConstrained = Stream.value(false);
      isTeamConstrained = Stream.value(false);
      team = teamId != null ? observeTeam(database, teamId!) : observeCurrentTeam(database);
    }

    isTeamConstrained = team.switchMap((t) => Stream.value(t?.isGroupConstrained ?? false));

    return StreamProvider<AtMentionData>(
      create: (_) => Rx.combineLatest4(
        isChannelConstrained,
        isTeamConstrained,
        useChannelMentions,
        useGroupMentions,
        (isChannelConstrained, isTeamConstrained, useChannelMentions, useGroupMentions) => AtMentionData(
          isChannelConstrained: isChannelConstrained,
          isTeamConstrained: isTeamConstrained,
          useChannelMentions: useChannelMentions,
          useGroupMentions: useGroupMentions,
          teamId: team.switchMap((t) => Stream.value(t?.id)),
        ),
      ),
      child: AtMention(),
    );
  }
}

class AtMentionData {
  final bool isChannelConstrained;
  final bool isTeamConstrained;
  final bool useChannelMentions;
  final bool useGroupMentions;
  final Stream<String?> teamId;

  AtMentionData({
    required this.isChannelConstrained,
    required this.isTeamConstrained,
    required this.useChannelMentions,
    required this.useGroupMentions,
    required this.teamId,
  });
}
