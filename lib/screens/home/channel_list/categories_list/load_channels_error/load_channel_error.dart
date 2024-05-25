
import 'package:flutter/material.dart';
import 'package:mattermost_flutter/actions/remote/retry.dart';
import 'package:mattermost_flutter/components/loading_error.dart';
import 'package:mattermost_flutter/context/server.dart';
import 'package:mattermost_flutter/store/team_load_store.dart';
import 'package:mattermost_flutter/screens/home/channel_list/categories_list/load_channels_error/load_teams_error.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class LoadChannelsError extends StatefulWidget {
  final String teamDisplayName;
  final String teamId;

  LoadChannelsError({required this.teamDisplayName, required this.teamId});

  @override
  _LoadChannelsErrorState createState() => _LoadChannelsErrorState();
}

class _LoadChannelsErrorState extends State<LoadChannelsError> {
  bool loading = false;

  Future<void> onRetryTeams() async {
    setState(() {
      loading = true;
    });

    final serverUrl = useServerUrl(context);
    setTeamLoading(serverUrl, true);
    final result = await retryInitialChannel(serverUrl, widget.teamId);
    setTeamLoading(serverUrl, false);

    if (result.error != null) {
      setState(() {
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    if (widget.teamId.isEmpty) {
      return LoadTeamsError();
    }

    return LoadingError(
      loading: loading,
      message: localizations.loadChannelsErrorMessage,
      onRetry: onRetryTeams,
      title: localizations.loadChannelsErrorTitle(widget.teamDisplayName),
    );
  }
}
