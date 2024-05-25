// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:provider/provider.dart';
import 'package:mattermost_flutter/components/loading.dart';
import 'package:mattermost_flutter/components/date_separator.dart';
import 'package:mattermost_flutter/components/post.dart';
import 'package:mattermost_flutter/constants/screens.dart';
import 'package:mattermost_flutter/constants/events.dart';
import 'package:mattermost_flutter/context/server.dart';
import 'package:mattermost_flutter/context/theme.dart';
import 'package:mattermost_flutter/hooks/android_back_handler.dart';
import 'package:mattermost_flutter/utils/post_list.dart';
import 'package:mattermost_flutter/components/empty_state.dart';

class PinnedMessages extends HookWidget {
  final bool appsEnabled;
  final String channelId;
  final String componentId;
  final String? currentTimezone;
  final List<String> customEmojiNames;
  final bool isCRTEnabled;
  final List<PostModel> posts;

  PinnedMessages({
    required this.appsEnabled,
    required this.channelId,
    required this.componentId,
    this.currentTimezone,
    required this.customEmojiNames,
    required this.isCRTEnabled,
    required this.posts,
  });

  @override
  Widget build(BuildContext context) {
    final theme = useTheme();
    final serverUrl = useServerUrl();
    final data = useMemo(() => selectOrderedPosts(posts, 0, false, '', '', false, currentTimezone, false).reversed.toList(), [posts]);

    final loading = useState(!posts.isNotEmpty);
    final refreshing = useState(false);

    final close = useCallback(() {
      if (componentId.isNotEmpty) {
        Navigator.of(context).pop();
      }
    }, [componentId]);

    useEffect(() {
      fetchPinnedPosts(serverUrl, channelId).whenComplete(() {
        loading.value = false;
      });
    }, []);

    useAndroidHardwareBackHandler(componentId, close);

    final onViewableItemsChanged = useCallback((viewableItems) {
      if (viewableItems.isEmpty) {
        return;
      }

      final viewableItemsMap = viewableItems.fold<Map<String, bool>>({}, (acc, item) {
        if (item.isViewable && item.type == 'post') {
          acc['${Screens.PINNED_MESSAGES}-${item.value.currentPost.id}'] = true;
        }
        return acc;
      });

      DeviceEventEmitter.emit(Events.ITEM_IN_VIEWPORT, viewableItemsMap);
    }, []);

    final handleRefresh = useCallback(() async {
      refreshing.value = true;
      await fetchPinnedPosts(serverUrl, channelId);
      refreshing.value = false;
    }, [serverUrl, channelId]);

    final emptyList = useMemo(() {
      return Center(
        child: loading.value
            ? Loading(color: theme.buttonBg, size: 'large')
            : EmptyState(),
      );
    }, [loading.value, theme.buttonBg]);

    final renderItem = useCallback((item) {
      switch (item.type) {
        case 'date':
          return DateSeparator(
            key: item.value,
            date: getDateForDateLine(item.value),
            timezone: currentTimezone,
          );
        case 'post':
          return Post(
            appsEnabled: appsEnabled,
            customEmojiNames: customEmojiNames,
            highlightPinnedOrSaved: false,
            isCRTEnabled: isCRTEnabled,
            location: Screens.PINNED_MESSAGES,
            key: item.value.currentPost.id,
            nextPost: null,
            post: item.value.currentPost,
            previousPost: null,
            showAddReaction: false,
            shouldRenderReplyButton: false,
            skipSavedHeader: true,
            skipPinnedHeader: true,
            testID: 'pinned_messages.post_list.post',
          );
        default:
          return null;
      }
    }, [appsEnabled, currentTimezone, customEmojiNames, theme]);

    return SafeArea(
      child: Scaffold(
        body: Column(
          children: [
            Expanded(
              child: data.isNotEmpty
                  ? ListView.builder(
                      itemCount: data.length,
                      itemBuilder: (context, index) {
                        return renderItem(data[index]);
                      },
                    )
                  : emptyList,
            ),
          ],
        ),
      ),
    );
  }
}
