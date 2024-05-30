// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

class ChannelsWithCallsStateManager with ChangeNotifier {
  final Map<String, BehaviorSubject<ChannelsWithCalls>> _channelsWithCallsSubjects = {};

  BehaviorSubject<ChannelsWithCalls> _getChannelsWithCallsSubject(String serverUrl) {
    if (!_channelsWithCallsSubjects.containsKey(serverUrl)) {
      _channelsWithCallsSubjects[serverUrl] = BehaviorSubject<ChannelsWithCalls>.seeded(DefaultChannelsWithCalls());
    }
    return _channelsWithCallsSubjects[serverUrl]!;
  }

  ChannelsWithCalls getChannelsWithCalls(String serverUrl) {
    return _getChannelsWithCallsSubject(serverUrl).value;
  }

  void setChannelsWithCalls(String serverUrl, ChannelsWithCalls channelsWithCalls) {
    _getChannelsWithCallsSubject(serverUrl).add(channelsWithCalls);
    notifyListeners();
  }

  Stream<ChannelsWithCalls> observeChannelsWithCalls(String serverUrl) {
    return _getChannelsWithCallsSubject(serverUrl).stream;
  }

  ChannelsWithCalls useChannelsWithCalls(BuildContext context, String serverUrl) {
    final notifier = ChannelsWithCallsStateNotifier(serverUrl);
    return context.watch<ChannelsWithCallsStateNotifier>().value;
  }
}

class ChannelsWithCallsStateNotifier extends ValueNotifier<ChannelsWithCalls> {
  late final StreamSubscription<ChannelsWithCalls> _subscription;
  final String serverUrl;

  ChannelsWithCallsStateNotifier(this.serverUrl) : super(DefaultChannelsWithCalls()) {
    _subscription = ChannelsWithCallsStateManager()._getChannelsWithCallsSubject(serverUrl).listen((channelsWithCalls) {
      value = channelsWithCalls;
    });
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
