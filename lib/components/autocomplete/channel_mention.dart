import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:debounce_throttle/debounce_throttle.dart';
import 'package:mattermost_flutter/actions/remote/channel.dart';
import 'package:mattermost_flutter/components/autocomplete/autocomplete_section_header.dart';
import 'package:mattermost_flutter/components/channel_item.dart';
import 'package:mattermost_flutter/constants.dart';
import 'package:mattermost_flutter/context/server.dart';
import 'package:mattermost_flutter/i18n.dart';
import 'package:mattermost_flutter/queries/servers/channel.dart';
import 'package:mattermost_flutter/types/database/models/servers/channel.dart';

const SECTION_KEY_PUBLIC_CHANNELS = 'publicChannels';
const SECTION_KEY_PRIVATE_CHANNELS = 'privateChannels';
const SECTION_KEY_DIRECT_AND_GROUP_MESSAGES = 'directAndGroupMessages';
const SECTION_KEY_MY_CHANNELS = 'myChannels';
const SECTION_KEY_OTHER_CHANNELS = 'otherChannels';

class ChannelMention extends StatefulWidget {
  final String? channelId;
  final String teamId;
  final int cursorPosition;
  final bool isSearch;
  final ValueChanged<String> updateValue;
  final ValueChanged<bool> onShowingChange;
  final String value;
  final bool nestedScrollEnabled;
  final TextStyle listStyle;

  ChannelMention({
    required this.teamId,
    required this.cursorPosition,
    required this.isSearch,
    required this.updateValue,
    required this.onShowingChange,
    required this.value,
    required this.nestedScrollEnabled,
    required this.listStyle,
    this.channelId,
  });

  @override
  _ChannelMentionState createState() => _ChannelMentionState();
}

class _ChannelMentionState extends State<ChannelMention> {
  final _debouncer = Debouncer<String>(Duration(milliseconds: 200));
  DateTime _latestSearchAt = DateTime.now();

  List<SectionListData<dynamic>> sections = [];
  List<ChannelModel> localChannels = [];
  List<ChannelModel> remoteChannels = [];
  bool loading = false;
  String? noResultsTerm;
  int localCursorPosition = 0;
  bool useLocal = true;

  @override
  void initState() {
    super.initState();
    _debouncer.values.listen((value) {
      runSearch(
        widget.value,
        widget.teamId,
      );
    });
  }

  void runSearch(
    String term,
    String teamId, [
    String? channelId,
  ]) async {
    final searchAt = DateTime.now();
    _latestSearchAt = searchAt;

    final receivedChannels = await searchChannels(
      Provider.of<ServerUrl>(context, listen: false),
      term,
      teamId,
      channelId,
    );

    if (_latestSearchAt.isBefore(searchAt)) {
      return;
    }

    setState(() {
      remoteChannels = receivedChannels ?? [];
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final matchTerm = getMatchTermForChannelMention(
      widget.value.substring(0, localCursorPosition),
      widget.isSearch,
    );

    if (sections.isEmpty || noResultsTerm != null) {
      return SizedBox.shrink();
    }

    return ListView.builder(
      itemCount: sections.length,
      itemBuilder: (context, index) {
        final section = sections[index];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AutocompleteSectionHeader(
              id: section.id,
              defaultMessage: section.defaultMessage,
              loading: !section.hideLoadingIndicator && loading,
            ),
            ...section.data.map((item) {
              switch (section.key) {
                case SECTION_KEY_PUBLIC_CHANNELS:
                case SECTION_KEY_PRIVATE_CHANNELS:
                case SECTION_KEY_DIRECT_AND_GROUP_MESSAGES:
                case SECTION_KEY_MY_CHANNELS:
                case SECTION_KEY_OTHER_CHANNELS:
                  return ChannelItem(
                    key: Key('autocomplete-channel-${item.name}'),
                    name: item.name,
                    displayName: item.displayName,
                    memberCount: item.memberCount,
                    onPress: (mention) => completeMention(mention),
                  );
                default:
                  return SizedBox.shrink();
              }
            }).toList(),
          ],
        );
      },
    );
  }

