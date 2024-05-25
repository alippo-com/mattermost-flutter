import 'package:flutter/material.dart';
import 'package:mattermost_flutter/components/profile_picture/image.dart';
import 'package:mattermost_flutter/types/user_model.dart';

class UserAvatar extends StatelessWidget {
  final BoxDecoration? style;
  final UserModel user;

  UserAvatar({required this.style, required this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      key: Key(user.id),
      decoration: style,
      child: ProfilePicture(
        author: user,
        size: 24,
      ),
    );
  }
}
