
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mattermost_flutter/components/files.dart';
import 'package:mattermost_flutter/components/formatted_text.dart';
import 'package:mattermost_flutter/components/jumbo_emoji.dart';
import 'package:mattermost_flutter/constants/screens.dart';
import 'package:mattermost_flutter/utils/post.dart';
import 'package:mattermost_flutter/utils/theme.dart';
import 'package:mattermost_flutter/types/database/models/servers/post.dart';
import 'package:mattermost_flutter/types/global/markdown.dart';

import 'acknowledgements.dart';
import 'add_members.dart';
import 'content.dart';
import 'failed.dart';
import 'message.dart';
import 'reactions.dart';

class Body extends StatefulWidget {
  final bool appsEnabled;
  final bool hasFiles;
  final bool hasReactions;
  final bool highlight;
  final bool highlightReplyBar;
  final bool? isCRTEnabled;
  final bool isEphemeral;
  final bool? isFirstReply;
  final bool isJumboEmoji;
  final bool? isLastReply;
  final bool isPendingOrFailed;
  final bool? isPostAcknowledgementEnabled;
  final bool isPostAddChannelMember;
  final String location;
  final PostModel post;
  final List<SearchPattern>? searchPatterns;
  final bool? showAddReaction;
  final Theme theme;

  Body({
    required this.appsEnabled,
    required this.hasFiles,
    required this.hasReactions,
    required this.highlight,
    required this.highlightReplyBar,
    this.isCRTEnabled,
    required this.isEphemeral,
    this.isFirstReply,
    required this.isJumboEmoji,
    this.isLastReply,
    required this.isPendingOrFailed,
    this.isPostAcknowledgementEnabled,
    required this.isPostAddChannelMember,
    required this.location,
    required this.post,
    this.searchPatterns,
    this.showAddReaction,
    required this.theme,
  });

  @override
  _BodyState createState() => _BodyState();
}

class _BodyState extends State<Body> {
  double layoutWidth = 0;

  TextStyle getStyleSheet(Theme theme) {
    return TextStyle(
      color: theme.centerChannelColor,
      fontSize: 15,
      lineHeight: 20,
    );
  }

  @override
  Widget build(BuildContext context) {
    final style = getStyleSheet(widget.theme);
    final isEdited = postEdited(widget.post);
    final isFailed = isPostFailed(widget.post);
    final hasBeenDeleted = widget.post.deleteAt != null;
    final isReplyPost = widget.post.rootId != null && (!widget.isEphemeral || !hasBeenDeleted) && widget.location != THREAD;
    final hasContent = widget.post.metadata?.embeds?.isNotEmpty == true || (widget.appsEnabled && widget.post.props?.appBindings?.isNotEmpty == true) || widget.post.props?.attachments?.isNotEmpty == true;

    Widget body;
    Widget? message;

    if (hasBeenDeleted) {
      body = FormattedText(
        style: style,
        id: 'post_body.deleted',
        defaultMessage: '(message deleted)',
      );
    } else if (widget.isPostAddChannelMember) {
      message = AddMembers(
        location: widget.location,
        post: widget.post,
        theme: widget.theme,
      );
    } else if (widget.isJumboEmoji) {
      message = JumboEmoji(
        baseTextStyle: style,
        isEdited: isEdited,
        value: widget.post.message,
      );
    } else if (widget.post.message.isNotEmpty) {
      message = Message(
        highlight: widget.highlight,
        isEdited: isEdited,
        isPendingOrFailed: widget.isPendingOrFailed,
        isReplyPost: isReplyPost,
        layoutWidth: layoutWidth,
        location: widget.location,
        post: widget.post,
        searchPatterns: widget.searchPatterns,
        theme: widget.theme,
      );
    }

    final acknowledgementsVisible = widget.isPostAcknowledgementEnabled == true && widget.post.metadata?.priority?.requestedAck == true;
    final reactionsVisible = widget.hasReactions && widget.showAddReaction == true;

    if (!hasBeenDeleted) {
      body = Column(
        children: [
          message ?? Container(),
          if (hasContent)
            Content(
              isReplyPost: isReplyPost,
              layoutWidth: layoutWidth,
              location: widget.location,
              post: widget.post,
              theme: widget.theme,
            ),
          if (widget.hasFiles)
            Files(
              failed: isFailed,
              layoutWidth: layoutWidth,
              location: widget.location,
              post: widget.post,
              isReplyPost: isReplyPost,
            ),
          if (acknowledgementsVisible || reactionsVisible)
            Row(
              children: [
                if (acknowledgementsVisible)
                  Acknowledgements(
                    hasReactions: widget.hasReactions,
                    location: widget.location,
                    post: widget.post,
                    theme: widget.theme,
                  ),
                if (reactionsVisible)
                  Reactions(
                    location: widget.location,
                    post: widget.post,
                    theme: widget.theme,
                  ),
              ],
            ),
        ],
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return Row(
          children: [
            if (isReplyPost && !widget.isCRTEnabled == true && widget.location != Screens.PERMALINK)
              Container(
                width: 3,
                decoration: BoxDecoration(
                  color: widget.theme.centerChannelColor,
                  opacity: 0.1,
                ),
                margin: EdgeInsets.symmetric(horizontal: 1),
              ),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  if (widget.location == Screens.SAVED_MESSAGES) {
                    setState(() {
                      layoutWidth = constraints.maxWidth;
                    });
                  }
                },
                child: Column(
                  children: [
                    body,
                    if (isFailed)
                      Failed(
                        post: widget.post,
                        theme: widget.theme,
                      ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
