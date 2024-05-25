
import 'package:flutter/material.dart';
import 'package:mattermost_flutter/typings/database/models/servers/post.dart';
import 'package:mattermost_flutter/typings/database/models/servers/user.dart';
import 'package:mattermost_flutter/constants/screens.dart';
import 'package:mattermost_flutter/hooks/show_more.dart';
import 'package:mattermost_flutter/utils/markdown.dart';
import 'package:mattermost_flutter/utils/theme.dart';
import 'package:mattermost_flutter/utils/typography.dart';
import 'package:mattermost_flutter/components/markdown.dart';
import 'package:reanimated/reanimated.dart';

import 'show_more_button.dart';

class Message extends StatefulWidget {
  final UserModel? currentUser;
  final bool? isHighlightWithoutNotificationLicensed;
  final bool highlight;
  final bool isEdited;
  final bool isPendingOrFailed;
  final bool isReplyPost;
  final double? layoutWidth;
  final String location;
  final PostModel post;
  final List<SearchPattern>? searchPatterns;
  final Theme theme;

  const Message({
    this.currentUser,
    this.isHighlightWithoutNotificationLicensed,
    required this.highlight,
    required this.isEdited,
    required this.isPendingOrFailed,
    required this.isReplyPost,
    this.layoutWidth,
    required this.location,
    required this.post,
    this.searchPatterns,
    required this.theme,
  });

  @override
  _MessageState createState() => _MessageState();
}

class _MessageState extends State<Message> {
  bool open = false;
  double? height;
  late double maxHeight;

  @override
  void initState() {
    super.initState();
    maxHeight = (MediaQuery.of(context).size.height * 0.5) + SHOW_MORE_HEIGHT;
  }

  @override
  Widget build(BuildContext context) {
    final animatedStyle = useShowMoreAnimatedStyle(height, maxHeight, open);
    final style = getStyleSheet(widget.theme);
    final blockStyles = getMarkdownBlockStyles(widget.theme);
    final textStyles = getMarkdownTextStyles(widget.theme);

    return Column(
      children: [
        AnimatedContainer(
          duration: Duration(milliseconds: 300),
          height: open ? null : maxHeight,
          child: SingleChildScrollView(
            physics: NeverScrollableScrollPhysics(),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Markdown(
                baseTextStyle: style.message,
                blockStyles: blockStyles,
                channelId: widget.post.channelId,
                channelMentions: widget.post.props?.channelMentions,
                imagesMetadata: widget.post.metadata?.images,
                isEdited: widget.isEdited,
                isReplyPost: widget.isReplyPost,
                isSearchResult: widget.location == SEARCH,
                layoutWidth: widget.layoutWidth,
                location: widget.location,
                postId: widget.post.id,
                textStyles: textStyles,
                value: widget.post.message,
                mentionKeys: widget.currentUser?.mentionKeys ?? EMPTY_MENTION_KEYS,
                highlightKeys: widget.isHighlightWithoutNotificationLicensed == true 
                  ? (widget.currentUser?.highlightKeys ?? EMPTY_HIGHLIGHT_KEYS) 
                  : EMPTY_HIGHLIGHT_KEYS,
                searchPatterns: widget.searchPatterns,
                theme: widget.theme,
                isUnsafeLinksPost: widget.post.props.unsafeLinks != null && widget.post.props.unsafeLinks!.isNotEmpty,
              ),
            ),
          ),
        ),
        if ((height ?? 0) > maxHeight)
          ShowMoreButton(
            highlight: widget.highlight,
            theme: widget.theme,
            showMore: !open,
            onPress: () => setState(() => open = !open),
          ),
      ],
    );
  }

  void _onLayout(BuildContext context, BoxConstraints constraints) {
    setState(() {
      height = constraints.maxHeight;
    });
  }

  Map<String, TextStyle> getTextStyles(Theme theme) {
    return {};
  }

  Map<String, TextStyle> getBlockStyles(Theme theme) {
    return {};
  }

  Map<String, dynamic> getStyleSheet(Theme theme) {
    return {
      "messageContainer": BoxDecoration(
        color: Colors.transparent,
      ),
      "reply": BoxDecoration(
        color: Colors.transparent,
      ),
      "message": TextStyle(
        color: theme.centerChannelColor,
        ...typography('Body', 200),
        height: null, // remove line height, not needed and causes problems with md images
      ),
      "pendingPost": BoxDecoration(
        color: Colors.transparent.withOpacity(0.5),
      ),
    };
  }
}

const double SHOW_MORE_HEIGHT = 54;
const List<UserMentionKey> EMPTY_MENTION_KEYS = [];
const List<HighlightWithoutNotificationKey> EMPTY_HIGHLIGHT_KEYS = [];
