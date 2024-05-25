import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:provider/provider.dart';
import 'package:mattermost_flutter/types.dart'; // Assuming the types are defined here
import 'package:mattermost_flutter/queries.dart'; // Assuming the queries functions are defined here
import 'package:mattermost_flutter/components/load_channel_error.dart'; // Assuming the LoadChannelsError widget is defined here

class LoadChannelsErrorScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final database = Provider.of<Database>(context);
    final team = observeCurrentTeam(database);

    final teamDisplayName = team.switchMap((t) => Stream.value(t?.displayName));
    final teamId = team.switchMap((t) => Stream.value(t?.id));

    return StreamBuilder(
      stream: CombineLatestStream.list([teamDisplayName, teamId]),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return CircularProgressIndicator();
        }

        final displayName = snapshot.data[0];
        final id = snapshot.data[1];

        return LoadChannelsError(
          teamDisplayName: displayName,
          teamId: id,
        );
      },
    );
  }
}
