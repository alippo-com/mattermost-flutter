// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:mattermost_flutter/i18n.dart';
import 'package:mattermost_flutter/utils/key_mirror.dart';

class SnackBarType {
  static const ADD_CHANNEL_MEMBERS = 'ADD_CHANNEL_MEMBERS';
  static const FAVORITE_CHANNEL = 'FAVORITE_CHANNEL';
  static const FOLLOW_THREAD = 'FOLLOW_THREAD';
  static const INFO_COPIED = 'INFO_COPIED';
  static const LINK_COPIED = 'LINK_COPIED';
  static const MESSAGE_COPIED = 'MESSAGE_COPIED';
  static const MUTE_CHANNEL = 'MUTE_CHANNEL';
  static const REMOVE_CHANNEL_USER = 'REMOVE_CHANNEL_USER';
  static const TEXT_COPIED = 'TEXT_COPIED';
  static const UNFAVORITE_CHANNEL = 'UNFAVORITE_CHANNEL';
  static const UNMUTE_CHANNEL = 'UNMUTE_CHANNEL';
  static const UNFOLLOW_THREAD = 'UNFOLLOW_THREAD';
}

class MessageType {
  static const SUCCESS = 'success';
  static const ERROR = 'error';
  static const DEFAULT = 'default';
}

class SnackBarConfig {
  final String id;
  final String defaultMessage;
  final String iconName;
  final bool canUndo;
  final String? type;

  const SnackBarConfig({
    required this.id,
    required this.defaultMessage,
    required this.iconName,
    required this.canUndo,
    this.type,
  });
}

const SNACK_BAR_CONFIG = {
  SnackBarType.ADD_CHANNEL_MEMBERS: SnackBarConfig(
    id: I18n.t('snack.bar.channel.members.added'),
    defaultMessage: '{numMembers, number} {numMembers, plural, one {member} other {members}} added',
    iconName: 'check',
    canUndo: false,
  ),
  SnackBarType.FAVORITE_CHANNEL: SnackBarConfig(
    id: I18n.t('snack.bar.favorited.channel'),
    defaultMessage: 'This channel was favorited',
    iconName: 'star',
    canUndo: true,
  ),
  SnackBarType.FOLLOW_THREAD: SnackBarConfig(
    id: I18n.t('snack.bar.following.thread'),
    defaultMessage: 'Thread followed',
    iconName: 'check',
    canUndo: true,
  ),
  SnackBarType.INFO_COPIED: SnackBarConfig(
    id: I18n.t('snack.bar.info.copied'),
    defaultMessage: 'Info copied to clipboard',
    iconName: 'content-copy',
    canUndo: false,
  ),
  SnackBarType.LINK_COPIED: SnackBarConfig(
    id: I18n.t('snack.bar.link.copied'),
    defaultMessage: 'Link copied to clipboard',
    iconName: 'link-variant',
    canUndo: false,
    type: MessageType.SUCCESS,
  ),
  SnackBarType.MESSAGE_COPIED: SnackBarConfig(
    id: I18n.t('snack.bar.message.copied'),
    defaultMessage: 'Text copied to clipboard',
    iconName: 'content-copy',
    canUndo: false,
  ),
  SnackBarType.MUTE_CHANNEL: SnackBarConfig(
    id: I18n.t('snack.bar.mute.channel'),
    defaultMessage: 'This channel was muted',
    iconName: 'bell-off-outline',
    canUndo: true,
  ),
  SnackBarType.REMOVE_CHANNEL_USER: SnackBarConfig(
    id: I18n.t('snack.bar.remove.user'),
    defaultMessage: '1 member was removed from the channel',
    iconName: 'check',
    canUndo: true,
  ),
  SnackBarType.TEXT_COPIED: SnackBarConfig(
    id: I18n.t('snack.bar.text.copied'),
    defaultMessage: 'Copied to clipboard',
    iconName: 'content-copy',
    canUndo: false,
    type: MessageType.SUCCESS,
  ),
  SnackBarType.UNFAVORITE_CHANNEL: SnackBarConfig(
    id: I18n.t('snack.bar.unfavorite.channel'),
    defaultMessage: 'This channel was unfavorited',
    iconName: 'star-outline',
    canUndo: true,
  ),
  SnackBarType.UNMUTE_CHANNEL: SnackBarConfig(
    id: I18n.t('snack.bar.unmute.channel'),
    defaultMessage: 'This channel was unmuted',
    iconName: 'bell-outline',
    canUndo: true,
  ),
  SnackBarType.UNFOLLOW_THREAD: SnackBarConfig(
    id: I18n.t('snack.bar.unfollow.thread'),
    defaultMessage: 'Thread unfollowed',
    iconName: 'check',
    canUndo: true,
  ),
};

class SnackBarConstants {
  static const SNACK_BAR_TYPE = SnackBarType;
  static const SNACK_BAR_CONFIG = SNACK_BAR_CONFIG;
}