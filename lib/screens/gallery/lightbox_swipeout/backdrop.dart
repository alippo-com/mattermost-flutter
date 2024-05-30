// Converted Dart code from React Native TypeScript
// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/material.dart';
import 'package:mattermost_flutter/types/compass_icon.dart';
import 'package:mattermost_flutter/utils/theme.dart';

class Backdrop extends StatelessWidget {
  final Animation<double> translateY;
  final Animation<double> opacity;

  Backdrop({
    required this.translateY,
    required this.opacity,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: translateY,
      builder: (context, child) {
        return Positioned.fill(
          child: Opacity(
            opacity: opacity.value,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black,
              ),
              child: child,
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black,
        ),
      ),
    );
  }
}

// A utility function to create an animation for opacity
Animation<double> createOpacityAnimation(Animation<double> translateY) {
  return Tween<double>(begin: 1, end: 0).animate(
    CurvedAnimation(
      parent: translateY,
      curve: Interval(0, 1, curve: Curves.easeOut),
    ),
  );
}
