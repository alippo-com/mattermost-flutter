import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mattermost_flutter/types/database.dart';
import 'package:mattermost_flutter/queries/servers/user.dart';
import 'member.dart';

class EnhancedMember extends StatelessWidget {
  final ChannelMembershipModel member;

  EnhancedMember({required this.member});

  @override
  Widget build(BuildContext context) {
    final database = Provider.of<Database>(context);

    final user = observeUser(database, member.userId);

    return Member(user: user);
  }
}

class WithDatabase extends StatelessWidget {
  final Widget child;

  WithDatabase({required this.child});

  @override
  Widget build(BuildContext context) {
    return Provider<Database>(
      create: (_) => Database(),
      child: child,
    );
  }
}

void main() {
  runApp(
    WithDatabase(
      child: EnhancedMember(
        member: ChannelMembershipModel(userId: 'some_user_id'), // Replace with actual member data
      ),
    ),
  );
}
