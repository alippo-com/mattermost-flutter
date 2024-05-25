
  // Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
  // See LICENSE.txt for license information.
  
  import 'dart:async';
  
  class StartSetup {
    String? media;
    bool? auto;
    String? ringback;
  }

  class StopSetup {
    String? busytone;
  }

  class InCallManager {
    Future<void> start(StartSetup setup) async {}

    Future<void> stop(StopSetup setup) async {}

    Future<void> turnScreenOff() async {}

    Future<void> turnScreenOn() async {}

    Future<bool> getIsWiredHeadsetPluggedIn() async {
      return Future.value(false);
    }

    int setFlashOn(bool enable, int brightness) {
      return 0;
    }

    Future<void> setKeepScreenOn(bool enable) async {}

    Future<void> setSpeakerphoneOn(bool enable) async {}

    Future<void> setForceSpeakerphoneOn(bool flag) async {}

    Future<void> setMicrophoneMute(bool enable) async {}

    Future<void> startRingtone(
        String ringtone, List<int> vibrate_pattern, String ios_category, int seconds) async {}

    Future<void> stopRingtone() async {}

    Future<void> startProximitySensor() async {}

    Future<void> stopProximitySensor() async {}

    Future<void> startRingback(String ringback) async {}

    Future<void> stopRingback() async {}

    Future<void> pokeScreen(int timeout) async {}

    Future<String> getAudioUri(String audioType, String fileType) async {
      return Future.value('');
    }

    Future<String> chooseAudioRoute(String route) async {
      return Future.value('');
    }

    Future<void> requestAudioFocus() async {}

    Future<void> abandonAudioFocus() async {}
  }

  InCallManager inCallManager = InCallManager();
  