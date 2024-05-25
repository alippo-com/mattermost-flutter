
// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:mattermost_flutter/types/calls.dart';

class GlobalCallsStateManager with ChangeNotifier {
  final BehaviorSubject<GlobalCallsState> _globalStateSubject = BehaviorSubject<GlobalCallsState>.seeded(DefaultGlobalCallsState());

  GlobalCallsState getGlobalCallsState() {
    return _globalStateSubject.value;
  }

  void setGlobalCallsState(GlobalCallsState globalState) {
    _globalStateSubject.add(globalState);
    notifyListeners();
  }

  Stream<GlobalCallsState> observeGlobalCallsState() {
    return _globalStateSubject.stream;
  }

  GlobalCallsState useGlobalCallsState(BuildContext context) {
    final notifier = GlobalCallsStateNotifier();
    return context.watch<GlobalCallsStateNotifier>().value;
  }
}

class GlobalCallsStateNotifier extends ValueNotifier<GlobalCallsState> {
  late final StreamSubscription<GlobalCallsState> _subscription;

  GlobalCallsStateNotifier() : super(DefaultGlobalCallsState()) {
    _subscription = GlobalCallsStateManager()._globalStateSubject.listen((globalState) {
      value = globalState;
    });
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
