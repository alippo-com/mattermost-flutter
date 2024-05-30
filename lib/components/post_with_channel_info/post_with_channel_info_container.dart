// Dart Code
// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:watermelon_db/watermelon_db.dart';

import 'package:mattermost_flutter/queries/servers/post.dart';
import 'package:mattermost_flutter/components/post_with_channel_info/post_with_channel_info.dart';

import 'package:mattermost_flutter/types/database/models/servers/post.dart';

class OwnProps {
  final PostModel post;
  final bool skipSavedPostsHighlight;
  final Database database;

  OwnProps({
    required this.post,
    this.skipSavedPostsHighlight = false,
    required this.database,
  });
}

class PostWithChannelInfoContainer extends StatelessWidget {
  final OwnProps ownProps;

  PostWithChannelInfoContainer({required this.ownProps});

  @override
  Widget build(BuildContext context) {
    final isCRTEnabled = observeIsCRTEnabled(ownProps.database);
    final isSaved = ownProps.skipSavedPostsHighlight
        ? Observable.just(false)
        : observePostSaved(ownProps.database, ownProps.post.id);

    return PostWithChannelInfo(
      isCRTEnabled: isCRTEnabled,
      isSaved: isSaved,
    );
  }
}
