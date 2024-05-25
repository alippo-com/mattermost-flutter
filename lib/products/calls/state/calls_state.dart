// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:mattermost_flutter/types/calls.dart';

class CallsStateManager with ChangeNotifier {
  final Map<String, BehaviorSubject<CallsState>> _callsStateSubjects = {};

  BehaviorSubject<CallsState> _getCallsStateSubject(String serverUrl) {
    if (!_callsStateSubjects.containsKey(serverUrl)) {
      _callsStateSubjects[serverUrl] = BehaviorSubject<CallsState>.seeded(DefaultCallsState());
    }
    return _callsStateSubjects[serverUrl]!;
  }

  CallsState getCallsState(String serverUrl) {
    return _getCallsStateSubject(serverUrl).value;
  }

  void setCallsState(String serverUrl, CallsState state) {
    _getCallsStateSubject(serverUrl).add(state);
    notifyListeners();
  }

  Stream<CallsState> observeCallsState(String serverUrl) {
    return _getCallsStateSubject(serverUrl).stream;
  }

  CallsState useCallsState(BuildContext context, String serverUrl) {
    final notifier = CallsStateNotifier(serverUrl);
    return context.watch<CallsStateNotifier>().value;
  }
}

class CallsStateNotifier extends ValueNotifier<CallsState> {
  late final StreamSubscription<CallsState> _subscription;

  CallsStateNotifier(String serverUrl) : super(DefaultCallsState()) {
    final callsStateSubject = CallsStateManager()._getCallsStateSubject(serverUrl);
    _subscription = callsStateSubject.listen((callsState) {
      value = callsState;
    });
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}