// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/material.dart';
import 'package:mattermost_flutter/components/compass_icon.dart';
import 'package:mattermost_flutter/components/loading.dart';
import 'package:mattermost_flutter/components/touchable_with_feedback.dart';
import 'package:mattermost_flutter/utils/theme.dart';
import 'package:mattermost_flutter/utils/typography.dart';

class LoadingError extends StatelessWidget {
  final bool loading;
  final String message;
  final VoidCallback onRetry;
  final String title;

  const LoadingError({
    Key? key,
    required this.loading,
    required this.message,
    required this.onRetry,
    required this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = useTheme(context);
    final styles = getStyleSheet(theme);
    final buttonStyle = [
      SizedBox(height: 24),
      buttonBackgroundStyle(theme, 'lg', 'primary', 'inverted'),
    ];

    if (loading) {
      return Loading(
        containerStyle: styles['container'],
        color: theme.buttonBg,
      );
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          height: 120,
          width: 120,
          decoration: BoxDecoration(
            color: changeOpacity(theme.sidebarText, 0.08),
            borderRadius: BorderRadius.circular(60),
          ),
          child: Center(
            child: CompassIcon(
              name: 'alert-circle-outline',
              style: styles['icon'],
            ),
          ),
        ),
        Text(
          title,
          style: typography('Heading', 400).merge(styles['header']),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 4),
        Text(
          message,
          style: typography('Body', 200).merge(styles['body']),
          textAlign: TextAlign.center,
        ),
        TouchableWithFeedback(
          style: buttonStyle,
          onPress: onRetry,
          type: 'opacity',
          child: Text(
            'Retry',
            style: buttonTextStyle(theme, 'lg', 'primary', 'inverted'),
          ),
        ),
      ],
    );
  }

  getStyleSheet(ThemeData theme) {
    return {
      'container': BoxDecoration(
        alignItems: Alignment.center,
        justifyContent: MainAxisAlignment.center,
        padding: EdgeInsets.all(20),
      ),
      'iconWrapper': BoxDecoration(
        height: 120,
        width: 120,
        backgroundColor: changeOpacity(theme.sidebarText, 0.08),
        borderRadius: BorderRadius.circular(60),
        justifyContent: MainAxisAlignment.center,
        alignItems: Alignment.center,
      ),
      'icon': TextStyle(
        fontSize: 72,
        lineHeight: 72,
        color: changeOpacity(theme.sidebarText, 0.48),
      ),
      'header': TextStyle(
        color: theme.sidebarHeaderTextColor,
        marginTop: 20,
        textAlign: TextAlign.center,
      ),
      'body': TextStyle(
        color: theme.sidebarText,
        textAlign: TextAlign.center,
        marginTop: 4,
      ),
    };
  }
}
