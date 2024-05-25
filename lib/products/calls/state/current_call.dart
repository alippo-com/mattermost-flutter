
// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:mattermost_flutter/types/calls.dart';

final BehaviorSubject<CurrentCall?> currentCallSubject = BehaviorSubject<CurrentCall?>.seeded(null);

CurrentCall? getCurrentCall() {
  return currentCallSubject.value;
}

void setCurrentCall(CurrentCall? currentCall) {
  currentCallSubject.add(currentCall);
}

Stream<CurrentCall?> observeCurrentCall() {
  return currentCallSubject.stream;
}

class CurrentCallNotifier extends ValueNotifier<CurrentCall?> {
  late final StreamSubscription<CurrentCall?> _subscription;

  CurrentCallNotifier() : super(null) {
    _subscription = currentCallSubject.stream.listen((currentCall) {
      value = currentCall;
    });
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

CurrentCall? useCurrentCall(BuildContext context) {
  return context.watch<CurrentCallNotifier>().value;
}
