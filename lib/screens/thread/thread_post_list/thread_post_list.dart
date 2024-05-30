import 'package:flutter/material.dart';

// Placeholder: Replace these with actual database query implementations
import 'package:mattermost_flutter/database/queries.dart';
import 'package:mattermost_flutter/models/post_model.dart';
import 'package:mattermost_flutter/models/channel_model.dart';
import 'package:mattermost_flutter/models/thread_model.dart';

class ThreadPostList extends StatefulWidget {
  final PostModel rootPost;

  const ThreadPostList({required this.rootPost});

  @override
  _ThreadPostListState createState() => _ThreadPostListState();
}

class _ThreadPostListState extends State<ThreadPostList> {
  late Stream<bool> isCRTEnabled;
  late Stream<DateTime?> channelLastViewedAt;
  late Stream<List<PostModel>> posts;
  late Stream<String?> teamId;
  late Stream<ThreadModel?> thread;
  late Stream<String?> version;

  @override
  void initState() {
    super.initState();
    final database = getDatabase(); // Placeholder for getting the database

    isCRTEnabled = observeIsCRTEnabled(database);
    channelLastViewedAt = observeMyChannel(database, widget.rootPost.channelId)
        .switchMap((myChannel) => Stream.value(myChannel?.viewedAt));
    posts = queryPostsInThread(database, widget.rootPost.id, true, true)
        .switchMap((postsInThread) {
      if (postsInThread.isEmpty) {
        return Stream.value([]);
      }

      final earliest = postsInThread[0].earliest;
      final latest = postsInThread[0].latest;
      return queryPostsChunk(database, widget.rootPost.id, earliest, latest, true);
    });
    teamId = observeChannel(database, widget.rootPost.channelId)
        .switchMap((channel) => Stream.value(channel?.teamId));
    thread = observeThreadById(database, widget.rootPost.id);
    version = observeConfigValue(database, 'Version');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Thread Post List'),
      ),
      body: StreamBuilder<List<PostModel>>(
        stream: posts,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No posts available'));
          } else {
            final posts = snapshot.data!;
            return ListView.builder(
              itemCount: posts.length,
              itemBuilder: (context, index) {
                final post = posts[index];
                return ListTile(
                  title: Text(post.message),
                  subtitle: Text(post.userId),
                );
              },
            );
          }
        },
      ),
    );
  }
}
