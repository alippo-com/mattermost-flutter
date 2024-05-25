
import 'package:flutter/material.dart';
import 'package:mattermost_flutter/components/post_list/post.dart';
import 'package:mattermost_flutter/components/post_with_channel_info/channel_info.dart';
import 'package:mattermost_flutter/types/database/models/servers/post.dart';
import 'package:mattermost_flutter/types/global/markdown.dart';

class PostWithChannelInfo extends StatelessWidget {
  final bool appsEnabled;
  final List<String> customEmojiNames;
  final bool isCRTEnabled;
  final PostModel post;
  final String location;
  final String? testID;
  final List<SearchPattern>? searchPatterns;
  final bool skipSavedPostsHighlight;
  final bool? isSaved;

  const PostWithChannelInfo({
    Key? key,
    required this.appsEnabled,
    required this.customEmojiNames,
    required this.isCRTEnabled,
    required this.post,
    required this.location,
    this.testID,
    this.searchPatterns,
    this.skipSavedPostsHighlight = false,
    this.isSaved,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(0),
      child: Column(
        children: [
          ChannelInfo(
            post: post,
            testID: '${testID}.post_channel_info.${post.id}',
          ),
          Row(
            children: [
              Post(
                appsEnabled: appsEnabled,
                customEmojiNames: customEmojiNames,
                isCRTEnabled: isCRTEnabled,
                post: post,
                location: location,
                highlightPinnedOrSaved: !skipSavedPostsHighlight,
                searchPatterns: searchPatterns,
                skipPinnedHeader: true,
                skipSavedHeader: skipSavedPostsHighlight,
                shouldRenderReplyButton: false,
                showAddReaction: false,
                previousPost: null,
                nextPost: null,
                testID: '${testID}.post',
                isSaved: isSaved,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
