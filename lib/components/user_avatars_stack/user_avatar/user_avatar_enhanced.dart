// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/material.dart';
import 'package:watermelondb/watermelondb.dart';
import 'package:mattermost_flutter/components/user_avatars_stack/user_avatar/user_avatar.dart';

class UserAvatarEnhanced extends StatelessWidget {
  final UserModel user;

  const UserAvatarEnhanced({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<UserModel>(
      stream: user.observe(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return CircularProgressIndicator();
        }

        return UserAvatar(user: snapshot.data!);
      },
    );
  }
}
