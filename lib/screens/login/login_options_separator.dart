// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/material.dart';
import 'package:mattermost_flutter/types/theme.dart';
import 'package:mattermost_flutter/utils/theme.dart';
import 'package:mattermost_flutter/components/formatted_text.dart';

class LoginOptionsSeparator extends StatelessWidget {
  final Theme theme;

  LoginOptionsSeparator({required this.theme});

  @override
  Widget build(BuildContext context) {
    final styles = getStyleFromTheme(theme);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: Container(
            height: 0.4,
            color: changeOpacity(theme.centerChannelColor, 0.16),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6.0),
          child: FormattedText(
            id: 'mobile.login_options.separator_text',
            defaultMessage: 'or log in with',
            style: TextStyle(
              color: changeOpacity(theme.centerChannelColor, 0.64),
              fontFamily: 'OpenSans',
              fontSize: 12,
              height: 1.2, // Equivalent to top: -2 in Flutter
            ),
            testID: 'mobile.login_options.separator_text',
          ),
        ),
        Expanded(
          child: Container(
            height: 0.4,
            color: changeOpacity(theme.centerChannelColor, 0.16),
          ),
        ),
      ],
    );
  }

  Map<String, dynamic> getStyleFromTheme(Theme theme) {
    return {
      'container': {
        'flexDirection': 'row',
        'alignItems': 'center',
        'color': changeOpacity(theme.centerChannelColor, 0.64),
      },
      'line': {
        'flex': 1,
        'height': 0.4,
        'backgroundColor': changeOpacity(theme.centerChannelColor, 0.16),
      },
      'text': {
        'marginRight': 6,
        'marginLeft': 6,
        'textAlign': 'center',
        'color': changeOpacity(theme.centerChannelColor, 0.64),
        'fontFamily': 'OpenSans',
        'fontSize': 12,
        'top': -2,
      },
    };
  }
}
