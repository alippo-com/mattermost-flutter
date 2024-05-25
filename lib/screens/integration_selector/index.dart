
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mattermost_flutter/database/database.dart'; // Adjust the path as necessary
import 'package:mattermost_flutter/queries/system.dart'; // Adjust the path as necessary
import 'package:mattermost_flutter/screens/integration_selector/integration_selector.dart'; // Adjust the path as necessary

class IntegrationSelectorWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final database = Provider.of<Database>(context, listen: false);

    return StreamProvider<CurrentUserTeamData>(
      create: (_) => observeCurrentUserTeamData(database),
      initialData: CurrentUserTeamData(
        currentUserId: '',
        currentTeamId: '',
      ),
      child: IntegrationSelector(),
    );
  }
}

class CurrentUserTeamData {
  final String currentUserId;
  final String currentTeamId;

  CurrentUserTeamData({
    required this.currentUserId,
    required this.currentTeamId,
  });
}

Stream<CurrentUserTeamData> observeCurrentUserTeamData(Database database) async* {
  final currentUserId = await observeCurrentUserId(database);
  final currentTeamId = await observeCurrentTeamId(database);
  yield CurrentUserTeamData(
    currentUserId: currentUserId,
    currentTeamId: currentTeamId,
  );
}
