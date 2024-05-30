import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mattermost_flutter/constants/autocomplete.dart';
import 'package:mattermost_flutter/queries/servers/channel.dart';
import 'package:mattermost_flutter/components/autocomplete/channel_mention/channel_mention.dart';

class ChannelMentionProvider extends StatelessWidget {
  final String value;
  final bool isSearch;
  final int cursorPosition;
  final String teamId;

  ChannelMentionProvider({
    required this.value,
    required this.isSearch,
    required this.cursorPosition,
    required this.teamId,
  });

  @override
  Widget build(BuildContext context) {
    final database = Provider.of<Database>(context);

    final matchPattern = isSearch
        ? Observable.just(CHANNEL_MENTION_SEARCH_REGEX)
        : observeConfigBooleanValue(database, 'DelayChannelAutocomplete')
            .map((c) => c ? CHANNEL_MENTION_REGEX_DELAYED : CHANNEL_MENTION_REGEX);

    final matchTerm = matchPattern.map((regexp) {
      return getMatchTermForChannelMention(value.substring(0, cursorPosition), regexp, isSearch);
    });

    final localChannels = matchTerm.switchMap((term) {
      return term == null
          ? Observable.just([])
          : queryChannelsForAutocomplete(database, term, isSearch, teamId).asObservable();
    });

    return ChannelMention(
      matchTerm: matchTerm,
      localChannels: localChannels,
    );
  }

  String? getMatchTermForChannelMention(String value, RegExp matchPattern, bool isSearch) {
    // Implementation of getMatchTermForChannelMention function in Dart
    RegExpMatch? match = matchPattern.firstMatch(value);
    if (match != null) {
      if (isSearch) {
        return match.group(1)?.toLowerCase();
      } else if (match.start > 0 && value[match.start - 1] == '~') {
        return null;
      } else {
        return match.group(2)?.toLowerCase();
      }
    }
    return null;
  }
}
