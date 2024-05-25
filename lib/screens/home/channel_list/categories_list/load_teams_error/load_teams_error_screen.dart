import 'package:flutter/material.dart';
import 'package:mattermost_flutter/types.dart'; // Assuming the types are defined here
import 'package:mattermost_flutter/queries.dart'; // Assuming the queries functions are defined here
import 'package:mattermost_flutter/components/loading_error.dart'; // Assuming the LoadingError widget is defined here
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';

class LoadTeamsErrorScreen extends StatefulWidget {
  @override
  _LoadTeamsErrorScreenState createState() => _LoadTeamsErrorScreenState();
}

class _LoadTeamsErrorScreenState extends State<LoadTeamsErrorScreen> {
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    final formatMessage = Provider.of<FormatMessage>(context);
    final serverUrl = Provider.of<ServerUrl>(context);
    final serverName = Provider.of<ServerDisplayName>(context);

    Future<void> onRetryTeams() async {
      setState(() {
        loading = true;
      });

      setTeamLoading(serverUrl, true);
      final error = await retryInitialTeamAndChannel(serverUrl);
      setTeamLoading(serverUrl, false);

      if (error != null) {
        setState(() {
          loading = false;
        });
      }
    }

    return LoadingError(
      loading: loading,
      message: formatMessage({'id': 'load_teams_error.message', 'defaultMessage': 'There was a problem loading content for this server.'}),
      onRetry: onRetryTeams,
      title: formatMessage({'id': 'load_teams_error.title', 'defaultMessage': "Couldn't load {serverName}"}, {'serverName': serverName}),
    );
  }
}
