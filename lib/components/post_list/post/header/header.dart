
import 'package:flutter/material.dart';
import 'package:mattermost_flutter/components/formatted_time.dart';
import 'package:mattermost_flutter/components/post_priority/post_priority_label.dart';
import 'package:mattermost_flutter/constants/screens.dart';
import 'package:mattermost_flutter/context/theme.dart';
import 'package:mattermost_flutter/i18n.dart';
import 'package:mattermost_flutter/utils/post.dart';
import 'package:mattermost_flutter/utils/theme.dart';
import 'package:mattermost_flutter/utils/typography.dart';
import 'package:mattermost_flutter/utils/user.dart';
import 'package:mattermost_flutter/types/database/models/servers/post.dart';
import 'package:mattermost_flutter/types/database/models/servers/user.dart';

import 'commented_on.dart';
import 'display_name.dart';
import 'reply.dart';
import 'tag.dart';

class Header extends StatelessWidget {
  final UserModel? author;
  final int commentCount;
  final UserModel? currentUser;
  final bool enablePostUsernameOverride;
  final bool isAutoResponse;
  final bool? isCRTEnabled;
  final bool isCustomStatusEnabled;
  final bool isEphemeral;
  final bool isMilitaryTime;
  final bool isPendingOrFailed;
  final bool isSystemPost;
  final bool isWebHook;
  final String location;
  final PostModel post;
  final UserModel? rootPostAuthor;
  final bool showPostPriority;
  final bool? shouldRenderReplyButton;
  final String teammateNameDisplay;
  final bool hideGuestTags;

  Header({
    this.author,
    required this.commentCount,
    this.currentUser,
    required this.enablePostUsernameOverride,
    required this.isAutoResponse,
    this.isCRTEnabled,
    required this.isCustomStatusEnabled,
    required this.isEphemeral,
    required this.isMilitaryTime,
    required this.isPendingOrFailed,
    required this.isSystemPost,
    required this.isWebHook,
    required this.location,
    required this.post,
    this.rootPostAuthor,
    required this.showPostPriority,
    this.shouldRenderReplyButton,
    required this.teammateNameDisplay,
    required this.hideGuestTags,
  });

  @override
  Widget build(BuildContext context) {
    final theme = useTheme(context);
    final style = getStyleSheet(theme);
    final pendingPostStyle = isPendingOrFailed ? style['pendingPost'] : null;
    final isReplyPost = post.rootId != null && !isEphemeral;
    final showReply = !isReplyPost && (location != THREAD) && (shouldRenderReplyButton == true && (!rootPostAuthor && commentCount > 0));
    final displayName = postUserDisplayName(post, author, teammateNameDisplay, enablePostUsernameOverride);
    final rootAuthorDisplayName = rootPostAuthor != null ? displayUsername(rootPostAuthor, currentUser?.locale, teammateNameDisplay, true) : null;
    final customStatus = getUserCustomStatus(author);
    final showCustomStatusEmoji = isCustomStatusEnabled && displayName != null && customStatus != null &&
      !(isSystemPost || author?.isBot == true || isAutoResponse || isWebHook) &&
      !isCustomStatusExpired(author) && customStatus.emoji != null;

    return Column(
      children: [
        Container(
          margin: EdgeInsets.only(top: 10),
          child: Row(
            children: [
              HeaderDisplayName(
                channelId: post.channelId,
                commentCount: commentCount,
                displayName: displayName,
                location: location,
                rootPostAuthor: rootAuthorDisplayName,
                shouldRenderReplyButton: shouldRenderReplyButton,
                theme: theme,
                userIconOverride: post.props?['override_icon_url'],
                userId: post.userId,
                usernameOverride: post.props?['override_username'],
                showCustomStatusEmoji: showCustomStatusEmoji,
                customStatus: customStatus!,
              ),
              if (!isSystemPost || isAutoResponse)
                HeaderTag(
                  isAutoResponder: isAutoResponse,
                  isAutomation: isWebHook || author?.isBot == true,
                  showGuestTag: author?.isGuest == true && !hideGuestTags,
                ),
              FormattedTime(
                timezone: getUserTimezone(currentUser),
                isMilitaryTime: isMilitaryTime,
                value: post.createAt,
                style: style['time'],
                testID: 'post_header.date_time',
              ),
              if (showPostPriority && post.metadata?.priority?.priority != null)
                Container(
                  margin: EdgeInsets.only(left: 6),
                  child: PostPriorityLabel(
                    label: post.metadata!.priority!.priority!,
                  ),
                ),
              if (!isCRTEnabled && showReply && commentCount > 0)
                HeaderReply(
                  commentCount: commentCount,
                  location: location,
                  post: post,
                  theme: theme,
                ),
            ],
          ),
        ),
        if (rootAuthorDisplayName != null && location == CHANNEL)
          HeaderCommentedOn(
            locale: currentUser?.locale ?? DEFAULT_LOCALE,
            name: rootAuthorDisplayName,
            theme: theme,
          ),
      ],
    );
  }

  Map<String, dynamic> getStyleSheet(Theme theme) {
    return {
      'container': {
        'flex': 1,
        'marginTop': 10,
      },
      'pendingPost': {
        'opacity': 0.5,
      },
      'wrapper': {
        'flex': 1,
        'flexDirection': 'row',
      },
      'time': {
        'color': theme.centerChannelColor,
        'marginTop': 5,
        'opacity': 0.5,
        ...typography('Body', 75, 'Regular'),
      },
      'postPriority': {
        'alignSelf': 'center',
        'marginLeft': 6,
      },
    };
  }
}
