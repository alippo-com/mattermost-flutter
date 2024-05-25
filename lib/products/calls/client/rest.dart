
// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:mattermost_flutter/types/calls.dart';
import 'package:mattermost_flutter/types/mattermost_calls.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

abstract class ClientCallsMix {
  Future<bool> getEnabled();
  Future<List<CallChannelState>> getCalls();
  Future<CallChannelState> getCallForChannel(String channelId);
  Future<CallsConfig> getCallsConfig();
  Future<CallsVersion> getVersion();
  Future<CallChannelState> enableChannelCalls(String channelId, bool enable);
  Future<ApiResp> endCall(String channelId);
  Future<List<RTCIceServer>> genTURNCredentials();
  Future<dynamic> startCallRecording(String callId); // ApiResp | CallJobState
  Future<dynamic> stopCallRecording(String callId); // ApiResp | CallJobState
  Future<ApiResp> dismissCall(String channelId);
  Future<ApiResp> makeHost(String callId, String newHostId);
}

mixin ClientCalls on Object {
  Future<bool> getEnabled() async {
    try {
      await doFetch('${getCallsRoute()}/version', {'method': 'get'});
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<List<CallChannelState>> getCalls() async {
    return doFetch('${getCallsRoute()}/channels?mobilev2=true', {'method': 'get'});
  }

  Future<CallChannelState> getCallForChannel(String channelId) async {
    return doFetch('${getCallsRoute()}/${channelId}?mobilev2=true', {'method': 'get'});
  }

  Future<CallsConfig> getCallsConfig() async {
    return doFetch('${getCallsRoute()}/config', {'method': 'get'}) as CallsConfig;
  }

  Future<CallsVersion> getVersion() async {
    try {
      return doFetch('${getCallsRoute()}/version', {'method': 'get'});
    } catch (e) {
      return {};
    }
  }

  Future<CallChannelState> enableChannelCalls(String channelId, bool enable) async {
    return doFetch('${getCallsRoute()}/${channelId}', {'method': 'post', 'body': {'enabled': enable}});
  }

  Future<ApiResp> endCall(String channelId) async {
    return doFetch('${getCallsRoute()}/calls/${channelId}/end', {'method': 'post'});
  }

  Future<List<RTCIceServer>> genTURNCredentials() async {
    return doFetch('${getCallsRoute()}/turn-credentials', {'method': 'get'});
  }

  Future<dynamic> startCallRecording(String callId) async {
    return doFetch('${getCallsRoute()}/calls/${callId}/recording/start', {'method': 'post'});
  }

  Future<dynamic> stopCallRecording(String callId) async {
    return doFetch('${getCallsRoute()}/calls/${callId}/recording/stop', {'method': 'post'});
  }

  Future<ApiResp> dismissCall(String channelId) async {
    return doFetch('${getCallsRoute()}/calls/${channelId}/dismiss-notification', {'method': 'post'});
  }

  Future<ApiResp> makeHost(String callId, String newHostId) async {
    return doFetch('${getCallsRoute()}/calls/${callId}/host/make', {
      'method': 'post',
      'body': {'new_host_id': newHostId},
    });
  }

  Future<dynamic> doFetch(String url, Map<String, dynamic> options);
  String getCallsRoute();
}
