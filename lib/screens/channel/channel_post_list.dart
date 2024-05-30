
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:provider/provider.dart';
import 'package:mattermost_flutter/actions/remote/channel.dart';
import 'package:mattermost_flutter/actions/remote/post.dart';
import 'package:mattermost_flutter/components/post_list.dart';
import 'package:mattermost_flutter/constants.dart';
import 'package:mattermost_flutter/context/server.dart';
import 'package:mattermost_flutter/hooks/did_update.dart';
import 'package:mattermost_flutter/store/ephemeral_store.dart';
import 'package:mattermost_flutter/utils/debounce.dart';
import 'package:mattermost_flutter/utils/log.dart';
import 'package:mattermost_flutter/utils/navigation.dart';
import 'package:mattermost_flutter/utils/theme.dart';
import 'package:mattermost_flutter/screens/channel/intro.dart';

class ChannelPostList extends HookWidget {
  final String channelId;
  final BoxDecoration? contentContainerStyle;
  final bool isCRTEnabled;
  final int lastViewedAt;
  final String nativeID;
  final List<PostModel> posts;
  final bool shouldShowJoinLeaveMessages;

  ChannelPostList({
    required this.channelId,
    this.contentContainerStyle,
    required this.isCRTEnabled,
    required this.lastViewedAt,
    required this.nativeID,
    required this.posts,
    required this.shouldShowJoinLeaveMessages,
  });

  @override
  Widget build(BuildContext context) {
    final appState = useAppState();
    final isTablet = useIsTablet();
    final serverUrl = Provider.of<ServerUrl>(context);
    final canLoadPostsBefore = useRef(true);
    final canLoadPost = useRef(true);
    final fetchingPosts = useState(EphemeralStore.isLoadingMessagesForChannel(serverUrl, channelId));
    final oldPostsCount = useRef(posts.length);

    final onEndReached = useCallback(debounce(() async {
      if (!fetchingPosts.value && canLoadPostsBefore.current && posts.isNotEmpty) {
        final lastPost = posts.last;
        final result = await fetchPostsBefore(serverUrl, channelId, lastPost.id);
        canLoadPostsBefore.current = false;
        if (result.posts.isNotEmpty) {
          canLoadPostsBefore.current = result.posts.length > 0;
        }
      }
    }, 500), [fetchingPosts.value, serverUrl, channelId, posts]);

    useDidUpdate(() {
      fetchingPosts.value = EphemeralStore.isLoadingMessagesForChannel(serverUrl, channelId);
    }, [serverUrl, channelId]);

    useEffect(() {
      final listener = DeviceEventEmitter.addListener(Events.LOADING_CHANNEL_POSTS, (event) {
        if (event.serverUrl == serverUrl && event.channelId == channelId) {
          fetchingPosts.value = event.value;
        }
      });

      return () => listener.remove();
    }, [serverUrl, channelId]);

    useEffect(() {
      if (!fetchingPosts.value && canLoadPost.current && posts.length < PER_PAGE_DEFAULT) {
        canLoadPost.current = false;
        fetchPosts(serverUrl, channelId);
      }
    }, [fetchingPosts.value, posts]);

    useEffect(() {
      if (oldPostsCount.current < posts.length && appState == AppLifecycleState.resumed) {
        oldPostsCount.current = posts.length;
        markChannelAsRead(serverUrl, channelId, true);
      }
    }, [isCRTEnabled, posts, channelId, serverUrl, appState == AppLifecycleState.resumed]);

    final intro = Intro(channelId: channelId);

    final postList = PostList(
      channelId: channelId,
      contentContainerStyle: BoxDecoration(
        color: isCRTEnabled ? null : Colors.transparent,
      ).copyWith(contentContainerStyle),
      isCRTEnabled: isCRTEnabled,
      footer: intro,
      lastViewedAt: lastViewedAt,
      location: Screens.CHANNEL,
      nativeID: nativeID,
      onEndReached: onEndReached,
      posts: posts,
      shouldShowJoinLeaveMessages: shouldShowJoinLeaveMessages,
      showMoreMessages: true,
      testID: 'channel.post_list',
    );

    if (isTablet) {
      return postList;
    }

    return SafeArea(
      child: Container(
        decoration: BoxDecoration(color: Colors.white),
        child: postList,
      ),
    );
  }
}
