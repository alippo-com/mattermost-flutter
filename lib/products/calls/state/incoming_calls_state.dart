// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:mattermost_flutter/types/calls.dart';

class IncomingCallsStateManager with ChangeNotifier {
  final BehaviorSubject<IncomingCalls> _incomingCallsSubject = BehaviorSubject<IncomingCalls>.seeded(DefaultIncomingCalls());

  IncomingCalls getIncomingCalls() {
    return _incomingCallsSubject.value;
  }

  void setIncomingCalls(IncomingCalls state) {
    _incomingCallsSubject.add(state);
    notifyListeners();
  }

  Stream<IncomingCalls> observeIncomingCalls() {
    return _incomingCallsSubject.stream;
  }

  IncomingCalls useIncomingCalls(BuildContext context) {
    final notifier = IncomingCallsStateNotifier();
    return context.watch<IncomingCallsStateNotifier>().value;
  }
}

class IncomingCallsStateNotifier extends ValueNotifier<IncomingCalls> {
  late final StreamSubscription<IncomingCalls> _subscription;

  IncomingCallsStateNotifier() : super(DefaultIncomingCalls()) {
    _subscription = IncomingCallsStateManager()._incomingCallsSubject.listen((incomingCalls) {
      value = incomingCalls;
    });
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
