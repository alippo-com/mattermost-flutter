import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'combined_user_activity.dart';
date_separator.dart';
import 'new_message_line.dart';
import 'post.dart';
import 'thread_overview.dart';
import 'more_messages.dart';
import '../constants.dart';
import '../context/server.dart';
import '../context/theme.dart';
import '../utils/post_list.dart'

class PostList extends StatefulWidget {
  final bool appsEnabled;
  final String channelId;
  final TextStyle? contentContainerStyle;
  final String? currentTimezone;
  final String currentUserId;
  final String currentUsername;
  final List<String> customEmojiNames;
  final bool? disablePullToRefresh;
  final String? highlightedId;
  final bool? highlightPinnedOrSaved;
  final bool? isCRTEnabled;
  final bool? isPostAcknowledgementEnabled;
  final int lastViewedAt;
  final String location;
  final String nativeID;
  final Function? onEndReached;
  final List<PostModel> posts;
  final String? rootId;
  final bool? shouldRenderReplyButton;
  final bool shouldShowJoinLeaveMessages;
  final bool? showMoreMessages;
  final bool? showNewMessageLine;
  final Widget? footer;
  final Widget? header;
  final String testID;
  final bool? currentCallBarVisible;
  final Set<String> savedPostIds;

  const PostList({
    Key? key,
    required this.appsEnabled,
    required this.channelId,
    this.contentContainerStyle,
    this.currentTimezone,
    required this.currentUserId,
    required this.currentUsername,
    required this.customEmojiNames,
    this.disablePullToRefresh,
    this.highlightedId,
    this.highlightPinnedOrSaved,
    this.isCRTEnabled,
    this.isPostAcknowledgementEnabled,
    required this.lastViewedAt,
    required this.location,
    required this.nativeID,
    this.onEndReached,
    required this.posts,
    this.rootId,
    this.shouldRenderReplyButton,
    required this.shouldShowJoinLeaveMessages,
    this.showMoreMessages,
    this.showNewMessageLine,
    this.footer,
    this.header,
    required this.testID,
    this.currentCallBarVisible,
    required this.savedPostIds,
  }) : super(key: key);

  @override
  _PostListState createState() => _PostListState();
}

class _PostListState extends State<PostList> {
  final ScrollController _scrollController = ScrollController();
  bool _refreshing = false;
  bool _showScrollToEndBtn = false;
  String? _lastPostId;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _scrollToTop();
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToTop() {
    _scrollController.animateTo(0, duration: Duration(milliseconds: 300), curve: Curves.easeInOut);
  }

  void _onRefresh() async {
    if (widget.disablePullToRefresh ?? false) {
      return;
    }
    setState(() {
      _refreshing = true;
    });
    // Fetch posts logic here
    setState(() {
      _refreshing = false;
    });
  }

  void _onScroll() {
    if (_scrollController.offset > 160) {
      setState(() {
        _showScrollToEndBtn = true;
      });
    } else {
      setState(() {
        _showScrollToEndBtn = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeNotifier>(context);
    final serverUrl = Provider.of<ServerNotifier>(context).serverUrl;
    final orderedPosts = preparePostList(
      widget.posts,
      widget.lastViewedAt,
      widget.showNewMessageLine ?? true,
      widget.currentUserId,
      widget.currentUsername,
      widget.shouldShowJoinLeaveMessages,
      widget.currentTimezone,
      widget.location == Screens.THREAD,
      widget.savedPostIds,
    );

    return Stack(
      children: [
        ListView.builder(
          controller: _scrollController,
          itemCount: orderedPosts.length,
          itemBuilder: (context, index) {
            final item = orderedPosts[index];
            switch (item.type) {
              case 'start-of-new-messages':
                return NewMessagesLine(
                  key: Key(item.value),
                  theme: theme,
                  testID: '${widget.testID}.new_messages_line',
                );
              case 'date':
                return DateSeparator(
                  key: Key(item.value),
                  date: getDateForDateLine(item.value),
                  timezone: widget.currentTimezone,
                );
              case 'thread-overview':
                return ThreadOverview(
                  key: Key(item.value),
                  rootId: widget.rootId!,
                  testID: '${widget.testID}.thread_overview',
                );
              case 'user-activity':
                return CombinedUserActivity(
                  key: Key(item.value),
                  postId: item.value,
                  location: widget.location,
                  showJoinLeave: widget.shouldShowJoinLeaveMessages,
                  theme: theme,
                );
              default:
                final post = item.value.currentPost;
                return Post(
                  key: Key(post.id),
                  post: post,
                  theme: theme,
                  // Additional props based on your requirements
                );
            }
          },
        ),
        if (_showScrollToEndBtn)
          Positioned(
            bottom: 16,
            right: 16,
            child: FloatingActionButton(
              onPressed: _scrollToTop,
              child: Icon(Icons.arrow_downward),
            ),
          ),
      ],
    );
  }
}
