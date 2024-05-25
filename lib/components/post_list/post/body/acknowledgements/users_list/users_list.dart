// Dart Code
// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/material.dart';
import 'package:flutter_bottom_sheet/flutter_bottom_sheet.dart';
import 'package:provider/provider.dart';

import 'package:mattermost_flutter/hooks/device.dart';
import 'package:mattermost_flutter/components/post_list/post/body/acknowledgements/users_list/user_list_item.dart';
import 'package:mattermost_flutter/types/database/models/servers/user.dart';
import 'package:mattermost_flutter/types/database/models/user_timezone.dart';

class UsersList extends StatelessWidget {
  final String channelId;
  final String location;
  final List<UserModel> users;
  final Map<String, int> userAcknowledgements;
  final UserTimezone? timezone;

  UsersList({
    required this.channelId,
    required this.location,
    required this.users,
    required this.userAcknowledgements,
    this.timezone,
  });

  @override
  Widget build(BuildContext context) {
    final isTablet = useIsTablet();

    Widget renderUserListItem(UserModel item) {
      return UserListItem(
        channelId: channelId,
        location: location,
        user: item,
        userAcknowledgement: userAcknowledgements[item.id] ?? 0,
        timezone: timezone,
      );
    }

    if (isTablet) {
      return ListView.builder(
        itemCount: users.length,
        itemBuilder: (context, index) {
          return renderUserListItem(users[index]);
        },
      );
    }

    return BottomSheetListView(
      itemCount: users.length,
      itemBuilder: (context, index) {
        return renderUserListItem(users[index]);
      },
    );
  }
}
