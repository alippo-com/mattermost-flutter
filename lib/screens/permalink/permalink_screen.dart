// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';

import 'package:mattermost_flutter/database/database.dart';
import 'package:mattermost_flutter/queries/channel.dart';
import 'package:mattermost_flutter/queries/post.dart';
import 'package:mattermost_flutter/queries/system.dart';
import 'package:mattermost_flutter/queries/team.dart';
import 'package:mattermost_flutter/queries/thread.dart';

import 'permalink.dart';

class PermalinkScreen extends StatelessWidget {
  final String postId;
  final String? teamName;

  PermalinkScreen({required this.postId, this.teamName});

  @override
  Widget build(BuildContext context) {
    final database = Provider.of<Database>(context);

    final postStream = observePost(database, postId);
    final teamStream = teamName != null
        ? queryTeamByName(database, teamName!).asStream().switchMap((ts) {
            final t = ts.isNotEmpty ? ts.first : null;
            return t != null ? t.observe().asStream() : Stream.value(null);
          })
        : Stream.value(null);

    final channelStream = postStream.switchMap((p) =>
        p != null ? observeChannel(database, p.channelId).asStream() : Stream.value(null));
    final rootIdStream = postStream.switchMap((p) => Stream.value(p?.rootId));
    final isTeamMemberStream = teamStream.switchMap((t) => t != null
        ? queryMyTeamsByIds(database, [t.id])
            .asStream()
            .switchMap((ms) => Stream.value(ms.isNotEmpty))
        : Stream.value(false));
    final currentTeamIdStream = observeCurrentTeamId(database).asStream();
    final isCRTEnabledStream = observeIsCRTEnabled(database).asStream();

    return StreamBuilder(
      stream: CombineLatestStream.list([
        channelStream,
        rootIdStream,
        isTeamMemberStream,
        currentTeamIdStream,
        isCRTEnabledStream,
      ]),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return CircularProgressIndicator();
        }

        final data = snapshot.data as List<dynamic>;
        final channel = data[0];
        final rootId = data[1];
        final isTeamMember = data[2];
        final currentTeamId = data[3];
        final isCRTEnabled = data[4];

        return Permalink(
          channel: channel,
          rootId: rootId,
          isTeamMember: isTeamMember,
          currentTeamId: currentTeamId,
          isCRTEnabled: isCRTEnabled,
        );
      },
    );
  }
}
