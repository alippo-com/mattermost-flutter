
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:debounce_throttle/debounce_throttle.dart';
import 'package:mattermost_flutter/actions/remote/user.dart';
import 'package:mattermost_flutter/actions/local/group.dart';
import 'package:mattermost_flutter/components/autocomplete/at_mention_group.dart';
import 'package:mattermost_flutter/components/autocomplete/at_mention_item.dart';
import 'package:mattermost_flutter/components/autocomplete/autocomplete_section_header.dart';
import 'package:mattermost_flutter/components/autocomplete/special_mention_item.dart';
import 'package:mattermost_flutter/constants.dart';
import 'package:mattermost_flutter/context/server.dart';
import 'package:mattermost_flutter/utils/helpers.dart';
import 'package:mattermost_flutter/i18n.dart';
import 'package:mattermost_flutter/queries/servers/user.dart';
import 'package:mattermost_flutter/types/database/models/servers/group.dart';
import 'package:mattermost_flutter/types/database/models/servers/user.dart';

const SECTION_KEY_TEAM_MEMBERS = 'teamMembers';
const SECTION_KEY_IN_CHANNEL = 'inChannel';
const SECTION_KEY_OUT_OF_CHANNEL = 'outChannel';
const SECTION_KEY_SPECIAL = 'special';
const SECTION_KEY_GROUPS = 'groups';

class SpecialMention {
  final String completeHandle;
  final String id;
  final String defaultMessage;

  SpecialMention({
    required this.completeHandle,
    required this.id,
    required this.defaultMessage,
  });
}

typedef UserMentionSections = List<SectionListData<dynamic>>;

String? getMatchTermForAtMention(String value, bool isSearch) {
  final regex = isSearch ? AT_MENTION_SEARCH_REGEX : AT_MENTION_REGEX;
  var term = value.toLowerCase();
  if (term.startsWith('from: @') || term.startsWith('from:@')) {
    term = term.replaceFirst('@', '');
  }

  final match = regex.firstMatch(term);
  if (match != null) {
    return (isSearch ? match.group(1) : match.group(2))?.toLowerCase();
  }
  return null;
}

List<SpecialMention> getSpecialMentions() {
  return [
    SpecialMention(
      completeHandle: 'all',
      id: t('suggestion.mention.all'),
      defaultMessage: 'Notifies everyone in this channel',
    ),
    SpecialMention(
      completeHandle: 'channel',
      id: t('suggestion.mention.channel'),
      defaultMessage: 'Notifies everyone in this channel',
    ),
    SpecialMention(
      completeHandle: 'here',
      id: t('suggestion.mention.here'),
      defaultMessage: 'Notifies everyone online in this channel',
    ),
  ];
}

bool checkSpecialMentions(String term) {
  return getSpecialMentions().any((m) => m.completeHandle.startsWith(term));
}

String keyExtractor(UserModel item) {
  return item.id;
}

List<UserModel> filterResults(List<UserModel> users, String term) {
  return users.where((u) {
    final firstName = u.firstName.toLowerCase();
    final lastName = u.lastName.toLowerCase();
    final fullName = '$firstName $lastName';
    return u.username.toLowerCase().contains(term) ||
        u.nickname.toLowerCase().contains(term) ||
        fullName.contains(term) ||
        u.email.toLowerCase().contains(term);
  }).toList();
}

UserMentionSections makeSections(
  List<dynamic> teamMembers,
  List<dynamic> usersInChannel,
  List<dynamic> usersOutOfChannel,
  List<GroupModel> groups,
  bool showSpecialMentions,
  bool isLocal,
  bool isSearch,
) {
  final newSections = <SectionListData<dynamic>>[];

  if (isSearch) {
    if (teamMembers.isNotEmpty) {
      newSections.add(SectionListData(
        id: t('mobile.suggestion.members'),
        defaultMessage: 'Members',
        data: teamMembers,
        key: SECTION_KEY_TEAM_MEMBERS,
      ));
    }
  } else if (isLocal) {
    if (teamMembers.isNotEmpty) {
      newSections.add(SectionListData(
        id: t('mobile.suggestion.members'),
        defaultMessage: 'Members',
        data: teamMembers,
        key: SECTION_KEY_TEAM_MEMBERS,
      ));
    }

    if (groups.isNotEmpty) {
      newSections.add(SectionListData(
        id: t('suggestion.mention.groups'),
        defaultMessage: 'Group Mentions',
        data: groups,
        key: SECTION_KEY_GROUPS,
      ));
    }

    if (showSpecialMentions) {
      newSections.add(SectionListData(
        id: t('suggestion.mention.special'),
        defaultMessage: 'Special Mentions',
        data: getSpecialMentions(),
        key: SECTION_KEY_SPECIAL,
      ));
    }
  } else {
    if (usersInChannel.isNotEmpty) {
      newSections.add(SectionListData(
        id: t('suggestion.mention.members'),
        defaultMessage: 'Channel Members',
        data: usersInChannel,
        key: SECTION_KEY_IN_CHANNEL,
      ));
    }

    if (groups.isNotEmpty) {
      newSections.add(SectionListData(
        id: t('suggestion.mention.groups'),
        defaultMessage: 'Group Mentions',
        data: groups,
        key: SECTION_KEY_GROUPS,
      ));
    }

    if (showSpecialMentions) {
      newSections.add(SectionListData(
        id: t('suggestion.mention.special'),
        defaultMessage: 'Special Mentions',
        data: getSpecialMentions(),
        key: SECTION_KEY_SPECIAL,
      ));
    }

    if (usersOutOfChannel.isNotEmpty) {
      newSections.add(SectionListData(
        id: t('suggestion.mention.nonmembers'),
        defaultMessage: 'Not in Channel',
        data: usersOutOfChannel,
        key: SECTION_KEY_OUT_OF_CHANNEL,
      ));
    }
  }
  return newSections;
}

