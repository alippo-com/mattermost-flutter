import 'package:flutter/material.dart';
import 'package:mattermost_flutter/types/database.dart';
import 'package:mattermost_flutter/types/observables.dart';
import 'document_renderer.dart';

class DocumentRendererContainer extends StatelessWidget {
  final bool canDownloadFiles;

  DocumentRendererContainer({required this.canDownloadFiles});

  @override
  Widget build(BuildContext context) {
    return DocumentRenderer(canDownloadFiles: canDownloadFiles);
  }
}

Stream<bool> observeCanDownloadFiles(Database database) async* {
  yield await SystemQueries.observeCanDownloadFiles(database);
}

class EnhancedDocumentRenderer extends StatelessWidget {
  final Database database;

  EnhancedDocumentRenderer({required this.database});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: observeCanDownloadFiles(database),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        }
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }
        return DocumentRendererContainer(canDownloadFiles: snapshot.data ?? false);
      },
    );
  }
}
