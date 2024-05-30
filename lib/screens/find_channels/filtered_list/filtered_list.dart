// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/material.dart';
import 'package:mattermost_flutter/constants.dart';
import 'package:mattermost_flutter/helpers/database.dart';
import 'package:mattermost_flutter/helpers/role.dart';
import 'package:mattermost_flutter/types.dart';
import 'package:mattermost_flutter/components/channel_item.dart';
import 'package:mattermost_flutter/components/loading.dart';
import 'package:mattermost_flutter/components/no_results_with_term.dart';
import 'package:mattermost_flutter/components/threads_button.dart';
import 'package:mattermost_flutter/components/user_item.dart';
import 'package:mattermost_flutter/utils/theme.dart';
import 'package:mattermost_flutter/utils/navigation.dart';
import 'package:mattermost_flutter/actions/remote/channel.dart';
import 'package:mattermost_flutter/utils/channel.dart';

class FilteredList extends StatefulWidget {
  final List<ChannelModel> archivedChannels;
  final Future<void> Function() close;
  final List<ChannelModel> channelsMatch;
  final List<ChannelModel> channelsMatchStart;
  final String currentTeamId;
  final bool isCRTEnabled;
  final double keyboardOverlap;
  final bool loading;
  final void Function(bool) onLoading;
  final bool restrictDirectMessage;
  final bool showTeamName;
  final Set<String> teamIds;
  final String teammateDisplayNameSetting;
  final String term;
  final List<UserModel> usersMatch;
  final List<UserModel> usersMatchStart;
  final String? testID;

  const FilteredList({
    required this.archivedChannels,
    required this.close,
    required this.channelsMatch,
    required this.channelsMatchStart,
    required this.currentTeamId,
    required this.isCRTEnabled,
    required this.keyboardOverlap,
    required this.loading,
    required this.onLoading,
    required this.restrictDirectMessage,
    required this.showTeamName,
    required this.teamIds,
    required this.teammateDisplayNameSetting,
    required this.term,
    required this.usersMatch,
    required this.usersMatchStart,
    this.testID,
  });

  @override
  _FilteredListState createState() => _FilteredListState();
}

class _FilteredListState extends State<FilteredList> {
  late Debouncer _debouncer;
  late bool _mounted;
  late RemoteChannels _remoteChannels;

  @override
  void initState() {
    super.initState();
    _debouncer = Debouncer(milliseconds: 500);
    _mounted = true;
    _remoteChannels = RemoteChannels(archived: [], startWith: [], matches: []);
    _debouncer.run(_search);
  }

  @override
  void dispose() {
    _mounted = false;
    super.dispose();
  }

  Future<void> _search() async {
    widget.onLoading(true);
    if (_mounted) {
      setState(() {
        _remoteChannels = RemoteChannels(archived: [], startWith: [], matches: []);
      });
    }
    final lowerCasedTerm = (widget.term.startsWith('@') ? widget.term.substring(1) : widget.term).toLowerCase();
    if ((widget.channelsMatchStart.length + widget.channelsMatch.length) < MAX_RESULTS) {
      if (widget.restrictDirectMessage) {
        searchProfiles(widget.currentTeamId, lowerCasedTerm, allowInactive: true);
      } else {
        searchProfiles(lowerCasedTerm, allowInactive: true);
      }
    }

    if (!widget.term.startsWith('@')) {
      if (totalLocalResults < MAX_RESULTS) {
        final channels = await searchAllChannels(lowerCasedTerm, true);
        if (channels != null) {
          final existingChannelIds = widget.channelsMatchStart
              .followedBy(widget.channelsMatch)
              .followedBy(widget.archivedChannels)
              .map((c) => c.id)
              .toSet();

          final startWith = <Channel>[];
          final matches = <Channel>[];
          final archived = <Channel>[];

          for (final c in channels) {
            if (!existingChannelIds.contains(c.id) && widget.teamIds.contains(c.teamId)) {
              if (!c.deleteAt) {
                if (c.displayName.toLowerCase().startsWith(lowerCasedTerm)) {
                  startWith.add(c);
                } else if (c.displayName.toLowerCase().contains(lowerCasedTerm)) {
                  matches.add(c);
                }
              } else if (c.displayName.toLowerCase().contains(lowerCasedTerm)) {
                archived.add(c);
              }
            }
          }

          if (_mounted) {
            setState(() {
              _remoteChannels = RemoteChannels(
                archived: archived..sort(sortChannelsByDisplayName),
                startWith: startWith..sort(sortByLastPostAt),
                matches: matches..sort(sortChannelsByDisplayName),
              );
            });
          }
        }
      }
    }

    widget.onLoading(false);
  }

