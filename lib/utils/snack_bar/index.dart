
// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:mattermost_flutter/constants.dart';
import 'package:mattermost_flutter/types/screens/navigation.dart';
import 'package:mattermost_flutter/types/react_intl.dart';

typedef PrimitiveType = Object; // Assuming PrimitiveType is an alias for Object

class ShowSnackBarArgs {
  final SNACK_BAR_TYPE barType;
  final void Function()? onAction;
  final AvailableScreens? sourceScreen;
  final Map<String, PrimitiveType>? messageValues;

  ShowSnackBarArgs({
    required this.barType,
    this.onAction,
    this.sourceScreen,
    this.messageValues,
  });
}

void showSnackBar(ShowSnackBarArgs passProps) {
  const screen = Screens.SNACK_BAR;
  showOverlay(screen, passProps);
}

void showMuteChannelSnackbar(bool muted, void Function() onAction) {
  showSnackBar(ShowSnackBarArgs(
    onAction: onAction,
    barType: muted ? SNACK_BAR_TYPE.MUTE_CHANNEL : SNACK_BAR_TYPE.UNMUTE_CHANNEL,
  ));
}

void showFavoriteChannelSnackbar(bool favorited, void Function() onAction) {
  showSnackBar(ShowSnackBarArgs(
    onAction: onAction,
    barType: favorited ? SNACK_BAR_TYPE.FAVORITE_CHANNEL : SNACK_BAR_TYPE.UNFAVORITE_CHANNEL,
  ));
}

void showAddChannelMembersSnackbar(int count) {
  showSnackBar(ShowSnackBarArgs(
    barType: SNACK_BAR_TYPE.ADD_CHANNEL_MEMBERS,
    sourceScreen: Screens.CHANNEL_ADD_MEMBERS,
    messageValues: {'numMembers': count},
  ));
}

void showRemoveChannelUserSnackbar() {
  showSnackBar(ShowSnackBarArgs(
    barType: SNACK_BAR_TYPE.REMOVE_CHANNEL_USER,
    sourceScreen: Screens.MANAGE_CHANNEL_MEMBERS,
  ));
}

void showThreadFollowingSnackbar(bool following, void Function() onAction) {
  showSnackBar(ShowSnackBarArgs(
    onAction: onAction,
    barType: following ? SNACK_BAR_TYPE.FOLLOW_THREAD : SNACK_BAR_TYPE.UNFOLLOW_THREAD,
  ));
}
