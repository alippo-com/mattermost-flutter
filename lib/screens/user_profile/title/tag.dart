import 'package:flutter/material.dart';
import 'package:mattermost_flutter/components/tag.dart';

class UserProfileTag extends StatelessWidget {
  final bool isBot;
  final bool isChannelAdmin;
  final bool showGuestTag;
  final bool isSystemAdmin;
  final bool isTeamAdmin;

  const UserProfileTag({
    Key? key,
    required this.isBot,
    required this.isChannelAdmin,
    required this.showGuestTag,
    required this.isSystemAdmin,
    required this.isTeamAdmin,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final tagStyle = const BoxDecoration(
      color: Colors.transparent, // specify a background color if needed
      borderRadius: BorderRadius.all(Radius.circular(4.0)),
    );

    final padding = const EdgeInsets.symmetric(horizontal: 6);
    final margin = const EdgeInsets.only(bottom: 4);

    if (isBot) {
      return Container(
        decoration: tagStyle,
        padding: padding,
        margin: margin,
        child: BotTag(
          testID: 'user_profile.bot.tag',
        ),
      );
    }

    if (showGuestTag) {
      return Container(
        decoration: tagStyle,
        padding: padding,
        margin: margin,
        child: GuestTag(
          testID: 'user_profile.guest.tag',
        ),
      );
    }

    if (isSystemAdmin) {
      return Container(
        decoration: tagStyle,
        padding: padding,
        margin: margin,
        child: Tag(
          id: 'user_profile.system_admin',
          defaultMessage: 'System Admin',
          testID: 'user_profile.system_admin.tag',
        ),
      );
    }

    if (isTeamAdmin) {
      return Container(
        decoration: tagStyle,
        padding: padding,
        margin: margin,
        child: Tag(
          id: 'user_profile.team_admin',
          defaultMessage: 'Team Admin',
          testID: 'user_profile.team_admin.tag',
        ),
      );
    }

    if (isChannelAdmin) {
      return Container(
        decoration: tagStyle,
        padding: padding,
        margin: margin,
        child: Tag(
          id: 'user_profile.channel_admin',
          defaultMessage: 'Channel Admin',
          testID: 'user_profile.channel_admin.tag',
        ),
      );
    }

    return SizedBox.shrink();
  }
}
