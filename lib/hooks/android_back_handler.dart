// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mattermost_flutter/types/screens/navigation.dart';

class AndroidHardwareBackHandler extends StatefulWidget {
  final AvailableScreens? componentId;
  final VoidCallback callback;

  AndroidHardwareBackHandler({this.componentId, required this.callback});

  @override
  _AndroidHardwareBackHandlerState createState() => _AndroidHardwareBackHandlerState();
}

class _AndroidHardwareBackHandlerState extends State<AndroidHardwareBackHandler> {
  @override
  void initState() {
    super.initState();
    _setupBackHandler();
  }

  void _setupBackHandler() {
    SystemChannels.platform.setMethodCallHandler((call) async {
      if (call.method == 'SystemNavigator.pop') {
        if (NavigationStore.getVisibleScreen() == widget.componentId) {
          widget.callback();
          return true;
        }
        return false;
      }
      return false;
    });
  }

  @override
  void dispose() {
    SystemChannels.platform.setMethodCallHandler(null);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(); // This hook does not render anything
  }
}
