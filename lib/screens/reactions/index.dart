import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:mattermost_flutter/types/database.dart';
import 'package:mattermost_flutter/utils/observables.dart';
import 'package:mattermost_flutter/queries/servers/post.dart';
import 'package:mattermost_flutter/screens/reactions/reactions.dart';

class EnhancedReactions extends StatelessWidget {
  final String postId;

  EnhancedReactions({required this.postId});

  @override
  Widget build(BuildContext context) {
    final database = Provider.of<Database>(context);

    final post = observePost(database, postId);

    final reactions = post.switchMap((p) =>
        p != null ? observeReactionsForPost(database, postId) : Stream.value(null));

    return StreamProvider.value(
      value: reactions,
      initialData: null,
      child: Reactions(),
    );
  }
}
