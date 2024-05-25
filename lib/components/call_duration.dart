// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CallDuration extends StatefulWidget {
  final TextStyle? style;
  final int value;
  final int? updateIntervalInSeconds;

  CallDuration({
    required this.value,
    this.style,
    this.updateIntervalInSeconds,
  });

  @override
  _CallDurationState createState() => _CallDurationState();
}

class _CallDurationState extends State<CallDuration> {
  late String formattedTime;
  late DateTime startTime;
  late Duration updateInterval;
  late DateFormat formatter;

  @override
  void initState() {
    super.initState();
    startTime = DateTime.fromMillisecondsSinceEpoch(widget.value);
    formattedTime = _getCallDuration();
    if (widget.updateIntervalInSeconds != null) {
      updateInterval = Duration(seconds: widget.updateIntervalInSeconds!);
      _startInterval();
    }
    formatter = DateFormat('mm:ss');
  }

  void _startInterval() {
    Future.delayed(updateInterval, () {
      if (mounted) {
        setState(() {
          formattedTime = _getCallDuration();
        });
        _startInterval();
      }
    });
  }

  String _getCallDuration() {
    final now = DateTime.now();
    if (now.isBefore(startTime)) {
      return '00:00';
    }

    final totalSeconds = now.difference(startTime).inSeconds;
    final seconds = totalSeconds % 60;
    final totalMinutes = totalSeconds ~/ 60;
    final minutes = totalMinutes % 60;
    final hours = totalMinutes ~/ 60;

    if (hours > 0) {
      return '${hours}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      formattedTime,
      style: widget.style,
      maxLines: 1,
      overflow: TextOverflow.clip,
    );
  }
}
