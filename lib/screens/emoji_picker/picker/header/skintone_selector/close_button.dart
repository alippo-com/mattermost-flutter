// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/material.dart';
import 'package:mattermost_flutter/components/compass_icon.dart';
import 'package:mattermost_flutter/context/theme.dart';
import 'package:mattermost_flutter/utils/theme.dart';

class CloseButton extends StatelessWidget {
  final VoidCallback collapse;

  CloseButton({required this.collapse});

  @override
  Widget build(BuildContext context) {
    final theme = useTheme(context);
    final hitSlop = EdgeInsets.all(10.0);

    return GestureDetector(
      onTap: collapse,
      child: Container(
        padding: hitSlop,
        child: CompassIcon(
          name: 'close',
          size: 24.0,
          color: changeOpacity(theme.centerChannelColor, 0.56),
        ),
      ),
    );
  }
}
