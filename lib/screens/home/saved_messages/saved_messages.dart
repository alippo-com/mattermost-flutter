import 'package:flutter/material.dart';
import 'package:mattermost_flutter/actions/remote/post.dart';
import 'package:mattermost_flutter/components/loading.dart';
import 'package:mattermost_flutter/components/navigation_header.dart';
import 'package:mattermost_flutter/components/post_list/date_separator.dart';
import 'package:mattermost_flutter/components/post_with_channel_info.dart';
import 'package:mattermost_flutter/components/rounded_header_context.dart';
import 'package:mattermost_flutter/constants/general.dart';
import 'package:mattermost_flutter/constants/screens.dart';
import 'package:mattermost_flutter/context/server.dart';
import 'package:mattermost_flutter/context/theme.dart';
import 'package:mattermost_flutter/hooks/header.dart';
import 'package:mattermost_flutter/typings/components/post_list.dart';
import 'package:mattermost_flutter/typings/database/models/servers/post.dart';
import 'package:mattermost_flutter/utils/post_list.dart';
import 'package:provider/provider.dart';

class SavedMessages extends StatefulWidget {
  final bool appsEnabled;
  final String? currentTimezone;
  final List<String> customEmojiNames;
  final List<PostModel> posts;

  const SavedMessages({
    Key? key,
    required this.appsEnabled,
    required this.currentTimezone,
    required this.customEmojiNames,
    required this.posts,
  }) : super(key: key);

  @override
  _SavedMessagesState createState() => _SavedMessagesState();
}

class _SavedMessagesState extends State<SavedMessages> {
  bool loading = true;
  bool refreshing = false;

  late ThemeData theme;
  late String serverUrl;
  late ScrollController scrollController;

  @override
  void initState() {
    super.initState();
    theme = Provider.of<Theme>(context, listen: false).theme;
    serverUrl = Provider.of<Server>(context, listen: false).serverUrl;
    scrollController = ScrollController();
    fetchSavedPosts();
  }

  Future<void> fetchSavedPosts() async {
    setState(() {
      loading = true;
    });
    await fetchSavedPostsFromServer(serverUrl);
    setState(() {
      loading = false;
    });
  }

  Future<void> handleRefresh() async {
    setState(() {
      refreshing = true;
    });
    await fetchSavedPostsFromServer(serverUrl);
    setState(() {
      refreshing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final posts = widget.posts;
    final data = selectOrderedPosts(posts, 0, false, '', '', false, widget.currentTimezone, false).reversed.toList();

    return Scaffold(
      appBar: NavigationHeader(
        isLargeTitle: true,
        showBackButton: false,
        subtitle: 'All messages you've saved for follow up',
        title: 'Saved Messages',
      ),
      body: SafeArea(
        child: AnimatedBuilder(
          animation: scrollController,
          builder: (context, child) => ListView.builder(
            controller: scrollController,
            itemCount: data.length,
            itemBuilder: (context, index) {
              final item = data[index];
              if (item.type == 'date') {
                return DateSeparator(
                  key: ValueKey(item.value),
                  date: getDateForDateLine(item.value),
                  timezone: widget.currentTimezone,
                );
              } else if (item.type == 'post') {
                return PostWithChannelInfo(
                  key: ValueKey(item.value.currentPost.id),
                  appsEnabled: widget.appsEnabled,
                  customEmojiNames: widget.customEmojiNames,
                  location: Screens.savedMessages,
                  post: item.value.currentPost,
                  testID: 'saved_messages.post_list',
                  skipSavedPostsHighlight: true,
                );
              } else {
                return Container();
              }
            },
          ),
        ),
      ),
    );
  }
}

Future<void> fetchSavedPostsFromServer(String serverUrl) async {
  // Implement the function to fetch saved posts from the server.
}
