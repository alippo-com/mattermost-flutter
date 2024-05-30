import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mattermost_flutter/database/database.dart';
import 'package:mattermost_flutter/queries/team.dart';
import 'package:mattermost_flutter/queries/user.dart';
import 'invite.dart';

class EnhancedInvite extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final database = Provider.of<Database>(context);
    final team = observeCurrentTeam(database);

    return StreamProvider.value(
      value: team,
      initialData: null,
      child: Consumer<Database>(
        builder: (context, database, child) {
          final teamId = team.switchMap((t) => t?.id);
          final teamDisplayName = team.switchMap((t) => t?.displayName);
          final teamLastIconUpdate = team.switchMap((t) => t?.lastTeamIconUpdatedAt);
          final teamInviteId = team.switchMap((t) => t?.inviteId);
          final teammateNameDisplay = observeTeammateNameDisplay(database);
          final isAdmin = observeCurrentUser(database).map(
            (user) => isSystemAdmin(user?.roles ?? ''),
          ).distinct();

          return Invite(
            teamId: teamId,
            teamDisplayName: teamDisplayName,
            teamLastIconUpdate: teamLastIconUpdate,
            teamInviteId: teamInviteId,
            teammateNameDisplay: teammateNameDisplay,
            isAdmin: isAdmin,
          );
        },
      ),
    );
  }
}
