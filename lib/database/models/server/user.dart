// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:sqflite/sqflite.dart';
import 'package:mattermost_flutter/types/channel.dart';
import 'package:mattermost_flutter/types/channel_membership.dart';
import 'package:mattermost_flutter/types/post.dart';
import 'package:mattermost_flutter/types/preference.dart';
import 'package:mattermost_flutter/types/reaction.dart';
import 'package:mattermost_flutter/types/team_membership.dart';
import 'package:mattermost_flutter/types/thread_participant.dart';
import 'package:mattermost_flutter/types/user.dart';
import 'package:mattermost_flutter/utils/helpers.dart';

class UserModel {
  static const String table = 'USER';

  static final Map<String, String> associations = {
    'CHANNEL': 'creator_id',
    'CHANNEL_MEMBERSHIP': 'user_id',
    'POST': 'user_id',
    'PREFERENCE': 'user_id',
    'REACTION': 'user_id',
    'TEAM_MEMBERSHIP': 'user_id',
    'THREAD_PARTICIPANT': 'user_id',
  };

  String authService;
  int updateAt;
  int deleteAt;
  String email;
  String firstName;
  bool isBot;
  bool isGuest;
  String lastName;
  int lastPictureUpdate;
  String locale;
  String nickname;
  String position;
  String roles;
  String status;
  String username;
  String? remoteId;
  Map<String, dynamic>? notifyProps;
  Map<String, dynamic>? props;
  Map<String, dynamic>? timezone;
  String termsOfServiceId;
  int termsOfServiceCreateAt;

  UserModel({
    required this.authService,
    required this.updateAt,
    required this.deleteAt,
    required this.email,
    required this.firstName,
    required this.isBot,
    required this.isGuest,
    required this.lastName,
    required this.lastPictureUpdate,
    required this.locale,
    required this.nickname,
    required this.position,
    required this.roles,
    required this.status,
    required this.username,
    required this.remoteId,
    required this.notifyProps,
    required this.props,
    required this.timezone,
    required this.termsOfServiceId,
    required this.termsOfServiceCreateAt,
  });

  void prepareStatus(String status) {
    // Logic to prepare status update
    this.status = status;
  }

  List<UserMentionKey> get mentionKeys {
    List<UserMentionKey> keys = [];

    if (notifyProps == null) {
      return keys;
    }

    if (notifyProps!['mention_keys'] != null) {
      keys.addAll(notifyProps!['mention_keys'].split(',').map((key) => UserMentionKey(key: key)));
    }

    if (notifyProps!['first_name'] == 'true' && firstName.isNotEmpty) {
      keys.add(UserMentionKey(key: firstName, caseSensitive: true));
    }

    if (notifyProps!['channel'] == 'true') {
      keys.add(UserMentionKey(key: '@channel'));
      keys.add(UserMentionKey(key: '@all'));
      keys.add(UserMentionKey(key: '@here'));
    }

    String usernameKey = '@' + username;
    if (keys.indexWhere((key) => key.key == usernameKey) == -1) {
      keys.add(UserMentionKey(key: usernameKey));
    }

    return keys;
  }

  List<UserMentionKey> get userMentionKeys {
    List<UserMentionKey> mentionKeys = this.mentionKeys;

    return mentionKeys.where((m) => m.key != '@all' && m.key != '@channel' && m.key != '@here').toList();
  }

  List<HighlightWithoutNotificationKey> get highlightKeys {
    if (notifyProps == null) {
      return [];
    }

    List<HighlightWithoutNotificationKey> highlightWithoutNotificationKeys = [];

    if (notifyProps!['highlight_keys'] != null && notifyProps!['highlight_keys'].isNotEmpty) {
      notifyProps!['highlight_keys']
          .split(',')
          .forEach((key) {
        if (key.trim().isNotEmpty) {
          highlightWithoutNotificationKeys.add(HighlightWithoutNotificationKey(key: key.trim()));
        }
      });
    }

    return highlightWithoutNotificationKeys;
  }
}

class UserMentionKey {
  String key;
  bool caseSensitive;

  UserMentionKey({required this.key, this.caseSensitive = false});
}

class HighlightWithoutNotificationKey {
  String key;

  HighlightWithoutNotificationKey({required this.key});
}
