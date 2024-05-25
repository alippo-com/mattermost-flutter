
// Import necessary packages
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mattermost_flutter/database/database.dart';
import 'package:mattermost_flutter/queries/servers/system.dart';
import 'package:mattermost_flutter/queries/servers/team.dart';
import 'package:mattermost_flutter/screens/home/search/search_screen.dart';

class Enhance extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final database = Provider.of<Database>(context);
    final currentTeamId = observeCurrentTeamId(database);
    final teamsStream = queryJoinedTeams(database).observe();

    return StreamBuilder(
      stream: teamsStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return CircularProgressIndicator();
        }

        final teams = snapshot.data;

        return SearchScreen(
          teamId: currentTeamId,
          teams: teams,
        );
      },
    );
  }
}

class DatabaseProvider extends StatelessWidget {
  final Widget child;

  DatabaseProvider({required this.child});

  @override
  Widget build(BuildContext context) {
    return Provider<Database>(
      create: (context) => Database(),
      child: child,
    );
  }
}

void main() {
  runApp(
    DatabaseProvider(
      child: Enhance(),
    ),
  );
}
