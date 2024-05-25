import 'package:flutter/foundation.dart';

@immutable
class UserNotifyProps {
  final String? autoResponderActive;
  final String? autoResponderMessage;
  final bool channel;
  final String comments;
  final String desktop;
  final String? desktopNotificationSound;
  final bool desktopSound;
  final bool email;
  final bool firstName;
  final String? markUnread;
  final String mentionKeys;
  final String highlightKeys;
  final String push;
  final String pushStatus;
  final String? userId;
  final String? pushThreads;
  final String? emailThreads;

  const UserNotifyProps({
    this.autoResponderActive,
    this.autoResponderMessage,
    required this.channel,
    required this.comments,
    required this.desktop,
    this.desktopNotificationSound,
    required this.desktopSound,
    required this.email,
    required this.firstName,
    this.markUnread,
    required this.mentionKeys,
    required this.highlightKeys,
    required this.push,
    required this.pushStatus,
    this.userId,
    this.pushThreads,
    this.emailThreads,
  });
}

@immutable
class UserProfile {
  final String id;
  final int createAt;
  final int updateAt;
  final int deleteAt;
  final String username;
  final String? authData;
  final String authService;
  final String email;
  final bool? emailVerified;
  final String nickname;
  final String firstName;
  final String lastName;
  final String position;
  final String roles;
  final String locale;
  final UserNotifyProps notifyProps;
  final Map<String, dynamic>? props;
  final String? termsOfServiceId;
  final int? termsOfServiceCreateAt;
  final Map<String, String>? timezone;
  final bool? isBot;
  final int? lastPictureUpdate;
  final String? remoteId;
  final String? status;
  final String? botDescription;
  final int? botLastIconUpdate;

  const UserProfile({
    required this.id,
    required this.createAt,
    required this.updateAt,
    required this.deleteAt,
    required this.username,
    this.authData,
    required this.authService,
    required this.email,
    this.emailVerified,
    required this.nickname,
    required this.firstName,
    required this.lastName,
    required this.position,
    required this.roles,
    required this.locale,
    required this.notifyProps,
    this.props,
    this.termsOfServiceId,
    this.termsOfServiceCreateAt,
    this.timezone,
    this.isBot,
    this.lastPictureUpdate,
    this.remoteId,
    this.status,
    this.botDescription,
    this.botLastIconUpdate,
  });
}
