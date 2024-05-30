import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mattermost_flutter/queries/servers/post.dart';
import 'package:mattermost_flutter/components/post_list/post/avatar/avatar.dart';
import 'package:mattermost_flutter/types/database/models/servers/post.dart';

class PostProvider extends StatelessWidget {
  final PostModel post;
  final Widget child;

  PostProvider({required this.post, required this.child});

  @override
  Widget build(BuildContext context) {
    final database = Provider.of<Database>(context);
    final enablePostIconOverride = observeConfigBooleanValue(database, 'EnablePostIconOverride');
    final author = observePostAuthor(database, post);

    return MultiProvider(
      providers: [
        StreamProvider.value(
          value: author,
          initialData: null,
        ),
        StreamProvider.value(
          value: enablePostIconOverride,
          initialData: false,
        ),
      ],
      child: child,
    );
  }
}

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => Database(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Post Avatar'),
        ),
        body: PostProvider(
          post: PostModel(),
          child: Avatar(),
        ),
      ),
    );
  }
}
