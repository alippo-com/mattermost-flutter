// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mattermost_flutter/store/fetching_thread_store.dart';

class FetchingThreadState extends StatefulWidget {
  final String rootId;

  FetchingThreadState({required this.rootId});

  @override
  _FetchingThreadStateState createState() => _FetchingThreadStateState();
}

class _FetchingThreadStateState extends State<FetchingThreadState> {
  bool isFetching = false;
  StreamSubscription? _subscription;

  @override
  void initState() {
    super.initState();
    _subscription = subject.stream
        .switchMap((s) => Stream.value(s[widget.rootId] ?? false))
        .distinct()
        .listen((value) {
          setState(() {
            isFetching = value;
          });
        });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(); // This hook does not render anything
  }
}
