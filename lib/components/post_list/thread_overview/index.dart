// Dart Code
// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/material.dart';
import 'package:watermelondb/watermelondb.dart';
import 'package:rxdart/rxdart.dart';
import 'package:mattermost_flutter/queries/servers/post.dart';
import 'package:mattermost_flutter/queries/servers/preference.dart';
import 'package:mattermost_flutter/components/thread_overview/thread_overview.dart';
import 'package:mattermost_flutter/types/database/database.dart';

class EnhancedThreadOverview extends StatefulWidget {
  final Database database;
  final String rootId;

  EnhancedThreadOverview({required this.database, required this.rootId});

  @override
  _EnhancedThreadOverviewState createState() => _EnhancedThreadOverviewState();
}

class _EnhancedThreadOverviewState extends State<EnhancedThreadOverview> {
  late Observable<Post> rootPost;
  late Observable<bool> isSaved;
  late Observable<int> repliesCount;

  @override
  void initState() {
    super.initState();
    rootPost = observePost(widget.database, widget.rootId);
    isSaved = querySavedPostsPreferences(widget.database, widget.rootId)
        .observeWithColumns(['value'])
        .switchMap((pref) => Observable.just(pref.first?.value == 'true'));
    repliesCount = queryPostReplies(widget.database, widget.rootId).observeCount(false);
  }

  @override
  Widget build(BuildContext context) {
    return ThreadOverview(
      rootPost: rootPost,
      isSaved: isSaved,
      repliesCount: repliesCount,
    );
  }
}
