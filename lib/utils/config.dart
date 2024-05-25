// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:mattermost_flutter/helpers/helpers.dart';

bool hasReliableWebsocket(String? version, String? reliableWebsocketsConfig) {
  if (version != null && isMinimumServerVersion(version, 6, 5)) {
    return true;
  }

  return reliableWebsocketsConfig == 'true';
}