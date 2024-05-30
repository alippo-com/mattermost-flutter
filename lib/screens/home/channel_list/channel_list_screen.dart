// Mattermost Flutter - Channel List Screen
import 'package:flutter/material.dart';
import 'package:mattermost_flutter/database/database.dart';
import 'package:rxdart/rxdart.dart';
import 'package:mattermost_flutter/components/channel_list.dart';
import 'package:mattermost_flutter/queries/channel.dart';
import 'package:mattermost_flutter/queries/system.dart';
import 'package:mattermost_flutter/queries/team.dart';
import 'package:mattermost_flutter/queries/terms_of_service.dart';
import 'package:mattermost_flutter/queries/thread.dart';
import 'package:mattermost_flutter/queries/user.dart';
import 'package:mattermost_flutter/state/calls.dart';

class ChannelListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final database = DatabaseProvider.of(context);

    final isLicensed = observeLicense(database).switchMap((lcs) => lcs != null ? Stream.value(lcs.isLicensed == 'true') : Stream.value(false));

    final teamsCount = queryMyTeams(database).observeCount(false);

    final showIncomingCalls = observeIncomingCalls().switchMap((ics) => Stream.value(ics.incomingCalls.isNotEmpty)).distinct();

    return StreamBuilder(
      stream: CombineLatestStream.combine7(
        observeIsCRTEnabled(database),
        teamsCount.switchMap((v) => Stream.value(v > 0)).distinct(),
        teamsCount.switchMap((v) => Stream.value(v > 1)).distinct(),
        observeCurrentTeamId(database).switchMap((id) => id != null ? queryAllMyChannelsForTeam(database, id).observeCount(false) : Stream.value(0)).switchMap((v) => Stream.value(v > 0)).distinct(),
        isLicensed,
        observeShowToS(database),
        observeCurrentUserId(database).switchMap((id) => observeCurrentUser(database).switchMap((u) => Stream.value(u != null))).distinct(),
        (isCRTEnabled, hasTeams, hasMoreThanOneTeam, hasChannels, isLicensed, showToS, hasCurrentUser) {
          return {
            'isCRTEnabled': isCRTEnabled,
            'hasTeams': hasTeams,
            'hasMoreThanOneTeam': hasMoreThanOneTeam,
            'hasChannels': hasChannels,
            'isLicensed': isLicensed,
            'showToS': showToS,
            'hasCurrentUser': hasCurrentUser,
            'showIncomingCalls': showIncomingCalls,
          };
        },
      ),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return CircularProgressIndicator();
        }

        final data = snapshot.data;
        return ChannelsList(
          isCRTEnabled: data['isCRTEnabled'],
          hasTeams: data['hasTeams'],
          hasMoreThanOneTeam: data['hasMoreThanOneTeam'],
          hasChannels: data['hasChannels'],
          isLicensed: data['isLicensed'],
          showToS: data['showToS'],
          hasCurrentUser: data['hasCurrentUser'],
          showIncomingCalls: data['showIncomingCalls'],
        );
      },
    );
  }
}
