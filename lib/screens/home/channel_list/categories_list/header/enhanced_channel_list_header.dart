
// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:mattermost_flutter/constants.dart';
import 'package:mattermost_flutter/queries/servers/role.dart';
import 'package:mattermost_flutter/queries/servers/system.dart';
import 'package:mattermost_flutter/queries/servers/team.dart';
import 'package:mattermost_flutter/queries/servers/user.dart';
import 'package:mattermost_flutter/screens/home/channel_list/categories_list/header/channel_list_header.dart';
import 'package:mattermost_flutter/types/database/database.dart';

class EnhancedChannelListHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final database = Provider.of<Database>(context);

    final teamStream = observeCurrentTeam(database);
    final currentUserStream = observeCurrentUser(database);
    final enableOpenServerStream = observeConfigBooleanValue(database, 'EnableOpenServer');

    final canJoinChannelsStream = Rx.combineLatest2(currentUserStream, teamStream, (u, t) {
      return observePermissionForTeam(database, t, u, Permissions.JOIN_PUBLIC_CHANNELS, true);
    }).distinct();

    final canCreatePublicChannelsStream = Rx.combineLatest2(currentUserStream, teamStream, (u, t) {
      return observePermissionForTeam(database, t, u, Permissions.CREATE_PUBLIC_CHANNEL, true);
    });

    final canCreatePrivateChannelsStream = Rx.combineLatest2(currentUserStream, teamStream, (u, t) {
      return observePermissionForTeam(database, t, u, Permissions.CREATE_PRIVATE_CHANNEL, false);
    });

    final canCreateChannelsStream = Rx.combineLatest2(canCreatePublicChannelsStream, canCreatePrivateChannelsStream, (open, priv) {
      return open || priv;
    }).distinct();

    final canAddUserToTeamStream = Rx.combineLatest2(currentUserStream, teamStream, (u, t) {
      return observePermissionForTeam(database, t, u, Permissions.ADD_USER_TO_TEAM, false);
    });

    final canInvitePeopleStream = Rx.combineLatest2(enableOpenServerStream, canAddUserToTeamStream, (openServer, addUser) {
      return openServer && addUser;
    }).distinct();

    final displayNameStream = teamStream.switchMap((t) => Rx.of(t?.displayName)).distinct();

    final pushProxyStatusStream = observePushVerificationStatus(database);

    return StreamBuilder(
      stream: Rx.combineLatest6(
        canCreateChannelsStream,
        canJoinChannelsStream,
        canInvitePeopleStream,
        displayNameStream,
        pushProxyStatusStream,
        (canCreateChannels, canJoinChannels, canInvitePeople, displayName, pushProxyStatus) {
          return {
            'canCreateChannels': canCreateChannels,
            'canJoinChannels': canJoinChannels,
            'canInvitePeople': canInvitePeople,
            'displayName': displayName,
            'pushProxyStatus': pushProxyStatus,
          };
        },
      ),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return CircularProgressIndicator();
        }

        final data = snapshot.data;
        return ChannelListHeader(
          canCreateChannels: data['canCreateChannels'],
          canJoinChannels: data['canJoinChannels'],
          canInvitePeople: data['canInvitePeople'],
          displayName: data['displayName'],
          pushProxyStatus: data['pushProxyStatus'],
        );
      },
    );
  }
}
