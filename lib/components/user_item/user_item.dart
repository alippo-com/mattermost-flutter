
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mattermost_flutter/types/database/user_model.dart';
import 'package:mattermost_flutter/components/compass_icon.dart';
import 'package:mattermost_flutter/components/custom_status/custom_status_emoji.dart';
import 'package:mattermost_flutter/components/profile_picture.dart';
import 'package:mattermost_flutter/components/tag.dart';
import 'package:mattermost_flutter/utils/strings.dart';
import 'package:mattermost_flutter/utils/theme.dart';

class UserItem extends StatelessWidget {
  final Widget? footerComponent;
  final UserProfile? user;
  final BoxDecoration? containerStyle;
  final String currentUserId;
  final bool includeMargin;
  final double size;
  final String? testID;
  final bool isCustomStatusEnabled;
  final bool showBadges;
  final String? locale;
  final String teammateNameDisplay;
  final Widget? rightDecorator;
  final Function(UserProfile)? onUserPress;
  final Function(UserProfile)? onUserLongPress;
  final Function()? onLayout;
  final bool disabled;
  final GlobalKey? viewRef;
  final double? padding;
  final bool hideGuestTags;

  UserItem({
    this.footerComponent,
    this.user,
    this.containerStyle,
    required this.currentUserId,
    this.includeMargin = false,
    this.size = 24,
    this.testID,
    required this.isCustomStatusEnabled,
    this.showBadges = false,
    this.locale,
    required this.teammateNameDisplay,
    this.rightDecorator,
    this.onUserPress,
    this.onUserLongPress,
    this.onLayout,
    this.disabled = false,
    this.viewRef,
    this.padding,
    required this.hideGuestTags,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeData>(context);
    final style = _getThemedStyles(theme);

    final bot = user != null ? isBot(user!) : false;
    final guest = user != null ? isGuest(user!.roles) : false;
    final shared = user != null ? isShared(user!) : false;
    final deactivated = user != null ? isDeactivated(user!) : false;

    final isCurrentUser = currentUserId == user?.id;
    final customStatus = getUserCustomStatus(user);
    final customStatusExpired = isCustomStatusExpired(user);

    var displayName = displayUsername(user, locale, teammateNameDisplay);
    final showTeammateDisplay = displayName != user?.username;
    if (isCurrentUser) {
      displayName = 'You ($displayName)';
    }

    final userItemTestId = '$testID.${user?.id}';

    final containerViewStyle = [
      style['row'],
      BoxDecoration(
        color: disabled ? Colors.grey.withOpacity(0.32) : Colors.transparent,
        padding: EdgeInsets.symmetric(horizontal: padding ?? 0),
      ),
      if (includeMargin) style['margin'],
    ];

    return GestureDetector(
      onTap: () => onUserPress?.call(user!),
      onLongPress: () => onUserLongPress?.call(user!),
      onLayout: (_) => onLayout?.call(),
      child: Container(
        key: viewRef,
        decoration: containerStyle,
        child: Row(
          children: [
            ProfilePicture(
              user: user,
              size: size,
              showStatus: false,
              testID: '$userItemTestId.profile_picture',
              containerStyle: style['profile'],
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        nonBreakingString(displayName),
                        style: style['rowFullname'],
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (showTeammateDisplay && user?.username != null)
                        Text(
                          nonBreakingString(' @${user!.username}'),
                          style: style['rowUsername'],
                        ),
                      if (deactivated)
                        Text(
                          nonBreakingString(' Deactivated'),
                          style: style['rowUsername'],
                        ),
                    ],
                  ),
                  if (showBadges && bot)
                    BotTag(
                      testID: '$userItemTestId.bot.tag',
                      style: style['tag'],
                    ),
                  if (showBadges && guest && !hideGuestTags)
                    GuestTag(
                      testID: '$userItemTestId.guest.tag',
                      style: style['tag'],
                    ),
                  if (isCustomStatusEnabled && !bot && customStatus?.emoji != null && !customStatusExpired)
                    CustomStatusEmoji(
                      customStatus: customStatus!,
                      style: style['icon'],
                    ),
                  if (shared)
                    CompassIcon(
                      icon: Icons.circle,
                      size: 16,
                      color: theme.centerChannelColor,
                      style: style['icon'],
                    ),
                  if (rightDecorator != null) rightDecorator!,
                ],
              ),
            ),
            if (footerComponent != null) footerComponent!,
          ],
        ),
      ),
    );
  }

  Map<String, dynamic> _getThemedStyles(ThemeData theme) {
    return {
      'rowPicture': BoxDecoration(
        margin: EdgeInsets.only(right: 10, left: 2),
        width: 24,
        alignment: Alignment.center,
        justifyContent: MainAxisAlignment.center,
      ),
      'rowFullname': TextStyle(
        fontSize: 16,
        color: theme.textTheme.bodyLarge?.color,
      ),
      'rowUsername': TextStyle(
        fontSize: 12,
        color: theme.textTheme.bodyMedium?.color?.withOpacity(0.64),
      ),
      'row': BoxDecoration(
        height: 40,
        padding: EdgeInsets.only(bottom: 8, top: 4),
        flexDirection: Axis.horizontal,
        alignment: Alignment.center,
      ),
      'margin': BoxDecoration(margin: EdgeInsets.symmetric(vertical: 8)),
      'rowInfoBaseContainer': BoxDecoration(flex: 1),
      'rowInfoContainer': BoxDecoration(
        flex: 1,
        flexDirection: Axis.horizontal,
      ),
      'icon': BoxDecoration(margin: EdgeInsets.only(left: 4)),
      'profile': BoxDecoration(margin: EdgeInsets.only(right: 12)),
      'tag': BoxDecoration(margin: EdgeInsets.only(left: 6)),
      'flex': BoxDecoration(flex: 1),
    };
  }
}
