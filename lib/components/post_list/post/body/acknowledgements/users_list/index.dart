
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mattermost_flutter/components/post_list/post/body/acknowledgements/users_list/users_list.dart';

class UsersListProvider extends StatelessWidget {
  final List<String> userIds;

  UsersListProvider({required this.userIds});

  @override
  Widget build(BuildContext context) {
    return StreamProvider(
      create: (_) => queryUsersById(context.read<Database>(), userIds).asStream(),
      initialData: [],
      child: UsersList(),
    );
  }
}

Stream<List<User>> queryUsersById(Database database, List<String> userIds) {
  // Implement the query logic to fetch users by their IDs
  // This is a placeholder implementation
  return database.userDao.findUsersByIds(userIds).watch();
}