  Future<void> _onJoinChannel(Channel c) async {
    final res = await joinChannelIfNeeded(c.id);
    if (res.error != null) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          content: Text("We couldn't join the channel ${c.displayName}."),
        ),
      );
      return;
    }

    await widget.close();
    switchToChannelById(c.id);
  }

  Future<void> _onOpenDirectMessage(UserModel u) async {
    final displayName = displayUsername(u, widget.teammateDisplayNameSetting);
    final res = await makeDirectChannel(u.id, displayName, false);
    if (res.error != null) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          content: Text("We couldn't open a DM with $displayName."),
        ),
      );
      return;
    }

    await widget.close();
    switchToChannelById(res.data!.id);
  }

  Future<void> _onSwitchToChannel(Channel c) async {
    await widget.close();
    switchToChannelById(c.id);
  }

  Future<void> _onSwitchToThreads() async {
    await widget.close();
    switchToGlobalThreads();
  }

  Widget _renderEmpty() {
    if (widget.loading) {
      return Loading(
        containerStyle: const BoxDecoration(
          color: Colors.transparent,
        ),
        size: 50.0,
        color: Theme.of(context).primaryColor,
      );
    }

    if (widget.term.isNotEmpty) {
      return NoResultsWithTerm(term: widget.term);
    }

    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    final flatListStyle = BoxDecoration(
      color: Colors.transparent,
      padding: EdgeInsets.only(bottom: widget.keyboardOverlap),
    );

    final data = <ResultItem>[];

    // Add threads item to show it on the top of the list
    if (widget.isCRTEnabled) {
      final isThreadTerm = threadLabel(widget.term).indexOf(widget.term.toLowerCase()) == 0;
      if (isThreadTerm) {
        data.add('thread');
      }
    }

    data.addAll(widget.channelsMatchStart);

    // Channels that matches
    if (data.length < MAX_RESULTS) {
      data.addAll(widget.channelsMatch);
    }

    // Users that start with
    if (data.length < MAX_RESULTS) {
      data.addAll(widget.usersMatchStart);
    }

    // Archived channels local
    if (data.length < MAX_RESULTS) {
      data.addAll(widget.archivedChannels..sort(sortChannelsByDisplayName));
    }

    // Remote Channels that start with
    if (data.length < MAX_RESULTS) {
      data.addAll(_remoteChannels.startWith);
    }

    // Users & Channels that matches
    if (data.length < MAX_RESULTS) {
      data.addAll([...widget.usersMatch, ..._remoteChannels.matches]..sort(sortByUserOrChannel));
    }

    // Archived channels
    if (data length < MAX_RESULTS) {
      data.addAll(_remoteChannels.archived..sort(sortChannelsByDisplayName));
    }

    return AnimatedContainer(
      duration: Duration(milliseconds: 100),
      curve: Curves.easeIn,
      child: ListView.builder(
        itemCount: data.length,
        itemBuilder: (context, index) {
          final item = data[index];
          if (item == 'thread') {
            return ThreadsButton(
              onCenterBg: true,
              onPress: _onSwitchToThreads,
            );
          }

          if (item is ChannelModel) {
            return ChannelItem(
              channel: item,
              isOnCenterBg: true,
              onPress: _onSwitchToChannel,
              showTeamName: widget.showTeamName,
              shouldHighlightState: true,
              testID: 'find_channels.filtered_list.channel_item',
            );
          }

          if (item is UserModel) {
            return UserItem(
              onUserPress: _onOpenDirectMessage,
              user: item,
              testID: 'find_channels.filtered_list.user_item',
              showBadges: true,
            );
          }

          return ChannelItem(
            channel: item,
            isOnCenterBg: true,
            onPress: _onJoinChannel,
            showTeamName: widget.showTeamName,
            shouldHighlightState: true,
            testID: 'find_channels.filtered_list.remote_channel_item',
          );
        },
      ),
    );
  }
}

class RemoteChannels {
  List<Channel> archived;
  List<Channel> startWith;
  List<Channel> matches;

  RemoteChannels({required this.archived, required this.startWith, required this.matches});
}

class Debouncer {
  final int milliseconds;
  VoidCallback? action;
  Timer? _timer;

  Debouncer({required this.milliseconds});

  run(VoidCallback action) {
    if (_timer != null) {
      _timer!.cancel();
    }
    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }
}
