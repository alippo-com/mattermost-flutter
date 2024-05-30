import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:mattermost_flutter/constants/general.dart';
import 'package:mattermost_flutter/queries/channel.dart';
import 'package:mattermost_flutter/queries/post.dart';
import 'package:mattermost_flutter/queries/system.dart';
import 'package:mattermost_flutter/queries/user.dart';
import 'package:mattermost_flutter/types/gallery.dart';
import 'package:mattermost_flutter/widgets/footer.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';

class FooterProps {
  final Database database;
  final GalleryItemType item;

  FooterProps({required this.database, required this.item});
}

class EnhancedFooter extends HookWidget {
  final FooterProps props;

  EnhancedFooter({required this.props});

  @override
  Widget build(BuildContext context) {
    final database = props.database;
    final item = props.item;

    final post = useStream(useMemoized(
            () => item.postId != null ? observePost(database, item.postId) : Stream.value(null), [database, item.postId]));

    final currentChannelId = useStream(useMemoized(() => observeCurrentChannelId(database), [database]));
    final currentUserId = useStream(useMemoized(() => observeCurrentUserId(database), [database]));

    final teammateNameDisplay = useStream(useMemoized(() => observeTeammateNameDisplay(database), [database]));

    final author = useStream(useMemoized(() => post.stream.switchMap((p) {
      final id = p?.userId ?? item.authorId;
      if (id != null) {
        return observeUser(database, id);
      }
      return Stream.value(null);
    }), [post.stream]));

    final channel = useStream(useMemoized(() => CombineLatestStream.combine2(
        currentChannelId.stream, post.stream, (cId, p) {
      final id = p?.channelId ?? cId;
      return observeChannel(database, id);
    }), [currentChannelId.stream, post.stream]));

    final enablePostUsernameOverride = useStream(useMemoized(
            () => observeConfigBooleanValue(database, 'EnablePostUsernameOverride'), [database]));
    final enablePostIconOverride = useStream(useMemoized(
            () => observeConfigBooleanValue(database, 'EnablePostIconOverride'), [database]));
    final enablePublicLink = useStream(useMemoized(
            () => observeConfigBooleanValue(database, 'EnablePublicLink'), [database]));
    final channelName = useStream(useMemoized(
            () => channel.stream.switchMap((c) => Stream.value(c?.displayName ?? '')), [channel.stream]));
    final isDirectChannel = useStream(useMemoized(
            () => channel.stream.switchMap((c) => Stream.value(c?.type == General.DM_CHANNEL)), [channel.stream]));

    final canDownloadFiles = useStream(useMemoized(() => observeCanDownloadFiles(database), [database]));

    return Footer(
      author: author.data,
      canDownloadFiles: canDownloadFiles.data,
      channelName: channelName.data,
      currentUserId: currentUserId.data,
      enablePostIconOverride: enablePostIconOverride.data,
      enablePostUsernameOverride: enablePostUsernameOverride.data,
      enablePublicLink: enablePublicLink.data,
      isDirectChannel: isDirectChannel.data,
      post: post.data,
      teammateNameDisplay: teammateNameDisplay.data,
    );
  }
}