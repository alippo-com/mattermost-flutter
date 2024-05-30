
// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:mattermost_flutter/actions/remote/channel.dart';
import 'package:mattermost_flutter/actions/remote/post.dart';
import 'package:mattermost_flutter/actions/remote/team.dart';
import 'package:mattermost_flutter/context/theme.dart';
import 'package:mattermost_flutter/database/manager.dart';
import 'package:mattermost_flutter/queries/servers/channel.dart';
import 'package:mattermost_flutter/queries/servers/post.dart';
import 'package:mattermost_flutter/queries/servers/preference.dart';
import 'package:mattermost_flutter/store/ephemeral_store.dart';
import 'package:mattermost_flutter/utils/errors.dart';
import 'package:mattermost_flutter/utils/notification.dart';
import 'package:mattermost_flutter/utils/theme.dart';

import 'package:mattermost_flutter/types/my_channel_model.dart';
import 'package:mattermost_flutter/types/my_team_model.dart';
import 'package:mattermost_flutter/types/post_model.dart';

Future<Map<String, dynamic>> pushNotificationEntry(String serverUrl, NotificationData notification) async {
  // We only reach this point if we have a channel Id in the notification payload
  final channelId = notification.channelId!;
  final rootId = notification.rootId!;

  final operator = DatabaseManager.serverDatabases[serverUrl]?.operator;
  if (operator == null) {
    return {'error': '$serverUrl database not found'};
  }
  final database = operator.database;

  final currentTeamId = await getCurrentTeamId(database);
  final currentServerUrl = await DatabaseManager.getActiveServerUrl();

  var teamId = notification.teamId;
  if (teamId == null) {
    // If the notification payload does not have a teamId we assume is a DM/GM
    teamId = currentTeamId;
  }

  if (currentServerUrl != serverUrl) {
    await DatabaseManager.setActiveServerDatabase(serverUrl);
  }

  if (EphemeralStore.theme == null) {
    // When opening the app from a push notification the theme may not be set in the EphemeralStore
    // causing the goToScreen to use the Appearance theme instead and that causes the screen background color to potentially
    // not match the theme
    final themes = await queryThemePreferences(database, teamId).fetch();
    var theme = getDefaultThemeByAppearance();
    if (themes.isNotEmpty) {
      theme = setThemeDefaults(Theme.fromJson(themes[0].value));
    }
    updateThemeIfNeeded(theme, true);
  }

  // To make the switch faster we determine if we already have the team & channel
  var myChannel = await getMyChannel(database, channelId);
  var myTeam = await getMyTeamById(database, teamId);

  if (myTeam == null) {
    final resp = await fetchMyTeam(serverUrl, teamId);
    if (resp['error'] != null) {
      if (isErrorWithStatusCode(resp['error']) && resp['error'].statusCode == 403) {
        emitNotificationError('Team');
      } else {
        emitNotificationError('Connection');
      }
    } else {
      myTeam = resp['memberships']?.first;
    }
  }

  if (myChannel == null) {
    final resp = await fetchMyChannel(serverUrl, teamId, channelId);
    if (resp['error'] != null) {
      if (isErrorWithStatusCode(resp['error']) && resp['error'].statusCode == 403) {
        emitNotificationError('Channel');
      } else {
        emitNotificationError('Connection');
      }
    } else {
      myChannel = resp['memberships']?.first;
    }
  }

  final isCRTEnabled = await getIsCRTEnabled(database);
  final isThreadNotification = isCRTEnabled && rootId != null;

  if (myChannel != null && myTeam != null) {
    if (isThreadNotification) {
      var post = await getPostById(database, rootId);
      if (post == null) {
        final resp = await fetchPostById(serverUrl, rootId);
        post = resp['post'];
      }

      final actualRootId = post?.rootId;

      if (actualRootId != null) {
        await fetchAndSwitchToThread(serverUrl, actualRootId, true);
      } else if (post != null) {
        await fetchAndSwitchToThread(serverUrl, rootId, true);
      } else {
        emitNotificationError('Post');
      }
    } else {
      await switchToChannelById(serverUrl, channelId, teamId);
    }
  }

  WebsocketManager.openAll();

  return {};
}
