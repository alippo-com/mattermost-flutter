// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:mattermost_flutter/actions/remote/channel.dart';
import 'package:mattermost_flutter/actions/remote/user.dart';
import 'package:mattermost_flutter/constants/apps.dart';
import 'package:mattermost_flutter/types/autocomplete_suggestion.dart';
import 'package:mattermost_flutter/types/user_profile.dart';
import 'package:mattermost_flutter/types/channel.dart';

Future<List<AutocompleteSuggestion>?> inTextMentionSuggestions(
    String serverUrl, String pretext, String channelID, String teamID, [String delimiter = '']) async {
  final separatedWords = pretext.split(' ');
  final incompleteLessLastWord = separatedWords.sublist(0, separatedWords.length - 1).join(' ');
  final lastWord = separatedWords.last;
  if (lastWord.startsWith('@')) {
    final res = await searchUsers(serverUrl, lastWord.substring(1), teamID, channelID);
    final users = await getUserSuggestions(usersAutocomplete: res.users);
    users.forEach((u) {
      var complete = incompleteLessLastWord.isNotEmpty ? '$incompleteLessLastWord ${u.Complete}' : u.Complete;
      if (delimiter.isNotEmpty) {
        complete = '$delimiter$complete';
      }
      u.Complete = complete;
    });
    return users;
  }

  if (lastWord.startsWith('~') && !lastWord.startsWith('~~')) {
    final res = await searchChannels(serverUrl, lastWord.substring(1), teamID);
    final channels = await getChannelSuggestions(channels: res.channels);
    channels.forEach((c) {
      var complete = incompleteLessLastWord.isNotEmpty ? '$incompleteLessLastWord ${c.Complete}' : c.Complete;
      if (delimiter isNotEmpty) {
        complete = '$delimiter$complete';
      }
      c.Complete = complete;
    });
    return channels;
  }

  return null;
}

Future<List<AutocompleteSuggestion>> getUserSuggestions({required Map<String, dynamic> usersAutocomplete}) async {
  final notFoundSuggestions = [
    AutocompleteSuggestion(Complete: '', Suggestion: '', Description: 'No user found', Hint: '', IconData: '')
  ];
  if (usersAutocomplete isEmpty) {
    return notFoundSuggestions;
  }

  if (usersAutocomplete['users'].isEmpty && (usersAutocomplete['out_of_channel']?.isEmpty ?? true)) {
    return notFoundSuggestions;
  }

  final items = <AutocompleteSuggestion>[];
  usersAutocomplete['users'].forEach((u) {
    items.add(getUserSuggestion(UserProfile.fromJson(u)));
  });
  usersAutocomplete['out_of_channel']?.forEach((u) {
    items.add(getUserSuggestion(UserProfile.fromJson(u)));
  });

  return items;
}

Future<List<AutocompleteSuggestion>> getChannelSuggestions({required List<dynamic> channels}) async {
  final notFoundSuggestion = [
    AutocompleteSuggestion(Complete: '', Suggestion: '', Description: 'No channel found', Hint: '', IconData: '')
  ];
  if (channels.isEmpty) {
    return notFoundSuggestion;
  }

  final items = channels.map((c) {
    final channel = Channel.fromJson(c);
    return AutocompleteSuggestion(
      Complete: '~${channel.name}',
      Suggestion: '',
      Description: '',
      Hint: '',
      IconData: '',
      type: COMMAND_SUGGESTION_CHANNEL,
      item: channel,
    );
  }).toList();

  return items;
}

AutocompleteSuggestion getUserSuggestion(UserProfile u) {
  return AutocompleteSuggestion(
    Complete: '@${u.username}',
    Suggestion: '',
    Description: '',
    Hint: '',
    IconData: '',
    type: COMMAND_SUGGESTION_USER,
    item: u,
  );
}
