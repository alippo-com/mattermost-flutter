// Dart Code
// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_safe_area/flutter_safe_area.dart';
import 'package:mattermost_flutter/components/compass_icon.dart';
import 'package:mattermost_flutter/components/formatted_text.dart';
import 'package:mattermost_flutter/context/theme.dart';
import 'package:mattermost_flutter/utils/theme.dart';

class ReadOnlyChannel extends StatelessWidget {
  final String? testID;

  ReadOnlyChannel({this.testID});

  @override
  Widget build(BuildContext context) {
    final theme = useTheme();
    final style = _getStyle(theme);

    return SafeArea(
      bottom: true,
      child: Container(
        color: changeOpacity(theme.centerChannelColor, 0.04),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              CompassIcon.glasses,
              size: 20,
              color: changeOpacity(theme.centerChannelColor, 0.56),
            ),
            SizedBox(width: 9),
            FormattedText(
              id: 'mobile.create_post.read_only',
              defaultMessage: 'This channel is read-only.',
              style: TextStyle(
                color: theme.centerChannelColor,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }

  _getStyle(Theme theme) {
    return {
      'background': BoxDecoration(
        color: changeOpacity(theme.centerChannelColor, 0.04),
      ),
      'container': BoxDecoration(
        border: Border(
          top: BorderSide(
            color: changeOpacity(theme.centerChannelColor, 0.20),
            width: 1,
          ),
        ),
        height: 50,
        padding: EdgeInsets.symmetric(horizontal: 12),
        alignment: Alignment.center,
      ),
      'icon': TextStyle(
        fontSize: 20,
        height: 22 / 20,
        color: changeOpacity(theme.centerChannelColor, 0.56),
      ),
      'text': TextStyle(
        color: theme.centerChannelColor,
        fontSize: 15,
        height: 20 / 15,
        marginLeft: 9,
        opacity: 0.56,
      ),
    };
  }
}
