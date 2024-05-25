// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:mattermost_flutter/types/events.dart';
import 'package:mattermost_flutter/types/rtc_ice_candidate.dart';
import 'package:mattermost_flutter/types/rtc_track_event.dart';

// Only adding the types that are not included in the imported module.
class RTCIceCredentialType {
  static const String password = 'password';
}

class RTCIceServer {
  String? credential;
  RTCIceCredentialType? credentialType;
  List<String> urls;
  String? username;

  RTCIceServer({this.credential, this.credentialType, required this.urls, this.username});
}

class RTCPeerConnectionIceEvent {
  final RTCIceCandidate? candidate;

  RTCPeerConnectionIceEvent({this.candidate});
}

class RTCPeerConnection {
  void Function(Event)? onconnectionstatechange;
  Future<void> Function()? onnegotiationneeded;
  void Function(EventOnCandidate)? onicecandidate;
  void Function(EventOnConnectionStateChange)? oniceconnectionstatechange;
  void Function(RTCTrackEvent)? ontrack;

  RTCPeerConnection({
    this.onconnectionstatechange,
    this.onnegotiationneeded,
    this.onicecandidate,
    this.oniceconnectionstatechange,
    this.ontrack,
  });
}