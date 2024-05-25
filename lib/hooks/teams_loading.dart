// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:mattermost_flutter/store/team_load_store.dart';

class TeamsLoading extends StatefulWidget {
  final String serverUrl;

  TeamsLoading({required this.serverUrl});

  @override
  _TeamsLoadingState createState() => _TeamsLoadingState();
}

class _TeamsLoadingState extends State<TeamsLoading> {
  late BehaviorSubject<bool> _loadingSubject;
  late StreamSubscription<bool> _subscription;
  bool loading = false;

  @override
  void initState() {
    super.initState();
    _loadingSubject = getLoadingTeamChannelsSubject(widget.serverUrl).switchMap((v) => Stream.value(v != 0)).distinct();
    _subscription = _loadingSubject.listen((value) {
      if (mounted) {
        setState(() {
          loading = value;
        });
      }
    });
  }

  @override
  void dispose() {
    _subscription.cancel();
    _loadingSubject.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // Example usage of the loading state
      child: loading ? CircularProgressIndicator() : Container(),
    );
  }
}
