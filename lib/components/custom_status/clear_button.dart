// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/material.dart';
import 'package:mattermost_flutter/components/compass_icon.dart';
import 'package:mattermost_flutter/utils/tap.dart';
import 'package:mattermost_flutter/utils/theme.dart';
import 'package:mattermost_flutter/types.dart';

class ClearButton extends StatelessWidget {
  final VoidCallback handlePress;
  final double size;
  final double containerSize;
  final ThemeData theme;
  final String? testID;
  final String iconName;

  ClearButton({
    required this.handlePress,
    this.size = 20.0,
    this.containerSize = 40.0,
    required this.theme,
    this.testID,
    this.iconName = 'close-circle',
  });

  @override
  Widget build(BuildContext context) {
    final style = _getStyleSheet(theme);

    return GestureDetector(
      onTap: () => preventDoubleTap(handlePress),
      child: Container(
        height: containerSize,
        width: containerSize,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: changeOpacity(theme.iconTheme.color, 0.52),
        ),
        child: CompassIcon(
          name: iconName,
          size: size,
          color: theme.iconTheme.color,
        ),
      ),
    );
  }

  Map<String, dynamic> _getStyleSheet(ThemeData theme) {
    return {
      'container': BoxDecoration(
        shape: BoxShape.circle,
        color: changeOpacity(theme.iconTheme.color, 0.52),
      ),
      'button': TextStyle(
        color: changeOpacity(theme.iconTheme.color, 0.52),
      ),
    };
  }
}
