// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/material.dart';
import 'package:mattermost_flutter/components/compass_icon.dart';
import 'package:mattermost_flutter/components/touchable_with_feedback.dart';

class UploadRetry extends StatelessWidget {
  final VoidCallback onPress;

  UploadRetry({required this.onPress});

  @override
  Widget build(BuildContext context) {
    return TouchableWithFeedback(
      onPress: onPress,
      child: Container(
        decoration: BoxDecoration(
          color: Color.fromRGBO(0, 0, 0, 0.8),
          borderRadius: BorderRadius.circular(4),
        ),
        alignment: Alignment.center,
        child: CompassIcon(
          name: 'refresh',
          size: 25,
          color: Colors.white,
        ),
      ),
    );
  }
}
