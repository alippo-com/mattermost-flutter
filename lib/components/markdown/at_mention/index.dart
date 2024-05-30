
import 'package:flutter/material.dart';
import 'package:mattermost_flutter/database/database.dart';
import 'package:mattermost_flutter/queries/system.dart';
import 'package:mattermost_flutter/queries/user.dart';
import 'package:provider/provider.dart';

class AtMentionProvider extends StatelessWidget {
  final String mentionName;
  final Database database;

  AtMentionProvider({
    required this.mentionName,
    required this.database,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        StreamProvider<String>(
          create: (_) => observeCurrentUserId(database),
          initialData: '',
        ),
        StreamProvider<String>(
          create: (_) => observeTeammateNameDisplay(database),
          initialData: '',
        ),
        StreamProvider<List<User>>(
          create: (_) => queryUsersLike(database, mentionName.toLowerCase()).watch(),
          initialData: [],
        ),
        StreamProvider<List<Group>>(
          create: (_) => queryGroupsByName(database, mentionName.toLowerCase()).watch(),
          initialData: [],
        ),
        StreamProvider<List<GroupMembership>>(
          create: (context) => observeCurrentUserId(database).switchMap(
            (userId) => queryGroupMembershipForMember(database, userId).watch(),
          ),
          initialData: [],
        ),
      ],
      child: AtMention(),
    );
  }
}