  void completeMention(String mention) {
    final mentionPart = widget.value.substring(0, localCursorPosition);
    final completedDraft = widget.isSearch
        ? mentionPart.replaceAll(RegExp(CHANNEL_MENTION_SEARCH_REGEX), 'in: $mention ')
        : mentionPart.replaceAll(RegExp(CHANNEL_MENTION_REGEX), '~$mention ');

    final newCursorPosition = completedDraft.length;
    final newValue = widget.value.length > widget.cursorPosition
        ? completedDraft + widget.value.substring(widget.cursorPosition)
        : completedDraft;

    widget.updateValue(newValue);
    setState(() {
      localCursorPosition = newCursorPosition;
      noResultsTerm = mention;
      sections = [];
    });
    widget.onShowingChange(false);
  }
}

String? getMatchTermForChannelMention(String value, bool isSearch) {
  final regex = isSearch ? CHANNEL_MENTION_SEARCH_REGEX : CHANNEL_MENTION_REGEX;
  var term = value.toLowerCase();
  final match = regex.firstMatch(term);
  if (match != null) {
    return (isSearch ? match.group(1) : match.group(2))?.toLowerCase();
  }
  return null;
}

List<SectionListData<dynamic>> makeSections(
  List<dynamic> channels,
  List<dynamic> myMembers,
  bool loading,
  bool isSearch,
) {
  final newSections = <SectionListData<dynamic>>[];

  if (isSearch) {
    final List<dynamic> publicChannels = [];
    final List<dynamic> privateChannels = [];
    final List<dynamic> directAndGroupMessages = [];
    for (final c in channels) {
      switch (c.type) {
        case General.OPEN_CHANNEL:
          if (myMembers.contains(c.id)) {
            publicChannels.add(c);
          }
          break;
        case General.PRIVATE_CHANNEL:
          privateChannels.add(c);
          break;
        case General.DM_CHANNEL:
        case General.GM_CHANNEL:
          directAndGroupMessages.add(c);
      }
    }
    if (publicChannels.isNotEmpty) {
      newSections.add(SectionListData(
        id: t('suggestion.search.public'),
        defaultMessage: 'Public Channels',
        data: publicChannels,
        key: SECTION_KEY_PUBLIC_CHANNELS,
      ));
    }

    if (privateChannels.isNotEmpty) {
      newSections.add(SectionListData(
        id: t('suggestion.search.private'),
        defaultMessage: 'Private Channels',
        data: privateChannels,
        key: SECTION_KEY_PRIVATE_CHANNELS,
      ));
    }

    if (directAndGroupMessages.isNotEmpty) {
      newSections.add(SectionListData(
        id: t('suggestion.search.direct'),
        defaultMessage: 'Direct Messages',
        data: directAndGroupMessages,
        key: SECTION_KEY_DIRECT_AND_GROUP_MESSAGES,
      ));
    }
  } else {
    final List<dynamic> myChannels = [];
    final List<dynamic> otherChannels = [];
    for (final c in channels) {
      if (myMembers.contains(c.id)) {
        myChannels.add(c);
      } else {
        otherChannels.add(c);
      }
    }
    if (myChannels.isNotEmpty) {
      newSections.add(SectionListData(
        id: t('suggestion.mention.channels'),
        defaultMessage: 'My Channels',
        data: myChannels,
        key: SECTION_KEY_MY_CHANNELS,
      ));
    }

    if (otherChannels.isNotEmpty || (!myChannels.isNotEmpty && loading)) {
      newSections.add(SectionListData(
        id: t('suggestion.mention.morechannels'),
        defaultMessage: 'Other Channels',
        data: otherChannels,
        key: SECTION_KEY_OTHER_CHANNELS,
      ));
    }
  }

  if (newSections.isNotEmpty) {
    newSections.last.hideLoadingIndicator = false;
  }

  return newSections;
}

List<dynamic> filterResults(List<dynamic> channels, String term) {
  return channels.where((c) {
    final displayName = c.displayName.toLowerCase();
    return c.name.toLowerCase().contains(term) || displayName.contains(term);
  }).toList();
}
