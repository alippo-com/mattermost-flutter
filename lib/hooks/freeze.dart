// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/material.dart';
import 'package:mattermost_flutter/types/events.dart';

class FreezeScreen extends StatefulWidget {
  @override
  _FreezeScreenState createState() => _FreezeScreenState();
}

class _FreezeScreenState extends State<FreezeScreen> {
  bool freeze = false;
  Color backgroundColor = Colors.black;

  @override
  void initState() {
    super.initState();

    // Register event listener
    Events.on('FREEZE_SCREEN', _handleFreezeScreen);
  }

  @override
  void dispose() {
    // Remove event listener
    Events.off('FREEZE_SCREEN', _handleFreezeScreen);
    super.dispose();
  }

  void _handleFreezeScreen(bool shouldFreeze, [String color = '#000']) {
    setState(() {
      freeze = shouldFreeze;
      backgroundColor = _hexToColor(color);
    });
  }

  Color _hexToColor(String hex) {
    hex = hex.replaceFirst('#', '');
    if (hex.length == 6) {
      hex = 'FF' + hex;
    }
    return Color(int.parse(hex, radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: backgroundColor,
      child: Center(
        child: freeze ? Text('Screen is frozen') : Text('Screen is active'),
      ),
    );
  }
}
