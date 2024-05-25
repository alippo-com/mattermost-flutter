// Converted from ./mattermost-mobile/app/screens/channel/channel_post_list/intro/direct_channel/member/member.tsx

import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:mattermost_flutter/components/profile_picture.dart';
import 'package:mattermost_flutter/components/touchable_with_feedback.dart';
import 'package:mattermost_flutter/screens/navigation.dart';
import 'package:mattermost_flutter/constants/screens.dart';
import 'package:mattermost_flutter/types/theme.dart';
import 'package:mattermost_flutter/types/user_model.dart';

class Member extends StatelessWidget {
  final String channelId;
  final BoxDecoration? containerStyle;
  final double size;
  final bool showStatus;
  final Theme theme;
  final UserModel user;

  Member({
    required this.channelId,
    this.containerStyle,
    this.size = 72.0,
    this.showStatus = true,
    required this.theme,
    required this.user,
  });

  void _onPress(BuildContext context) {
    final screen = Screens.USER_PROFILE;
    final title = 'Profile'; // This should be localized
    final closeButtonId = 'close-user-profile';
    final props = {
      'closeButtonId': closeButtonId,
      'userId': user.id,
      'channelId': channelId,
      'location': Screens.CHANNEL,
    };

    KeyboardVisibility.onChange.listen((bool visible) {
      if (!visible) {
        openAsBottomSheet(context, screen, title, theme, closeButtonId, props);
      }
    });

    KeyboardVisibilityController().isVisible = false;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _onPress(context),
      child: Container(
        decoration: containerStyle,
        child: ProfilePicture(
          author: user,
          size: size,
          iconSize: 48.0,
          showStatus: showStatus,
          statusSize: 24.0,
          testID: 'channel_intro.\${user.id}.profile_picture',
        ),
      ),
    );
  }
}
