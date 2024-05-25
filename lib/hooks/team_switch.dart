// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/material.dart';
import 'package:mattermost_flutter/types/events.dart';
import 'dart:async';

class TeamSwitchNotifier extends StatefulWidget {
  final Widget child;

  TeamSwitchNotifier({required this.child});

  @override
  _TeamSwitchNotifierState createState() => _TeamSwitchNotifierState();

  static _TeamSwitchNotifierState? of(BuildContext context) {
    return context.findAncestorStateOfType<_TeamSwitchNotifierState>();
  }
}

class _TeamSwitchNotifierState extends State<TeamSwitchNotifier> {
  bool loading = false;
  StreamSubscription? _subscription;

  @override
  void initState() {
    super.initState();
    _subscription = Events.on('TEAM_SWITCH', _handleTeamSwitch);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  void _handleTeamSwitch(bool switching) {
    if (switching) {
      setState(() {
        loading = true;
      });
    } else {
      Future.delayed(Duration(milliseconds: 0), () {
        setState(() {
          loading = false;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

class UseTeamSwitch extends StatelessWidget {
  final Widget child;

  UseTeamSwitch({required this.child});

  @override
  Widget build(BuildContext context) {
    return TeamSwitchNotifier(
      child: child,
    );
  }
}

bool useTeamSwitch(BuildContext context) {
  final notifier = TeamSwitchNotifier.of(context);
  return notifier?.loading ?? false;
}
