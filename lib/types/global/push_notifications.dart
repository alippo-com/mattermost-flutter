// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.


class Notification {
  dynamic fireDate;
  String identifier;
  dynamic payload;
  String title;
  String body;
  String sound;
  int badge;
  String type;
  String thread;
}

class NotificationUserInfo {
  bool local;
  bool? test;
}

class NotificationData {
  String? ack_id;
  String? body;
  String channel_id;
  String? channel_name;
  String? identifier;
  String? from_webhook;
  String? message;
  String? override_icon_url;
  String? override_username;
  String post_id;
  String? root_id;
  String? sender_id;
  String? sender_name;
  String? server_id;
  String? server_url;
  String? team_id;
  String type;
  String? sub_type;
  String? use_user_icon;
  NotificationUserInfo? userInfo;
  String version;
  bool isCRTEnabled;
  NotificationExtraData? data;
}

class NotificationExtraData {
  dynamic channel;
  dynamic myChannel;
  dynamic categories;
  dynamic categoryChannels;
  dynamic team;
  dynamic myTeam;
  dynamic users;
  dynamic posts;
  dynamic threads;
}

class NotificationWithData extends Notification {
  NotificationData? payload;
  bool? foreground;
  bool? userInteraction;
}

class NotificationWithChannel extends Notification {
  String? channel_id;
  String? root_id;
}