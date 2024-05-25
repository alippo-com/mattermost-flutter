import 'package:flutter/material.dart';
import 'package:mattermost_flutter/constants/post_draft.dart';
import 'package:mattermost_flutter/queries/servers/file.dart';
import 'package:mattermost_flutter/queries/servers/system.dart';
import 'package:mattermost_flutter/screens/edit_post/edit_post.dart';

class EditPostScreen extends StatelessWidget {
  final Database database;
  final PostModel post;

  const EditPostScreen({
    Key? key,
    required this.database,
    required this.post,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<int>(
      stream: observeConfigIntValue(database, 'MaxPostSize', MAX_MESSAGE_LENGTH_FALLBACK),
      builder: (context, maxPostSizeSnapshot) {
        if (!maxPostSizeSnapshot.hasData) {
          return CircularProgressIndicator();
        }

        return StreamBuilder<bool>(
          stream: observeFilesForPost(database, post.id).map((files) => files.length > 0),
          builder: (context, hasFilesAttachedSnapshot) {
            if (!hasFilesAttachedSnapshot.hasData) {
              return CircularProgressIndicator();
            }

            return EditPost(
              maxPostSize: maxPostSizeSnapshot.data,
              hasFilesAttached: hasFilesAttachedSnapshot.data,
            );
          },
        );
      },
    );
  }
}

Stream<int> observeConfigIntValue(Database database, String key, int fallback) {
  // Implement the logic to observe an integer configuration value
}

Stream<List<File>> observeFilesForPost(Database database, String postId) {
  // Implement the logic to observe files for a post
}
