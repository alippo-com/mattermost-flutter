
// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/material.dart';
import 'package:mattermost_flutter/components/compass_icon.dart';
import 'package:mattermost_flutter/components/emoji.dart';
import 'package:mattermost_flutter/components/profile_picture.dart';
import 'package:mattermost_flutter/utils/theme.dart';
import 'package:mattermost_flutter/types/calls.dart';
import 'package:mattermost_flutter/types/emoji_data.dart';
import 'package:mattermost_flutter/models/servers/user.dart';

class CallAvatar extends StatelessWidget {
  final UserModel? userModel;
  final bool speaking;
  final String serverUrl;
  final double size;
  final bool? muted;
  final bool? sharingScreen;
  final bool? raisedHand;
  final EmojiData? reaction;

  const CallAvatar({
    Key? key,
    this.userModel,
    this.speaking = false,
    required this.serverUrl,
    required this.size,
    this.muted,
    this.sharingScreen,
    this.raisedHand,
    this.reaction,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final callsTheme = makeCallsTheme(theme);
    final style = _getStyleSheet(callsTheme);

    final iconSize = size <= 72 ? 18.0 : 24.0;
    final reactionSize = size <= 72 ? 22.0 : 28.0;

    Widget? topRightIcon;
    if (sharingScreen == true) {
      topRightIcon = Positioned(
        top: -5,
        right: -8,
        child: Container(
          width: reactionSize,
          height: reactionSize,
          decoration: BoxDecoration(
            color: theme.callsBg,
            borderRadius: BorderRadius.circular(reactionSize / 2),
          ),
          child: CompassIcon(
            name: 'monitor',
            size: reactionSize,
            style: style['reaction']!.copyWith(color: theme.buttonColor),
          ),
        ),
      );
    } else if (raisedHand == true) {
      topRightIcon = Positioned(
        top: -5,
        right: -8,
        child: Container(
          width: reactionSize,
          height: reactionSize,
          decoration: BoxDecoration(
            color: theme.callsBg,
            borderRadius: BorderRadius.circular(reactionSize / 2),
          ),
          child: CompassIcon(
            name: 'hand-right',
            size: reactionSize,
            style: style['reaction']!.copyWith(color: theme.awayIndicator),
          ),
        ),
      );
    }

    if (reaction != null) {
      topRightIcon = Positioned(
        top: -5,
        right: -8,
        child: Container(
          width: reactionSize,
          height: reactionSize,
          decoration: BoxDecoration(
            color: theme.callsBg,
            borderRadius: BorderRadius.circular(reactionSize / 2),
          ),
          child: Emoji(
            emojiName: reaction!.name,
            literal: reaction!.literal,
            size: reactionSize - 4,
            style: style['emoji'],
          ),
        ),
      );
    }

    final profile = userModel != null
        ? ProfilePicture(
            author: userModel!,
            size: size,
            showStatus: false,
            url: serverUrl,
          )
        : CompassIcon(
            name: 'account-outline',
            size: size,
            style: style['profileIcon'],
          );

    return Container(
      width: size + 12,
      height: size + 12,
      alignment: Alignment.center,
      child: Stack(
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(size / 2),
              boxShadow: speaking
                  ? [
                      BoxShadow(
                        color: theme.onlineIndicator.withOpacity(0.24),
                        blurRadius: 12,
                      ),
                      BoxShadow(
                        color: theme.onlineIndicator.withOpacity(0.32),
                        blurRadius: 6,
                      ),
                    ]
                  : [],
            ),
            child: ClipOval(
              child: profile,
            ),
          ),
          if (muted != null)
            Positioned(
              bottom: 0,
              right: -5,
              child: Container(
                width: iconSize + 10,
                height: iconSize + 10,
                decoration: BoxDecoration(
                  color: theme.callsBg,
                  borderRadius: BorderRadius.circular((iconSize + 10) / 2),
                ),
                child: CompassIcon(
                  name: muted! ? 'microphone-off' : 'microphone',
                  size: iconSize,
                  style: style['muteIcon']!.copyWith(
                    color: muted! ? theme.buttonColor : theme.onlineIndicator,
                  ),
                ),
              ),
            ),
          if (topRightIcon != null) topRightIcon,
        ],
      ),
    );
  }

  Map<String, TextStyle> _getStyleSheet(CallsTheme theme) {
    final mediumIcon = size <= 72;
    final muteWidthHeight = mediumIcon ? 28.0 : 36.0;
    final muteBorderRadius = mediumIcon ? 14.0 : 18.0;
    final reactWidthHeight = mediumIcon ? 32.0 : 40.0;
    final reactBorderRadius = mediumIcon ? 16.0 : 20.0;

    return {
      'profileIcon': TextStyle(
        color: theme.buttonColor.withOpacity(0.56),
      ),
      'muteIcon': TextStyle(
        color: theme.buttonColor,
        backgroundColor: theme.buttonColor.withOpacity(0.16),
      ),
      'reaction': TextStyle(
        backgroundColor: theme.buttonColor.withOpacity(0.16),
      ),
      'emoji': TextStyle(
        paddingLeft: mediumIcon ? 4.0 : 6.0,
        paddingTop: mediumIcon ? 5.0 : 3.0,
      ),
    };
  }
}
