// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/material.dart';
import 'package:mattermost_flutter/types/theme.dart';
import 'package:mattermost_flutter/utils/theme.dart';

class CustomStatusText extends StatelessWidget {
  final String text;
  final Theme theme;
  final TextStyle textStyle;
  final TextOverflow ellipsizeMode;
  final int numberOfLines;
  final String testID;

  CustomStatusText({
    required this.text,
    required this.theme,
    this.textStyle,
    this.ellipsizeMode = TextOverflow.clip,
    this.numberOfLines = 1,
    this.testID,
  });

  @override
  Widget build(BuildContext context) {
    final labelStyle = TextStyle(
      color: changeOpacity(theme.centerChannelColor, 0.5),
      fontSize: 17,
      textBaseline: TextBaseline.alphabetic,
    );

    return Text(
      text,
      style: labelStyle.merge(textStyle),
      overflow: ellipsizeMode,
      maxLines: numberOfLines,
      key: Key(testID),
    );
  }
}
