// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'dart:async';
import 'package:incall_manager/incall_manager.dart';

import 'package:mattermost_flutter/constants/general.dart';
import 'package:mattermost_flutter/constants/calls.dart';
import 'package:mattermost_flutter/database/manager.dart';
import 'package:mattermost_flutter/queries/servers/channel.dart';
import 'package:mattermost_flutter/utils/errors.dart';
import 'package:mattermost_flutter/utils/log.dart';
import 'package:mattermost_flutter/products/calls/connection/connection.dart';
import 'package:mattermost_flutter/products/calls/alerts.dart';
import 'package:mattermost_flutter/products/calls/state.dart';
import 'package:mattermost_flutter/types/calls.dart';

CallsConnection? connection;

CallsConnection? getConnectionForTesting() => connection;

Future<Map<String, dynamic>> loadConfig(String serverUrl, {bool force = false}) async {
  final now = DateTime.now().millisecondsSinceEpoch;
  final config = getCallsConfig(serverUrl);

  if (!force) {
    final lastRetrievedAt = config['last_retrieved_at'] ?? 0;
    if ((now - lastRetrievedAt) < Calls.refreshConfigMillis) {
      return {'data': config};
    }
  }

  try {
    final client = NetworkManager.getClient(serverUrl);
    final configs = await Future.wait([client.getCallsConfig(), client.getVersion()]);
    final nextConfig = {...configs[0], 'version': configs[1], 'last_retrieved_at': now};
    setConfig(serverUrl, nextConfig);
    return {'data': nextConfig};
  } catch (error) {
    logDebug('error on loadConfig', getFullErrorMessage(error));
    await forceLogoutIfNecessary(serverUrl, error);
    return {'error': error};
  }
}

Future<Map<String, dynamic>> loadCalls(String serverUrl, String userId) async {
  List<CallChannelState> resp = [];

  try {
    final client = NetworkManager.getClient(serverUrl);
    resp = await client.getCalls() ?? [];
  } catch (error) {
    logDebug('error on loadCalls', getFullErrorMessage(error));
    await forceLogoutIfNecessary(serverUrl, error);
    return {'error': error};
  }

  final callsResults = <String, Call>{};
  final enabledChannels = <String, bool>{};
  final ids = <String>{};

  for (final channel in resp) {
    if (channel.call != null) {
      callsResults[channel.channelId] = createCallAndAddToIds(channel.channelId, convertOldCallToNew(channel.call), ids);
    }

    if (channel.enabled != null) {
      enabledChannels[channel.channelId] = channel.enabled;
    }
  }

  if (ids.isNotEmpty) {
    fetchUsersByIds(serverUrl, ids.toList());
  }

  setCalls(serverUrl, userId, callsResults, enabledChannels);

  return {'data': {'calls': callsResults, 'enabled': enabledChannels}};
}
