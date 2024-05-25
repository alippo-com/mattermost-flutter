
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mattermost_flutter/queries/system.dart';
import 'package:mattermost_flutter/components/team_list/team_list_item.dart';
import 'package:mattermost_flutter/types/database/database.dart';

class TeamListItemWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final database = Provider.of<Database>(context);

    return StreamProvider<String>(
      create: (_) => observeCurrentUserId(database),
      initialData: '',
      child: TeamListItem(),
    );
  }
}

class DatabaseProvider extends StatelessWidget {
  final Widget child;

  DatabaseProvider({required this.child});

  @override
  Widget build(BuildContext context) {
    return Provider<Database>(
      create: (_) => Database(), // Assuming a Database constructor
      child: child,
    );
  }
}

void main() {
  runApp(DatabaseProvider(child: TeamListItemWrapper()));
}
