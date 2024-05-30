// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:mattermost_flutter/constants/general.dart';
import 'package:mattermost_flutter/utils/errors.dart';
import 'package:mattermost_flutter/utils/log.dart';

Future<bool> isNPSEnabled(String serverUrl) async {
  try {
    final client = NetworkManager.getClient(serverUrl);
    final manifests = await client.getPluginsManifests();
    for (final v in manifests) {
      if (v.id == General.NPS_PLUGIN_ID) {
        return true;
      }
    }
    return false;
  } catch (error) {
    logDebug('error on isNPSEnabled', getFullErrorMessage(error));
    return false;
  }
}

Future<Map<String, dynamic>> giveFeedbackAction(String serverUrl) async {
  try {
    final client = NetworkManager.getClient(serverUrl);
    final post = await client.npsGiveFeedbackAction();
    return {'post': post};
  } catch (error) {
    logDebug('error on giveFeedbackAction', getFullErrorMessage(error));
    return {'error': error};
  }
}
