import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mattermost_flutter/queries/servers/post.dart';
import 'package:mattermost_flutter/components/post_draft/quick_actions/quick_actions.dart';

class QuickActionsProvider extends StatelessWidget {
  final Widget child;

  QuickActionsProvider({required this.child});

  @override
  Widget build(BuildContext context) {
    final database = Provider.of<Database>(context);
    final canUploadFiles = observeCanUploadFiles(database);
    final isPostPriorityEnabled = observeIsPostPriorityEnabled(database);
    final maxFileCount = observeMaxFileCount(database);

    return MultiProvider(
      providers: [
        StreamProvider.value(
          value: canUploadFiles,
          initialData: false,
        ),
        StreamProvider.value(
          value: isPostPriorityEnabled,
          initialData: false,
        ),
        StreamProvider.value(
          value: maxFileCount,
          initialData: 0,
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
          title: Text('Quick Actions'),
        ),
        body: QuickActionsProvider(
          child: QuickActions(),
        ),
      ),
    );
  }
}
