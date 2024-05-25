
// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/material.dart';
import 'package:mattermost_flutter/components/compass_icon.dart';
import 'package:mattermost_flutter/constants/general.dart';
import 'package:mattermost_flutter/context/theme.dart';
import 'package:mattermost_flutter/utils/theme.dart';

class UserStatus extends StatelessWidget {
  final double size;
  final String status;

  UserStatus({
    this.size = 6.0,
    this.status = General.OFFLINE,
  });

  @override
  Widget build(BuildContext context) {
    final theme = useTheme(context);
    String iconName;
    Color iconColor;

    switch (status) {
      case General.AWAY:
        iconName = 'clock';
        iconColor = theme.awayIndicator;
        break;
      case General.DND:
        iconName = 'minus-circle';
        iconColor = theme.dndIndicator;
        break;
      case General.ONLINE:
        iconName = 'check-circle';
        iconColor = theme.onlineIndicator;
        break;
      default:
        iconName = 'circle-outline';
        iconColor = changeOpacity(Color(0xFFB8B8B8), 0.64);
        break;
    }

    return CompassIcon(
      name: iconName,
      style: TextStyle(fontSize: size, color: iconColor),
      testID: 'user_status.indicator.$status',
    );
  }
}
