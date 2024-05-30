
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mattermost_flutter/queries/servers/user.dart';
import 'package:mattermost_flutter/types/database/models/servers/post.dart';
import 'system_message.dart';

class SystemMessageProvider extends StatelessWidget {
  final PostModel post;
  final Widget child;

  SystemMessageProvider({required this.post, required this.child});

  @override
  Widget build(BuildContext context) {
    final database = Provider.of<Database>(context);
    final author = observeUser(database, post.userId);
    final hideGuestTags = observeConfigBooleanValue(database, 'HideGuestTags');

    return MultiProvider(
      providers: [
        StreamProvider.value(
          value: author,
          initialData: null,
        ),
        StreamProvider.value(
          value: hideGuestTags,
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
          title: Text('System Message'),
        ),
        body: SystemMessageProvider(
          post: PostModel(),
          child: SystemMessage(),
        ),
      ),
    );
  }
}
