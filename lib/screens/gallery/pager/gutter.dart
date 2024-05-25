// Converted Dart code from React Native TypeScript
// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/material.dart';
import 'package:mattermost_flutter/types/compass_icon.dart'; // Assuming this is the equivalent import
import 'package:mattermost_flutter/utils/gallery.dart'; // Assuming this is the equivalent import

class Gutter extends StatelessWidget {
  final double width;

  const Gutter({required this.width});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
    );
  }
}
