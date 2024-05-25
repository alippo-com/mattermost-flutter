
// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:mattermost_flutter/mattermost_flutter.dart';

class PostsInChannel {
  static const String tableName = 'posts_in_channel';
  final String channelId;
  final int earliest;
  final int latest;

  PostsInChannel({required this.channelId, required this.earliest, required this.latest});

  static final columns = [
    'channel_id',
    'earliest',
    'latest'
  ];

  Map<String, dynamic> toMap() {
    return {
      'channel_id': channelId,
      'earliest': earliest,
      'latest': latest,
    };
  }

  static PostsInChannel fromMap(Map<String, dynamic> map) {
    return PostsInChannel(
      channelId: map['channel_id'],
      earliest: map['earliest'],
      latest: map['latest'],
    );
  }
}
