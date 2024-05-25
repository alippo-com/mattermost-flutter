// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/material.dart';
import 'package:mattermost_flutter/components/user_item.dart';
import 'package:mattermost_flutter/types/user_profile.dart';
import 'package:mattermost_flutter/types/database/models/servers/user.dart';

class AtMentionItem extends StatelessWidget {
  final UserProfile user;
  final Function(String)? onPress;
  final String? testID;

  AtMentionItem({
    required this.user,
    this.onPress,
    this.testID,
  });

  void completeMention(UserProfile u) {
    if (onPress != null) {
      onPress!(u.username);
    }
  }

  @override
  Widget build(BuildContext context) {
    return UserItem(
      user: user,
      testID: testID,
      onUserPress: completeMention,
    );
  }
}
