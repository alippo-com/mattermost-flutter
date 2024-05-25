import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:mattermost_flutter/components/badge.dart';
import 'package:mattermost_flutter/components/channel_icon.dart';
import 'package:mattermost_flutter/components/compass_icon.dart';
import 'package:mattermost_flutter/constants.dart';
import 'package:mattermost_flutter/theme.dart';
import 'package:mattermost_flutter/utils/channel.dart';
import 'package:mattermost_flutter/utils/theme.dart';
import 'package:mattermost_flutter/utils/typography.dart';
import 'package:mattermost_flutter/utils/user.dart';

import 'channel_body.dart';

class ChannelItem extends StatelessWidget {
  final ChannelModel channel;
  final String currentUserId;
  final bool hasDraft;
  final bool isActive;
  final bool isMuted;
  final int membersCount;
  final bool isUnread;
  final int mentionsCount;
  final Function(ChannelModel) onPress;
  final String? teamDisplayName;
  final String? testID;
  final bool hasCall;
  final bool isOnCenterBg;
  final bool showChannelName;
  final bool isOnHome;

  static const double ROW_HEIGHT = 40;
  static const double ROW_HEIGHT_WITH_TEAM = 58;

  ChannelItem({
    required this.channel,
    required this.currentUserId,
    required this.hasDraft,
    required this.isActive,
    required this.isMuted,
    required this.membersCount,
    required this.isUnread,
    required this.mentionsCount,
    required this.onPress,
    this.teamDisplayName,
    this.testID,
    required this.hasCall,
    required this.isOnCenterBg,
    required this.showChannelName,
    required this.isOnHome,
  });

  @override
  Widget build(BuildContext context) {
    final theme = useTheme(context);
    final isTablet = useIsTablet(context);
    final styles = getStyleSheet(theme);

    final channelName = (showChannelName && !isDMorGM(channel)) ? channel.name : '';

    // Make it bolded if it has unreads or mentions
    final isBolded = isUnread || mentionsCount > 0;
    final showActive = isActive && isTablet;

    final teammateId = (channel.type == General.DM_CHANNEL) ? getUserIdFromChannelName(currentUserId, channel.name) : null;
    final isOwnDirectMessage = (channel.type == General.DM_CHANNEL) && currentUserId == teammateId;

    var displayName = channel.displayName ?? channel.display_name;
    if (isOwnDirectMessage) {
      displayName = '$displayName (you)';
    }

    final deleteAt = channel.deleteAt ?? channel.delete_at;
    final channelItemTestId = '$testID.${channel.name}';

    final height = (teamDisplayName != null && !isTablet) ? ROW_HEIGHT_WITH_TEAM : ROW_HEIGHT;

    final textStyles = [
      isBolded && !isMuted ? textStyleBold : textStyleRegular,
      styles.text,
      isBolded ? styles.highlight : null,
      showActive ? styles.textActive : null,
      isOnCenterBg ? styles.textOnCenterBg : null,
      isMuted ? styles.muted : null,
      isMuted && isOnCenterBg ? styles.mutedOnCenterBg : null,
    ].whereType<TextStyle>().toList();

    final containerStyle = [
      styles.container,
      isOnHome ? HOME_PADDING : null,
      showActive ? styles.activeItem : null,
      showActive && isOnHome
          ? {
              'paddingLeft': HOME_PADDING.paddingLeft - styles.activeItem.borderLeftWidth,
            }
          : null,
      {'minHeight': height},
    ].whereType<BoxDecoration>().toList();

    return GestureDetector(
      onTap: () => onPress(channel),
      child: Container(
        decoration: BoxDecoration(containerStyle),
        child: Row(
          children: [
            ChannelIcon(
              hasDraft: hasDraft,
              isActive: isTablet && isActive,
              isOnCenterBg: isOnCenterBg,
              isUnread: isBolded,
              isArchived: deleteAt > 0,
              membersCount: membersCount,
              name: channel.name,
              shared: channel.shared,
              size: 24,
              type: channel.type,
              isMuted: isMuted,
              style: styles.icon,
            ),
            ChannelBody(
              displayName: displayName,
              isMuted: isMuted,
              teamDisplayName: teamDisplayName,
              teammateId: teammateId,
              testId: channelItemTestId,
              textStyles: textStyles,
              channelName: channelName,
            ),
            Expanded(child: Container()),
            Badge(
              visible: mentionsCount > 0,
              value: mentionsCount,
              style: styles.badge,
            ),
            if (hasCall)
              CompassIcon(
                name: 'phone-in-talk',
                size: 16,
                style: styles.hasCall,
              ),
          ],
        ),
      ),
    );
  }
}

TextStyle get textStyleBold => typography('Body', 200, 'SemiBold');
TextStyle get textStyleRegular => typography('Body', 200, 'Regular');

BoxDecoration getStyleSheet(Theme theme) {
  return BoxDecoration(
    container: BoxDecoration(
      flexDirection: 'row',
      alignItems: 'center',
    ),
    icon: BoxDecoration(
      marginRight: 12,
    ),
    text: BoxDecoration(
      color: changeOpacity(theme.sidebarText, 0.72),
    ),
    highlight: BoxDecoration(
      color: theme.sidebarUnreadText,
    ),
    textOnCenterBg: BoxDecoration(
      color: theme.centerChannelColor,
    ),
    muted: BoxDecoration(
      color: changeOpacity(theme.sidebarText, 0.32),
    ),
    mutedOnCenterBg: BoxDecoration(
      color: changeOpacity(theme.centerChannelColor, 0.32),
    ),
    badge: BoxDecoration(
      borderColor: theme.sidebarBg,
      marginLeft: 4,
    ),
    badgeOnCenterBg: BoxDecoration(
      color: theme.buttonColor,
      backgroundColor: theme.buttonBg,
      borderColor: theme.centerChannelBg,
    ),
    mutedBadge: BoxDecoration(
      opacity: 0.32,
    ),
    activeItem: BoxDecoration(
      backgroundColor: changeOpacity(theme.sidebarTextActiveColor, 0.1),
      borderLeftColor: theme.sidebarTextActiveBorder,
      borderLeftWidth: 5,
    ),
    textActive: BoxDecoration(
      color: theme.sidebarText,
    ),
    hasCall: BoxDecoration(
      textAlign: 'right',
    ),
    filler: BoxDecoration(
      flex: 1,
    ),
  );
}
