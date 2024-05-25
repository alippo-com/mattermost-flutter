// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:mattermost_flutter/components/compass_icon.dart';
import 'package:mattermost_flutter/components/formatted_text.dart';
import 'package:mattermost_flutter/hooks/theme.dart';
import 'package:mattermost_flutter/utils/theme.dart';
import 'package:mattermost_flutter/utils/typography.dart';

class ResetToDefault extends HookWidget {
  final void Function()? onPress;
  final ValueNotifier<double> topPosition;

  ResetToDefault({
    required this.onPress,
    required this.topPosition,
  });

  @override
  Widget build(BuildContext context) {
    final theme = useTheme(context);
    final styles = _getStyleSheet(theme);

    final animatedTop = useAnimationController(
      duration: const Duration(milliseconds: 100),
    )..animateTo(topPosition.value);

    return AnimatedBuilder(
      animation: animatedTop,
      builder: (context, child) {
        return Positioned(
          top: animatedTop.value,
          right: 20,
          child: Container(
            decoration: BoxDecoration(
              color: theme.centerChannelBg,
            ),
            child: GestureDetector(
              onTap: onPress,
              child: Row(
                children: [
                  CompassIcon(
                    name: 'refresh',
                    size: 18,
                    color: theme.linkColor,
                  ),
                  SizedBox(width: 7),
                  FormattedText(
                    id: 'channel_notification_preferences.reset_default',
                    defaultMessage: 'Reset to default',
                    style: typography('Heading', 100).merge(TextStyle(
                      color: theme.linkColor,
                    )),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  static Map<String, TextStyle> _getStyleSheet(Theme theme) {
    return {
      'container': TextStyle(
        position: 'absolute',
        right: 20,
        zIndex: 1,
      ),
      'row': TextStyle(
        flexDirection: 'row',
      ),
      'text': typography('Heading', 100).merge(TextStyle(
        color: theme.linkColor,
        marginLeft: 7,
      )),
    };
  }
}
