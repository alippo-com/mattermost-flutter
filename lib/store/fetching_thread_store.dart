// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'dart:async';

class FetchingThreadStore {
  final Map<String, bool> _state = {};
  final _controller = StreamController<Map<String, bool>>.broadcast();

  Stream<Map<String, bool>> get stream => _controller.stream;

  void setFetchingThreadState(String rootId, bool isFetching) {
    _state[rootId] = isFetching;
    _controller.add(Map.from(_state));
  }

  void dispose() {
    _controller.close();
  }
}
