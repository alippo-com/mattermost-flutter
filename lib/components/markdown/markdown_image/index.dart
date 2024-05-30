
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sqflite/sqflite.dart'; // Use sqflite in place of watermelondb

import 'package:mattermost_flutter/constants/general.dart';
import 'package:mattermost_flutter/state/calls_state.dart';
import 'package:mattermost_flutter/context/server.dart';
import 'package:mattermost_flutter/queries/servers/channel.dart';
import 'package:mattermost_flutter/queries/servers/drafts.dart';
import 'package:mattermost_flutter/components/channel_item/channel_item.dart';

import 'package:mattermost_flutter/types/database/models/servers/channel.dart' as ChannelModel;

class EnhanceProps {
  final Database database;
  final ChannelModel.Channel channel;
  final bool showTeamName;
  final String? serverUrl;
  final bool shouldHighlightActive;
  final bool shouldHighlightState;

  EnhanceProps({
    required this.database,
    required this.channel,
    this.showTeamName = false,
    this.serverUrl,
    this.shouldHighlightActive = false,
    this.shouldHighlightState = false,
  });
}

class EnhancedChannelItem extends StatelessWidget {
  final EnhanceProps props;

  EnhancedChannelItem({required this.props});

  @override
  Widget build(BuildContext context) {
    final currentUserId = observeCurrentUserId(props.database);
    final myChannel = observeMyChannel(props.database, props.channel.id);

    final hasDraft = props.shouldHighlightState
        ? queryDraft(props.database, props.channel.id)
        .observeWithColumns(['message', 'files', 'metadata'])
        .switchMap((drafts) {
      if (drafts.isEmpty) return Stream.value(false);

      final draft = drafts.first;
      final standardPriority = draft.metadata?.priority?.priority == '';

      if (draft.message.isEmpty && draft.files.isEmpty && standardPriority) {
        return Stream.value(false);
      }

      return Stream.value(true);
    }).distinct()
        : Stream.value(false);

    final isActive = props.shouldHighlightActive
        ? observeCurrentChannelId(props.database).switchMap((id) {
      return Stream.value(id == props.channel.id);
    }).distinct()
        : Stream.value(false);

    final isMuted = props.shouldHighlightState
        ? myChannel.switchMap((mc) {
      if (mc == null) return Stream.value(false);
      return observeIsMutedSetting(props.database, mc.id);
    })
        : Stream.value(false);

    final teamId = props.channel.teamId ?? props.channel.team_id;
    final teamDisplayName = teamId != null && props.showTeamName
        ? observeTeam(props.database, teamId).switchMap((team) {
      return Stream.value(team?.displayName ?? '');
    }).distinct()
        : Stream.value('');

    final membersCount = props.channel.type == General.GM_CHANNEL
        ? queryChannelMembers(props.database, props.channel.id).observeCount(false)
        : Stream.value(0);

    final isUnread = props.shouldHighlightState
        ? myChannel.switchMap((mc) {
      return Stream.value(mc?.isUnread ?? false);
    }).distinct()
        : Stream.value(false);

    final mentionsCount = props.shouldHighlightState
        ? myChannel.switchMap((mc) {
      return Stream.value(mc?.mentionsCount ?? 0);
    }).distinct()
        : Stream.value(0);

    final hasCall = observeChannelsWithCalls(props.serverUrl ?? '').switchMap((calls) {
      return Stream.value(calls.containsKey(props.channel.id));
    }).distinct();

    return StreamProvider.value(
      value: CombineLatestStream.combine9(
        props.channel.observe(),
        currentUserId,
        hasDraft,
        isActive,
        isMuted,
        membersCount,
        isUnread,
        mentionsCount,
        teamDisplayName,
            (channel, currentUserId, hasDraft, isActive, isMuted, membersCount, isUnread, mentionsCount, teamDisplayName) {
          return ChannelItem(
            channel: channel,
            currentUserId: currentUserId,
            hasDraft: hasDraft,
            isActive: isActive,
            isMuted: isMuted,
            membersCount: membersCount,
            isUnread: isUnread,
            mentionsCount: mentionsCount,
            teamDisplayName: teamDisplayName,
            hasCall: hasCall,
          );
        },
      ),
      child: Consumer<ChannelItem>(
        builder: (context, channelItem, _) => channelItem,
      ),
    );
  }
}
