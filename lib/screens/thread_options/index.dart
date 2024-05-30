import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mattermost_flutter/components/thread_options.dart';
import 'package:mattermost_flutter/utils/database.dart';
import 'package:mattermost_flutter/models/thread_model.dart';
import 'package:mattermost_flutter/queries/post.dart';
import 'package:mattermost_flutter/queries/team.dart';

class ThreadOptionsWrapper extends HookConsumerWidget {
  final ThreadModel thread;

  ThreadOptionsWrapper({required this.thread});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final database = ref.read(databaseProvider);

    final isSaved = useProvider(observePostSavedProvider(database, thread.id));
    final post = useProvider(observePostProvider(database, thread.id));
    final team = useProvider(observeCurrentTeamProvider(database));

    return ThreadOptions(
      isSaved: isSaved,
      post: post,
      team: team,
    );
  }
}