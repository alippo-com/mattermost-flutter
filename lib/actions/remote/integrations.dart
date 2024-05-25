// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:mattermost_flutter/database/manager.dart';
import 'package:mattermost_flutter/managers/integrations_manager.dart';
import 'package:mattermost_flutter/managers/network_manager.dart';
import 'package:mattermost_flutter/queries/servers/system.dart';
import 'package:mattermost_flutter/utils/errors.dart';
import 'package:mattermost_flutter/utils/log.dart';

import 'session.dart';

Future<Map<String, dynamic>> submitInteractiveDialog(String serverUrl, DialogSubmission submission) async {
  try {
    final client = NetworkManager.getClient(serverUrl);
    final database = await DatabaseManager.getServerDatabaseAndOperator(serverUrl);

    submission.channelId = await getCurrentChannelId(database);
    submission.teamId = await getCurrentTeamId(database);
    final data = await client.submitInteractiveDialog(submission);
    return {'data': data};
  } catch (error) {
    logDebug('error on submitInteractiveDialog', getFullErrorMessage(error));
    forceLogoutIfNecessary(serverUrl, error);
    return {'error': error};
  }
}

Future<Map<String, dynamic>> postActionWithCookie(String serverUrl, String postId, String actionId, String actionCookie, [String selectedOption = '']) async {
  try {
    final client = NetworkManager.getClient(serverUrl);

    final data = await client.doPostActionWithCookie(postId, actionId, actionCookie, selectedOption);
    if (data?.triggerId != null) {
      IntegrationsManager.getManager(serverUrl)?.setTriggerId(data.triggerId);
    }

    return {'data': data};
  } catch (error) {
    logDebug('error on postActionWithCookie', getFullErrorMessage(error));
    forceLogoutIfNecessary(serverUrl, error);
    return {'error': error};
  }
}

Future<Map<String, dynamic>> selectAttachmentMenuAction(String serverUrl, String postId, String actionId, String selectedOption) async {
  return postActionWithCookie(serverUrl, postId, actionId, '', selectedOption);
}
