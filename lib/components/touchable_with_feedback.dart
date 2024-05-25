// Copyright (c) 2021-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/material.dart';

// Assuming TouchableWithFeedback is a touchable widget, the below is a placeholder for the actual implementation.
class TouchableWithFeedback extends StatelessWidget {
  final Widget child;
  final VoidCallback? onPressed;

  const TouchableWithFeedback({Key? key, required this.child, this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: child,
    );
  }
}