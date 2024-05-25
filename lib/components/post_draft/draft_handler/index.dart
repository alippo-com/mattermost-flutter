import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mattermost_flutter/constants/post_draft.dart';
import 'package:mattermost_flutter/queries/servers/system.dart';
import 'package:mattermost_flutter/types/database/database.dart';
import 'package:mattermost_flutter/components/post_draft/draft_handler.dart';

class DraftHandlerProvider extends StatelessWidget {
  final Widget child;

  DraftHandlerProvider({required this.child});

  @override
  Widget build(BuildContext context) {
    final database = Provider.of<Database>(context);
    final canUploadFiles = observeCanUploadFiles(database);
    final maxFileSize = observeConfigIntValue(database, 'MaxFileSize', DEFAULT_SERVER_MAX_FILE_SIZE);
    final maxFileCount = observeMaxFileCount(database);

    return MultiProvider(
      providers: [
        StreamProvider.value(
          value: canUploadFiles,
          initialData: false,
        ),
        StreamProvider.value(
          value: maxFileSize,
          initialData: DEFAULT_SERVER_MAX_FILE_SIZE,
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
          title: Text('Draft Handler'),
        ),
        body: DraftHandlerProvider(
          child: DraftHandler(),
        ),
      ),
    );
  }
}