Future<List<GroupModel>> searchGroups(
  String serverUrl,
  String matchTerm,
  bool useGroupMentions,
  bool isChannelConstrained,
  bool isTeamConstrained, {
  String? channelId,
  String? teamId,
}) async {
  if (useGroupMentions && matchTerm.isNotEmpty) {
    List<GroupModel> g = [];

    if (isChannelConstrained) {
      if (channelId != null) {
        g = await searchGroupsByNameInChannel(serverUrl, matchTerm, channelId);
      }
    } else if (isTeamConstrained) {
      g = await searchGroupsByNameInTeam(serverUrl, matchTerm, teamId!);
    } else {
      g = await searchGroupsByName(serverUrl, matchTerm);
    }

    return g.isNotEmpty ? g : [];
  }
  return [];
}

Future<List<UserModel>> getAllUsers(String serverUrl) async {
  final database = DatabaseManager.serverDatabases[serverUrl]?.database;
  if (database == null) {
    return [];
  }

  return queryAllUsers(database).fetch();
}

class AtMention extends StatefulWidget {
  final String? channelId;
  final String teamId;
  final int cursorPosition;
  final bool isSearch;
  final ValueChanged<String> updateValue;
  final ValueChanged<bool> onShowingChange;
  final String value;
  final bool nestedScrollEnabled;
  final bool useChannelMentions;
  final bool useGroupMentions;
  final bool isChannelConstrained;
  final bool isTeamConstrained;
  final TextStyle listStyle;

  AtMention({
    required this.teamId,
    required this.cursorPosition,
    required this.isSearch,
    required this.updateValue,
    required this.onShowingChange,
    required this.value,
    required this.nestedScrollEnabled,
    required this.useChannelMentions,
    required this.useGroupMentions,
    required this.isChannelConstrained,
    required this.isTeamConstrained,
    required this.listStyle,
    this.channelId,
  });

  @override
  _AtMentionState createState() => _AtMentionState();
}

class _AtMentionState extends State<AtMention> {
  final _debouncer = Debouncer<String>(Duration(milliseconds: 200));
  final _latestSearchAt = DateTime.now();

  List<SectionListData<dynamic>> sections = [];
  List<UserModel> usersInChannel = [];
  List<UserModel> usersOutOfChannel = [];
  List<GroupModel> groups = [];
  bool loading = false;
  String? noResultsTerm;
  int localCursorPosition = 0;
  bool useLocal = true;
  List<UserModel>? localUsers;
  List<UserModel> filteredLocalUsers = [];

  @override
  void initState() {
    super.initState();
    _debouncer.values.listen((value) {
      runSearch(
        widget.value,
        widget.useGroupMentions,
        widget.isChannelConstrained,
        widget.isTeamConstrained,
        widget.teamId,
        widget.channelId,
      );
    });
  }

  void runSearch(
    String term,
    bool groupMentions,
    bool channelConstrained,
    bool teamConstrained,
    String teamId, [
    String? channelId,
  ]) async {
    final searchAt = DateTime.now();
    _latestSearchAt = searchAt;

    final receivedUsers = await searchUsers(
      Provider.of<ServerUrl>(context, listen: false),
      term,
      teamId,
      channelId,
    );
    final groupsResult = await searchGroups(
      Provider.of<ServerUrl>(context, listen: false),
      term,
      groupMentions,
      channelConstrained,
      teamConstrained,
      channelId: channelId,
      teamId: teamId,
    );

    if (_latestSearchAt.isBefore(searchAt)) {
      return;
    }

    setState(() {
      groups = groupsResult;
      useLocal = receivedUsers == null;
      if (receivedUsers == null) {
        getAllUsers(Provider.of<ServerUrl>(context, listen: false)).then((users) {
          localUsers = users;
          if (_latestSearchAt.isBefore(searchAt)) {
            return;
          }
          filteredLocalUsers = filterResults(users, term);
        });
      } else if (receivedUsers.isNotEmpty) {
        usersInChannel = filterResults(receivedUsers, term);
        usersOutOfChannel = filterResults(receivedUsers, term);
      }
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final matchTerm = getMatchTermForAtMention(
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
                case SECTION_KEY_SPECIAL:
                  return SpecialMentionItem(
                    completeHandle: (item as SpecialMention).completeHandle,
                    defaultMessage: item.defaultMessage,
                    id: item.id,
                    onPress: (mention) => completeMention(mention),
                  );
                case SECTION_KEY_GROUPS:
                  return GroupMentionItem(
                    key: Key('autocomplete-group-${item.name}'),
                    name: item.name,
                    displayName: item.displayName,
                    memberCount: item.memberCount,
                    onPress: (mention) => completeMention(mention),
                  );
                default:
                  return AtMentionItem(
                    user: item,
                    onPress: (mention) => completeMention(mention),
                  );
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
        ? mentionPart.replaceAll(RegExp(AT_MENTION_SEARCH_REGEX), 'from: $mention ')
        : mentionPart.replaceAll(RegExp(AT_MENTION_REGEX), '@$mention ');

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
