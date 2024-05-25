
// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/widgets.dart';

// Dart Class Definitions for Global Calls State
class GlobalCallsState {
  final bool micPermissionsGranted;
  GlobalCallsState({this.micPermissionsGranted = false});
}

// Dart Class Definitions for Calls State
class CallsState {
  final String myUserId;
  final Map<String, dynamic> calls;
  final Map<String, bool> enabled;

  CallsState({
    this.myUserId = '',
    this.calls = const {},
    this.enabled = const {},
  });
}

// Dart Enum Definitions for Channel Type
enum ChannelType { DM, GM }

// Dart Class Definitions for Incoming Call Notification
class IncomingCallNotification {
  final String serverUrl;
  final String myUserId;
  final String callID;
  final String channelID;
  final String callerID;
  final UserModel? callerModel;
  final int startAt;
  final ChannelType type;

  IncomingCallNotification({
    required this.serverUrl,
    required this.myUserId,
    required this.callID,
    required this.channelID,
    required this.callerID,
    this.callerModel,
    required this.startAt,
    required this.type,
  });
}

// Dart Class Definitions for Calls
class Call {
  final String id;
  final Map<String, dynamic> sessions;
  final String channelId;
  final int startTime;
  final String screenOn;
  final String threadId;
  final String ownerId;
  final String hostId;
  final Map<String, bool> dismissed;

  Call({
    this.id = '',
    this.sessions = const {},
    this.channelId = '',
    this.startTime = 0,
    this.screenOn = '',
    this.threadId = '',
    this.ownerId = '',
    this.hostId = '',
    this.dismissed = const {},
  });
}

// Dart Enum Definitions for Audio Device
enum AudioDevice { Earpiece, Speakerphone, Bluetooth, WiredHeadset, None }

// Dart Class Definitions for Current Call
class CurrentCall extends Call {
  final bool connected;
  final String serverUrl;
  final String myUserId;
  final String mySessionId;
  final String screenShareURL;
  final bool speakerphoneOn;
  final AudioDeviceInfo audioDeviceInfo;
  final Map<String, bool> voiceOn;
  final bool micPermissionsErrorDismissed;
  final List<ReactionStreamEmoji> reactionStream;
  final bool callQualityAlert;
  final int callQualityAlertDismissed;
  final Map<String, LiveCaptionMobile> captions;

  CurrentCall({
    bool connected = false,
    String serverUrl = '',
    String myUserId = '',
    String mySessionId = '',
    String screenShareURL = '',
    bool speakerphoneOn = false,
    AudioDeviceInfo audioDeviceInfo = const AudioDeviceInfo(availableAudioDeviceList: [], selectedAudioDevice: AudioDevice.None),
    Map<String, bool> voiceOn = const {},
    bool micPermissionsErrorDismissed = false,
    List<ReactionStreamEmoji> reactionStream = const [],
    bool callQualityAlert = false,
    int callQualityAlertDismissed = 0,
    Map<String, LiveCaptionMobile> captions = const {},
  }) : super(
    connected: connected,
    serverUrl: serverUrl,
    myUserId: myUserId,
    mySessionId: mySessionId,
    screenShareURL: screenShareURL,
    speakerphoneOn: speakerphoneOn,
    audioDeviceInfo: audioDeviceInfo,
    voiceOn: voiceOn,
    micPermissionsErrorDismissed: micPermissionsErrorDismissed,
    reactionStream: reactionStream,
    callQualityAlert: callQualityAlert,
    callQualityAlertDismissed: callQualityAlertDismissed,
    captions: captions,
  );
}

// Other necessary Dart Classes and Enums would also include detailed definitions similar to above.
