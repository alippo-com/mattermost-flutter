// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/material.dart';
import 'package:mattermost_flutter/types/events.dart';
import 'dart:async';

class ChannelSwitchNotifier extends StatefulWidget {
  final Widget child;

  ChannelSwitchNotifier({required this.child});

  @override
  _ChannelSwitchNotifierState createState() => _ChannelSwitchNotifierState();

  static _ChannelSwitchNotifierState? of(BuildContext context) {
    return context.findAncestorStateOfType<_ChannelSwitchNotifierState>();
  }
}

class _ChannelSwitchNotifierState extends State<ChannelSwitchNotifier> {
  bool loading = false;
  StreamSubscription? _subscription;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _subscription = Events.on('CHANNEL_SWITCH', _handleChannelSwitch);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _timer?.cancel();
    super.dispose();
  }

  void _handleChannelSwitch(bool switching) {
    _timer?.cancel();
    if (switching) {
      setState(() {
        loading = true;
      });
    } else {
      _timer = Timer(Duration.zero, () {
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

class UseChannelSwitch extends StatelessWidget {
  final Widget child;

  UseChannelSwitch({required this.child});

  @override
  Widget build(BuildContext context) {
    return ChannelSwitchNotifier(
      child: child,
    );
  }
}

bool useChannelSwitch(BuildContext context) {
  final notifier = ChannelSwitchNotifier.of(context);
  return notifier?.loading ?? false;
}
