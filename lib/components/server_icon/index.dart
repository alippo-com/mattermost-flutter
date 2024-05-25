
import 'package:flutter/material.dart';
import 'package:mattermost_flutter/types.dart';
import 'package:mattermost_flutter/components/badge.dart';
import 'package:mattermost_flutter/components/compass_icon.dart';
import 'package:mattermost_flutter/components/touchable_with_feedback.dart';
import 'package:mattermost_flutter/context/theme.dart';
import 'package:mattermost_flutter/utils/theme.dart';

class ServerIcon extends StatelessWidget {
  final String? badgeBackgroundColor;
  final String? badgeBorderColor;
  final String? badgeColor;
  final TextStyle? badgeStyle;
  final bool hasUnreads;
  final String? iconColor;
  final int mentionCount;
  final VoidCallback? onPress;
  final double size;
  final TextStyle? style;
  final String? testID;
  final TextStyle? unreadStyle;

  ServerIcon({
    this.badgeBackgroundColor,
    this.badgeBorderColor,
    this.badgeColor,
    this.badgeStyle,
    required this.hasUnreads,
    this.iconColor,
    required this.mentionCount,
    this.onPress,
    this.size = 24.0,
    this.style,
    this.testID,
    this.unreadStyle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = useTheme(context);
    final bool hasBadge = mentionCount > 0 || hasUnreads;
    final int count = mentionCount > 0 ? mentionCount : (hasUnreads ? -1 : 0);

    final memoizedStyle = [
      badgeStyle ?? styles['badge'],
      if (count == -1) unreadStyle ?? styles['unread']
    ];

    return Container(
      child: TouchableWithFeedback(
        disabled: onPress == null,
        onPress: onPress,
        type: 'opacity',
        testID: testID,
        hitSlop: const EdgeInsets.fromLTRB(40, 20, 20, 5),
        child: Column(
          children: [
            CompassIcon(
              size: size,
              name: 'server-variant',
              color: iconColor ?? changeOpacity(theme['sidebarHeaderTextColor'], 0.56),
            ),
            Badge(
              borderColor: badgeBorderColor ?? theme['sidebarTeamBarBg'],
              backgroundColor: badgeBackgroundColor,
              color: badgeColor,
              visible: hasBadge,
              style: memoizedStyle,
              testID: '$testID.badge',
              value: count,
            ),
          ],
        ),
      ),
    );
  }

  static const styles = {
    'badge': TextStyle(
      left: 13,
      top: -8,
    ),
    'unread': TextStyle(
      left: 18,
      top: -5,
    ),
  };
}
