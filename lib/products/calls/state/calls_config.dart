// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

class CallsConfigState {
  // Define properties and constructor here
}

class DefaultCallsConfig {
  // Define the default config here
}

final Map<String, BehaviorSubject<CallsConfigState>> _callsConfigSubjects = {};

BehaviorSubject<CallsConfigState> _getCallsConfigSubject(String serverUrl) {
  if (!_callsConfigSubjects.containsKey(serverUrl)) {
    _callsConfigSubjects[serverUrl] = BehaviorSubject<CallsConfigState>.seeded(DefaultCallsConfig());
  }
  return _callsConfigSubjects[serverUrl]!;
}

CallsConfigState getCallsConfig(String serverUrl) {
  return _getCallsConfigSubject(serverUrl).value;
}

void setCallsConfig(String serverUrl, CallsConfigState callsConfig) {
  _getCallsConfigSubject(serverUrl).add(callsConfig);
}

Stream<CallsConfigState> observeCallsConfig(String serverUrl) {
  return _getCallsConfigSubject(serverUrl).stream;
}

class CallsConfigStateNotifier extends ValueNotifier<CallsConfigState> {
  late final StreamSubscription<CallsConfigState> _subscription;

  CallsConfigStateNotifier(String serverUrl) : super(DefaultCallsConfig()) {
    final callsConfigSubject = _getCallsConfigSubject(serverUrl);
    _subscription = callsConfigSubject.listen((callsConfig) {
      value = callsConfig;
    });
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

CallsConfigState useCallsConfig(BuildContext context, String serverUrl) {
  final notifier = CallsConfigStateNotifier(serverUrl);
  return context.watch<CallsConfigStateNotifier>().value;
}
