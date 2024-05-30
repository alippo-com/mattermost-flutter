// Converted from ./mattermost-mobile/app/screens/channel/channel_post_list/intro/index.ts

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mattermost_flutter/database/database.dart';
import 'package:mattermost_flutter/queries/servers/channel.dart';
import 'package:mattermost_flutter/queries/servers/user.dart';
import 'package:mattermost_flutter/screens/channel/channel_post_list/intro/intro.dart';
import 'package:mattermost_flutter/utils/types.dart';
import 'package:rxdart/rxdart.dart';

class IntroContainer extends StatelessWidget {
  final String channelId;
  
  IntroContainer({required this.channelId});

  @override
  Widget build(BuildContext context) {
    final database = Provider.of<Database>(context);

    final channelStream = observeChannel(database, channelId);
    final myChannelRolesStream = observeMyChannelRoles(database, channelId);
    final meRolesStream = observeCurrentUserRoles(database);

    final rolesStream = CombineLatestStream.combine2(
      meRolesStream,
      myChannelRolesStream,
      (String? userRoles, String? memberRoles) {
        final combinedRoles = <String>[];
        if (userRoles != null) {
          combinedRoles.addAll(userRoles.split(' '));
        }
        if (memberRoles != null) {
          combinedRoles.addAll(memberRoles.split(' '));
        }
        return queryRolesByNames(database, combinedRoles).map((roles) => roles.map((role) => role.permissions).toList());
      },
    );

    return StreamBuilder(
      stream: CombineLatestStream.combine2(channelStream, rolesStream, (channel, roles) => {'channel': channel, 'roles': roles}),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return CircularProgressIndicator();
        }

        final data = snapshot.data as Map<String, dynamic>;
        final channel = data['channel'];
        final roles = data['roles'];

        return Intro(channel: channel, roles: roles);
      },
    );
  }
}

