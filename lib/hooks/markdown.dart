// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/material.dart';
import 'package:mattermost_flutter/utils/user.dart';
import 'package:mattermost_flutter/types/group_model.dart';
import 'package:mattermost_flutter/types/user_model.dart';

UserModel? useMemoMentionedUser(List<UserModel> users, String mentionName) {
  final usersByUsername = getUsersByUsername(users);
  String mn = mentionName.toLowerCase();

  while (mn.isNotEmpty) {
    if (usersByUsername.containsKey(mn)) {
      return usersByUsername[mn];
    }

    // Repeatedly trim off trailing punctuation in case this is at the end of a sentence
    if (RegExp(r'[._-]$').hasMatch(mn)) {
      mn = mn.substring(0, mn.length - 1);
    } else {
      break;
    }
  }

  return null;
}

GroupModel? useMemoMentionedGroup(List<GroupModel> groups, UserModel? user, String mentionName) {
  if (user?.username != null) {
    return null;
  }

  final groupsByName = getGroupsByName(groups);
  String mn = mentionName.toLowerCase();

  while (mn.isNotEmpty) {
    if (groupsByName.containsKey(mn)) {
      return groupsByName[mn];
    }

    // Repeatedly trim off trailing punctuation in case this is at the end of a sentence
    if (RegExp(r'[._-]$').hasMatch(mn)) {
      mn = mn.substring(0, mn.length - 1);
    } else {
      break;
    }
  }

  return null;
}

Map<String, GroupModel> getGroupsByName(List<GroupModel> groups) {
  final Map<String, GroupModel> groupsByName = {};

  for (final g in groups) {
    groupsByName[g.name] = g;
  }

  return groupsByName;
}
