// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:mattermost_flutter/constants.dart';
import 'package:mattermost_flutter/constants/autocomplete.dart';

Set<String> getNeededAtMentionedUsernames(Set<String> usernames, List<Post> posts, {String? excludeUsername}) {
  final Set<String> usernamesToLoad = <String>{};

  void findNeededUsernames(String? text) {
    if (text == null || !text.contains('@')) {
      return;
    }

    RegExpMatch? match;
    while ((match = MENTIONS_REGEX.firstMatch(text)) != null) {
      final String lowercaseMatch = match.group(1)!.toLowerCase();

      if (General.SPECIAL_MENTIONS.contains(lowercaseMatch)) {
        continue;
      }

      if (lowercaseMatch == excludeUsername) {
        continue;
      }

      if (usernames.contains(lowercaseMatch)) {
        continue;
      }

      usernamesToLoad.add(lowercaseMatch);
    }
  }

  for (final Post post in posts) {
    findNeededUsernames(post.message);

    if (post.props?.attachments != null) {
      for (final Attachment attachment in post.props.attachments!) {
        findNeededUsernames(attachment.pretext);
        findNeededUsernames(attachment.text);
      }
    }
  }

  return usernamesToLoad;
}