
// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/material.dart';
import 'dart:io';

class PostListRefreshControl extends StatelessWidget {
  final Widget child;
  final bool enabled;
  final VoidCallback onRefresh;
  final bool refreshing;
  final BoxDecoration? style;

  const PostListRefreshControl({
    required this.child,
    required this.enabled,
    required this.onRefresh,
    required this.refreshing,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    if (Platform.isAndroid) {
      return RefreshIndicator(
        onRefresh: () async => onRefresh(),
        child: child,
      );
    }

    // Placeholder logic for iOS to mimic React.cloneElement behavior
    // This needs to be refined based on actual requirements
    return child;
  }
}
