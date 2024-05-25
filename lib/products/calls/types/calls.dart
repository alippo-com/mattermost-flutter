
// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/foundation.dart';
import 'package:mattermost_flutter/types.dart';

// Types converted from TypeScript to Dart

class GlobalCallsState {
  bool micPermissionsGranted;

  GlobalCallsState({this.micPermissionsGranted = false});
}

class CallsState {
  String myUserId;
  Map<String, dynamic> calls;
  Map<String, bool> enabled;

  CallsState({this.myUserId = '', this.calls = const {}, this.enabled = const {}});
}

enum ChannelType { DM, GM }

class IncomingCallNotification {
  String serverUrl;
  String myUserId;
  String callID;
  String channelID;
  String callerID;
  UserModel? callerModel;
  int startAt;
  ChannelType type;

  IncomingCallNotification({required this.serverUrl, required this.myUserId, required this.callID, required this.channelID, required this.callerID, this.callerModel, required this.startAt, required this.type});
}

class IncomingCalls {
  List<IncomingCallNotification> incomingCalls;

  IncomingCalls({this.incomingCalls = const []});
}

class Call {
  String id;
  Map<String, dynamic> sessions;
  String channelId;
  int startTime;
  String screenOn;
  String threadId;
  String ownerId;
  CallJobState? recState;
  CallJobState? capState;
  String hostId;
  Map<String, bool> dismissed;

  Call({this.id = '', this.sessions = const {}, this.channelId = '', this.startTime = 0, this.screenOn = '', this.threadId = '', this.ownerId = '', this.hostId = '', this.dismissed = const {}});
}

enum AudioDevice { Earpiece, Speakerphone, Bluetooth, WiredHeadset, None }

class CurrentCall extends Call {
  bool connected;
  String serverUrl;
  String myUserId;
  String mySessionId;
  String screenShareURL;
  bool speakerphoneOn;
  AudioDeviceInfo audioDeviceInfo;
  Map<String, bool> voiceOn;
  bool micPermissionsErrorDismissed;
  List<ReactionStreamEmoji> reactionStream;
  bool callQualityAlert;
  int callQualityAlertDismissed;
  Map<String, LiveCaptionMobile> captions;

  CurrentCall({required super.id, required super.sessions, required super.channelId, required super.startTime, required super.screenOn, required super.threadId, required super.ownerId, required super.hostId, required super.dismissed, this.connected = false, this.serverUrl = '', this.myUserId = '', this.mySessionId = '', this.screenShareURL = '', this.speakerphoneOn = false, this.audioDeviceInfo = const AudioDeviceInfo(availableAudioDeviceList: [], selectedAudioDevice: AudioDevice.None), this.voiceOn = const {}, this.micPermissionsErrorDismissed = false, this.reactionStream = const [], this.callQualityAlert = false, this.callQualityAlertDismissed = 0, this.captions = const {}});
