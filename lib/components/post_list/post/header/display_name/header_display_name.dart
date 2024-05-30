import 'package:flutter/material.dart';
import 'package:mattermost_flutter/utils/theme.dart';
import 'package:mattermost_flutter/components/custom_status_emoji.dart';
import 'package:mattermost_flutter/components/formatted_text.dart';
import 'package:mattermost_flutter/constants.dart';
import 'package:mattermost_flutter/utils/tap.dart';
import 'package:mattermost_flutter/utils/typography.dart';
import 'package:mattermost_flutter/context/theme.dart';

class HeaderDisplayName extends StatelessWidget {
  final String channelId;
  final int commentCount;
  final String? displayName;
  final String location;
  final String? rootPostAuthor;
  final bool? shouldRenderReplyButton;
  final ThemeData theme;
  final String? userIconOverride;
  final String userId;
  final String? usernameOverride;
  final bool showCustomStatusEmoji;
  final UserCustomStatus customStatus;

  HeaderDisplayName({
    required this.channelId,
    required this.commentCount,
    this.displayName,
    required this.location,
    this.rootPostAuthor,
    this.shouldRenderReplyButton,
    required this.theme,
    this.userIconOverride,
    required this.userId,
    this.usernameOverride,
    required this.showCustomStatusEmoji,
    required this.customStatus,
  });

  @override
  Widget build(BuildContext context) {
    final style = _getStyleSheet(theme);
    final intl = AppLocalizations.of(context);

    void onPress() {
      final screen = Screens.USER_PROFILE;
      final title = intl.translate('mobile.routes.user_profile', 'Profile');
      final closeButtonId = 'close-user-profile';
      final props = UserProfileScreenArguments(
        closeButtonId: closeButtonId,
        userId: userId,
        channelId: channelId,
        location: location,
        userIconOverride: userIconOverride,
        usernameOverride: usernameOverride,
      );

      FocusScope.of(context).unfocus();
      Navigator.pushNamed(context, screen, arguments: props);
    }

    final displayNameWidth = _calcNameWidth(context, style);
    final displayNameContainerStyle = [style['displayNameContainer'], displayNameWidth];
    final displayNameStyle = showCustomStatusEmoji ? style['displayNameCustomEmojiWidth'] : null;

    if (displayName != null && displayName!.isNotEmpty) {
      return GestureDetector(
        onTap: onPress,
        child: Container(
          child: Row(
            children: [
              Container(
                width: displayNameStyle != null ? MediaQuery.of(context).size.width * 0.9 : null,
                child: Text(
                  displayName!,
                  style: style['displayName'],
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              if (showCustomStatusEmoji)
                CustomStatusEmoji(
                  customStatus: customStatus,
                  style: style['customStatusEmoji'],
                ),
            ],
          ),
        ),
      );
    }

    return Container(
      child: FormattedText(
        id: 'channel_loader.someone',
        defaultMessage: 'Someone',
        style: style['displayName'],
      ),
    );
  }

  Map<String, dynamic> _calcNameWidth(BuildContext context, Map<String, dynamic> style) {
    final isLandscape = MediaQuery.of(context).size.width > MediaQuery.of(context).size.height;
    final showReply = shouldRenderReplyButton ?? false || (rootPostAuthor == null && commentCount > 0);

    if (showReply && isLandscape) {
      return style['displayNameContainerLandscapeBotReplyWidth'];
    } else if (isLandscape) {
      return style['displayNameContainerLandscape'];
    } else if (showReply) {
      return style['displayNameContainerBotReplyWidth'];
    }
    return {};
  }

  Map<String, dynamic> _getStyleSheet(ThemeData theme) {
    return {
      'displayName': {
        'color': theme.textTheme.bodyLarge!.color,
        'flexGrow': 1,
        'marginRight': 5,
        ...typography('Body', 200, 'SemiBold'),
      },
      'displayNameCustomEmojiWidth': {
        'maxWidth': '90%',
      },
      'displayNameContainer': {
        'maxWidth': '60%',
        'flexDirection': 'row',
        'alignItems': 'center',
      },
      'displayNameContainerBotReplyWidth': {
        'maxWidth': '50%',
      },
      'displayNameContainerLandscape': {
        'maxWidth': '80%',
      },
      'displayNameContainerLandscapeBotReplyWidth': {
        'maxWidth': '70%',
      },
      'customStatusEmoji': {
        'color': theme.textTheme.bodyLarge!.color,
        'marginRight': 4,
      },
    };
  }
}
