// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/material.dart';

import 'package:mattermost_flutter/actions/local/apps.dart';
import 'package:mattermost_flutter/constants/apps.dart';
import 'package:mattermost_flutter/database/manager.dart';
import 'package:mattermost_flutter/managers/apps_manager.dart';
import 'package:mattermost_flutter/managers/integrations_manager.dart';
import 'package:mattermost_flutter/queries/servers/channel.dart';
import 'package:mattermost_flutter/utils/deep_link.dart';
import 'package:mattermost_flutter/utils/errors.dart';
import 'package:mattermost_flutter/utils/log.dart';

import 'package:types/types.dart'; // Assuming all necessary types are defined here

Future<Map<String, dynamic>> executeCommand(String serverUrl, Intl intl, String message, String channelId, {String? rootId}) async {
  final operator = DatabaseManager.serverDatabases[serverUrl]?.operator;
  if (operator == null) {
    return {'error': '$serverUrl database not found'};
  }
  final database = operator.database;

  Client client;
  try {
    client = NetworkManager.getClient(serverUrl);
  } catch (error) {
    return {'error': error};
  }

  final channel = await getChannelById(database, channelId);
  final teamId = channel?.teamId ?? await getCurrentTeamId(database);

  final args = CommandArgs(
    channelId: channelId,
    teamId: teamId,
    rootId: rootId,
    parentId: rootId,
  );

  final appsEnabled = await AppsManager.isAppsEnabled(serverUrl);
  if (appsEnabled) {
    final parser = AppCommandParser(serverUrl, intl, channelId, teamId, rootId);
    if (parser.isAppCommand(message)) {
      return executeAppCommand(serverUrl, intl, parser, message, args);
    }
  }

  var msg = filterEmDashForCommand(message);
  var cmdLength = msg.indexOf(' ');
  if (cmdLength < 0) {
    cmdLength = msg.length;
  }

  final cmd = msg.substring(0, cmdLength).toLowerCase();
  if (cmd == '/code') {
    msg = '$cmd ${msg.substring(cmdLength).trimEnd()}';
  } else {
    msg = '$cmd ${msg.substring(cmdLength).trim()}';
  }

  Map<String, dynamic> data;
  try {
    data = await client.executeCommand(msg, args);
  } catch (error) {
    logDebug('error on executeCommand', getFullErrorMessage(error));
    return {'error': error};
  }

  if (data.containsKey('trigger_id')) { //eslint-disable-line camelcase
    IntegrationsManager.getManager(serverUrl).setTriggerId(data['trigger_id']);
  }

  return {'data': data};
}

Future<Map<String, dynamic>> executeAppCommand(String serverUrl, Intl intl, AppCommandParser parser, String msg, CommandArgs args) async {
  final creqWithError = await parser.composeCommandSubmitCall(msg);
  final creq = creqWithError.item1;
  final errorMessage = creqWithError.item2;

  Map<String, dynamic> createErrorMessage(String errMessage) {
    return {'error': {'message': errMessage}};
  }

  if (creq == null) {
    return createErrorMessage(errorMessage!);
  }

  final res = await doAppSubmit(serverUrl, creq, intl);
  if (res.containsKey('error')) {
    final errorResponse = res['error'];
    return createErrorMessage(errorResponse.text ?? intl.formatMessage({
      'id': 'apps.error.unknown',
      'defaultMessage': 'Unknown error.',
    }));
  }
  final callResp = res['data'];

  switch (callResp.type) {
    case AppCallResponseTypes.OK:
      if (callResp.text != null) {
        postEphemeralCallResponseForCommandArgs(serverUrl, callResp, callResp.text!, args);
      }
      return {'data': {}};
    case AppCallResponseTypes.FORM:
      if (callResp.form != null) {
        showAppForm(callResp.form!, creq.context);
      }
      return {'data': {}};
    case AppCallResponseTypes.NAVIGATE:
      if (callResp.navigateToUrl != null) {
        handleGotoLocation(serverUrl, intl, callResp.navigateToUrl!);
      }
      return {'data': {}};
    default:
      return createErrorMessage(intl.formatMessage({
        'id': 'apps.error.responses.unknown_type',
        'defaultMessage': 'App response type not supported. Response type: {type}.',
      }, {
        'type': callResp.type,
      }));
  }
}

String filterEmDashForCommand(String command) {
  return command.replaceAll('—', '--');
}

Future<Map<String, dynamic>> handleGotoLocation(String serverUrl, Intl intl, String location) async {
  final operator = DatabaseManager.serverDatabases[serverUrl]?.operator;
  if (operator == null) {
    return {'error': '$serverUrl database not found'};
  }
  final database = operator.database;

  final config = await getConfig(database);
  final match = matchDeepLink(location, serverUrl, config?.siteURL);

  if (match != null) {
    handleDeepLink(match.url, intl, location);
  } else {
    final formatMessage = intl.formatMessage;
    final onError = () {
      showDialog(
        context: context, // Replace with appropriate context
        builder: (context) => AlertDialog(
          title: Text(formatMessage({
            'id': 'mobile.server_link.error.title',
            'defaultMessage': 'Link Error',
          })),
          content: Text(formatMessage({
            'id': 'mobile.server_link.error.text',
            'defaultMessage': 'The link could not be found on this server.',
          })),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      );
    };

    tryOpenURL(location, onError);
  }
  return {'data': true};
}

Future<Map<String, dynamic>> fetchCommands(String serverUrl, String teamId) async {
  try {
    final client = NetworkManager.getClient(serverUrl);
    final commands = await client.getCommandsList(teamId);
    return {'commands': commands};
  } catch (error) {
    logDebug('error on fetchCommands', getFullErrorMessage(error));
    return {'error': error};
  }
}

Future<Map<String, dynamic>> fetchSuggestions(String serverUrl, String term, String teamId, String channelId, {String? rootId}) async {
  try {
    final client = NetworkManager.getClient(serverUrl);
    final suggestions = await client.getCommandAutocompleteSuggestionsList(term, teamId, channelId, rootId);
    return {'suggestions': suggestions};
  } catch (error) {
    logDebug('error on fetchSuggestions', getFullErrorMessage(error));
    return {'error': error};
  }
}
