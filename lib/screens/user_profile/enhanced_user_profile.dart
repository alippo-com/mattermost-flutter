import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';

import 'package:mattermost_flutter/constants/general.dart';
import 'package:mattermost_flutter/helpers/api/preference.dart';
import 'package:mattermost_flutter/queries/servers/channel.dart';
import 'package:mattermost_flutter/queries/servers/preference.dart';
import 'package:mattermost_flutter/queries/servers/role.dart';
import 'package:mattermost_flutter/queries/servers/system.dart';
import 'package:mattermost_flutter/queries/servers/user.dart';
import 'package:mattermost_flutter/utils/user.dart';
import 'package:mattermost_flutter/types/screens/user_profile.dart';
import 'package:mattermost_flutter/components/user_profile.dart';

class EnhancedUserProfile extends StatelessWidget {
  final String userId;
  final String? channelId;

  EnhancedUserProfile({required this.userId, this.channelId});

  @override
  Widget build(BuildContext context) {
    final database = Provider.of<Database>(context);

    final currentUser = observeCurrentUser(database);
    final currentUserId = observeCurrentUserId(database);
    final channel = channelId != null ? observeChannel(database, channelId!) : Stream.value(null);
    final user = observeUser(database, userId);
    final teammateDisplayName = observeTeammateNameDisplay(database);
    final isChannelAdmin = channelId != null ? observeUserIsChannelAdmin(database, userId, channelId!) : Stream.value(false);
    final isDefaultChannel = channel.switchMap((c) => Stream.value(c?.name == General.DEFAULT_CHANNEL));
    final isDirectMessage = channelId != null ? channel.switchMap((c) => Stream.value(c?.type == General.DM_CHANNEL)) : Stream.value(false);
    final teamId = channel.switchMap((c) => c?.teamId != null ? Stream.value(c.teamId) : observeCurrentTeamId(database));
    final isTeamAdmin = teamId.switchMap((id) => observeUserIsTeamAdmin(database, userId, id));
    final systemAdmin = user.switchMap((u) => Stream.value(u?.roles != null ? isSystemAdmin(u.roles) : false));
    final enablePostIconOverride = observeConfigBooleanValue(database, 'EnablePostIconOverride');
    final enablePostUsernameOverride = observeConfigBooleanValue(database, 'EnablePostUsernameOverride');
    final preferences = queryDisplayNamePreferences(database).observeWithColumns(['value']);
    final isMilitaryTime = preferences.map((prefs) => getDisplayNamePreferenceAsBool(prefs, Preferences.USE_MILITARY_TIME));
    final isCustomStatusEnabled = observeConfigBooleanValue(database, 'EnableCustomUserStatuses');
    final canManageAndRemoveMembers = Rx.combineLatest2(channel, currentUser, (c, u) => c != null && u != null ? observeCanManageChannelMembers(database, c.id, u) : Stream.value(false));
    final canChangeMemberRoles = Rx.combineLatest3(channel, currentUser, canManageAndRemoveMembers, (c, u, m) => c != null && u != null && m != null ? observePermissionForChannel(database, c, u, Permissions.MANAGE_CHANNEL_ROLES, true) : Stream.value(false));

    final hideGuestTags = observeConfigBooleanValue(database, 'HideGuestTags');

    return StreamBuilder(
      stream: Rx.combineLatest([
        canManageAndRemoveMembers,
        currentUserId,
        enablePostIconOverride,
        enablePostUsernameOverride,
        isChannelAdmin,
        isCustomStatusEnabled,
        isDefaultChannel,
        isDirectMessage,
        isMilitaryTime,
        systemAdmin,
        isTeamAdmin,
        teamId,
        teammateDisplayName,
        user,
        canChangeMemberRoles,
        hideGuestTags,
      ], (values) {
        return UserProfileData(
          canManageAndRemoveMembers: values[0],
          currentUserId: values[1],
          enablePostIconOverride: values[2],
          enablePostUsernameOverride: values[3],
          isChannelAdmin: values[4],
          isCustomStatusEnabled: values[5],
          isDefaultChannel: values[6],
          isDirectMessage: values[7],
          isMilitaryTime: values[8],
          isSystemAdmin: values[9],
          isTeamAdmin: values[10],
          teamId: values[11],
          teammateDisplayName: values[12],
          user: values[13],
          canChangeMemberRoles: values[14],
          hideGuestTags: values[15],
        );
      }),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return CircularProgressIndicator();
        }

        return UserProfile(
          data: snapshot.data!,
        );
      },
    );
  }
}
