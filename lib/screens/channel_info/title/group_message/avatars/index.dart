import 'package:flutter/material.dart';
import 'package:mattermost_flutter/database/database.dart';
import 'package:mattermost_flutter/queries/servers/user.dart';
import 'package:mattermost_flutter/components/group_avatars.dart';

class GroupAvatarsWrapper extends StatelessWidget {
  final List<String> userIds;

  GroupAvatarsWrapper({required this.userIds});

  @override
  Widget build(BuildContext context) {
    final database = DatabaseProvider.of(context);

    return StreamBuilder<List<User>>(
      stream: queryUsersById(database, userIds).observeWithColumns(['last_picture_update']),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return CircularProgressIndicator();
        }
        return GroupAvatars(users: snapshot.data!);
      },
    );
  }
}
