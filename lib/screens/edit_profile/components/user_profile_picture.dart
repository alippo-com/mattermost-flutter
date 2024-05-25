
import 'package:flutter/material.dart';
import 'package:mattermost_flutter/components/profile_picture.dart';
import 'package:mattermost_flutter/constants/profile.dart';
import 'edit_profile_picture.dart';
import 'package:mattermost_flutter/types/database/models/servers/user.dart';
import 'package:mattermost_flutter/types/screens/edit_profile.dart';

class UserProfilePicture extends StatelessWidget {
  final UserModel currentUser;
  final bool lockedPicture;
  final Function(NewProfileImage) onUpdateProfilePicture;

  UserProfilePicture({
    required this.currentUser,
    required this.lockedPicture,
    required this.onUpdateProfilePicture,
  });

  @override
  Widget build(BuildContext context) {
    if (lockedPicture) {
      return ProfilePicture(
        author: currentUser,
        size: USER_PROFILE_PICTURE_SIZE,
        showStatus: false,
        testID: 'edit_profile.${currentUser.id}.profile_picture',
      );
    }

    return EditProfilePicture(
      onUpdateProfilePicture: onUpdateProfilePicture,
      user: currentUser,
    );
  }
}
