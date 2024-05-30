
import 'package:flutter/material.dart';
import 'package:mattermost_flutter/types/server_context.dart';
import 'package:mattermost_flutter/store/ephemeral_store.dart';
import 'package:mattermost_flutter/components/team_sidebar.dart';
import 'package:provider/provider.dart';

class EnhancedTeamSidebar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final serverUrl = Provider.of<ServerContext>(context).serverUrl;
    final canJoinOtherTeams = EphemeralStore.observeCanJoinOtherTeams(serverUrl);

    return TeamSidebar(canJoinOtherTeams: canJoinOtherTeams);
  }
}
