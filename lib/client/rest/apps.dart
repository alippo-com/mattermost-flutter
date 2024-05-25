// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:mattermost_flutter/utils/helpers.dart';
import 'package:mattermost_flutter/types/base.dart';

abstract class ClientAppsMix {
  Future<AppCallResponse<T>> executeAppCall<T>(AppCallRequest call, bool trackAsSubmit);
  Future<List<AppBinding>> getAppsBindings(String userID, String channelID, String teamID);
}

mixin ClientApps<TBase extends ClientBase> on TBase implements ClientAppsMix {
  @override
  Future<AppCallResponse<T>> executeAppCall<T>(AppCallRequest call, bool trackAsSubmit) async {
    final callCopy = AppCallRequest(
      context: call.context.copyWith(userAgent: 'mobile', trackAsSubmit: trackAsSubmit),
      // other fields
    );

    return doFetch<AppCallResponse<T>>(
      '${getAppsProxyRoute()}/api/v1/call',
      method: 'post',
      body: callCopy,
    );
  }

  @override
  Future<List<AppBinding>> getAppsBindings(String userID, String channelID, String teamID) async {
    final params = {
      'user_id': userID,
      'channel_id': channelID,
      'team_id': teamID,
      'user_agent': 'mobile',
    };

    return doFetch<List<AppBinding>>(
      '${getAppsProxyRoute()}/api/v1/bindings${buildQueryString(params)}',
      method: 'get',
    );
  }
}
