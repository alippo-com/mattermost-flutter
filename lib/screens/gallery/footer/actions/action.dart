// Converted Dart code from React Native TypeScript
// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/material.dart';
import 'package:mattermost_flutter/types/compass_icon.dart';
import 'package:mattermost_flutter/utils/theme.dart';

class Action extends StatelessWidget {
  final bool disabled;
  final String iconName;
  final VoidCallback onPress;
  final BoxDecoration? style;

  Action({
    required this.disabled,
    required this.iconName,
    required this.onPress,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: disabled ? null : onPress,
      child: Container(
        width: 40,
        height: 40,
        decoration: style,
        child: Center(
          child: CompassIcon(
            color: changeOpacity(Colors.white, disabled ? 0.4 : 1),
            name: iconName,
            size: 24,
          ),
        ),
      ),
    );
  }
}
