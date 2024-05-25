
import 'package:flutter/material.dart';
import 'package:watermelondb/watermelondb.dart';
import 'package:mattermost_flutter/queries/servers/user.dart';
import 'package:mattermost_flutter/types/database.dart';
import 'group.dart';

class EnhancedGroup extends StatelessWidget {
  final List<String> userIds;
  final Database database;

  EnhancedGroup({required this.userIds, required this.database});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<User>>(
      stream: queryUsersById(database, userIds).observeWithColumns(['last_picture_update']),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        }
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }
        return Group(users: snapshot.data);
      },
    );
  }
}
