import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mattermost_flutter/database/database.dart';
import 'package:rxdart/rxdart.dart';

class ManageMembersLabel extends StatelessWidget {
  final bool isDefaultChannel;
  final String userId;

  ManageMembersLabel({required this.isDefaultChannel, required this.userId});

  @override
  Widget build(BuildContext context) {
    final database = Provider.of<AppDatabase>(context);
    final userDao = database.userDao;

    Stream<bool> canRemoveUser = userDao.getUserById(userId).asStream().switchMap((user) {
      return Stream.value(!isDefaultChannel || (isDefaultChannel && user.isGuest));
    });

    return StreamBuilder<bool>(
      stream: canRemoveUser,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        }
        final canRemove = snapshot.data ?? false;
        // Replace this with the actual widget you want to show
        return Text(canRemove ? 'Can Remove User' : 'Cannot Remove User');
      },
    );
  }
}
