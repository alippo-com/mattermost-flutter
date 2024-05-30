// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:mattermost_flutter/constants/general.dart';
import 'package:mattermost_flutter/constants/permissions.dart';

import 'package:mattermost_flutter/database/database.dart';
import 'package:mattermost_flutter/queries/channel.dart';
import 'package:mattermost_flutter/queries/role.dart';
import 'package:mattermost_flutter/queries/system.dart';
import 'package:mattermost_flutter/queries/team.dart';
import 'package:mattermost_flutter/queries/user.dart';


class ArchiveScreen extends StatelessWidget {
  final String channelId;
  final String? type;

  ArchiveScreen({required this.channelId, this.type});

  @override
  Widget build(BuildContext context) {
    final database = Provider.of<Database>(context);

    final teamStream = observeCurrentTeam(database).asStream();
    final currentUserStream = observeCurrentUser(database).asStream();
    final channelStream = observeChannel(database, channelId).asStream();
    final canViewArchivedChannelsStream = observeConfigBooleanValue(database, 'ExperimentalViewArchivedChannels').asStream();
    final isArchivedStream = channelStream.switchMap((c) => Stream.value((c?.deleteAt ?? 0) > 0));

    final canLeaveStream = channelStream.switchMap((ch) =>
        currentUserStream.switchMap((u) {
          final isDefaultChannel = ch?.name == General.DEFAULT_CHANNEL;
          return Stream.value(!isDefaultChannel || (isDefaultChannel && u?.isGuest));
        })
    );

    final canArchiveStream = channelStream.switchMap((ch) =>
        currentUserStream.switchMap((u) =>
            canLeaveStream.switchMap((leave) =>
                isArchivedStream.switchMap((archived) {
                  if (type == General.DM_CHANNEL || type == General.GM_CHANNEL || ch == null || u == null || !leave || archived) {
                    return Stream.value(false);
                  }

                  if (type == General.OPEN_CHANNEL) {
                    return observePermissionForChannel(database, ch, u, Permissions.DELETE_PUBLIC_CHANNEL, true).asStream();
                  }

                  return observePermissionForChannel(database, ch, u, Permissions.DELETE_PRIVATE_CHANNEL, true).asStream();
                })
            )
        )
    );

    final canUnarchiveStream = teamStream.switchMap((t) =>
        currentUserStream.switchMap((u) =>
            isArchivedStream.switchMap((archived) {
              if (type == General.DM_CHANNEL || type == General.GM_CHANNEL || t == null || u == null || !archived) {
                return Stream.value(false);
              }

              return observePermissionForTeam(database, t, u, Permissions.MANAGE_TEAM, false).asStream();
            })
        )
    );

    final displayNameStream = channelStream.switchMap((c) => Stream.value(c?.displayName));

    return StreamBuilder(
      stream: CombineLatestStream.list([
        canArchiveStream,
        canUnarchiveStream,
        canViewArchivedChannelsStream,
        displayNameStream,
      ]),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return CircularProgressIndicator();
        }

        final data = snapshot.data as List<dynamic>;
        final canArchive = data[0];
        final canUnarchive = data[1];
        final canViewArchivedChannels = data[2];
        final displayName = data[3];

        return Archive(
          canArchive: canArchive,
          canUnarchive: canUnarchive,
          canViewArchivedChannels: canViewArchivedChannels,
          displayName: displayName,
        );
      },
    );
  }
}
