
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:mattermost_flutter/types/database/models/servers/file.dart';
import 'package:mattermost_flutter/types/database/models/servers/post.dart';
import 'package:mattermost_flutter/queries/servers/file.dart';
import 'package:mattermost_flutter/queries/servers/system.dart';
import 'package:mattermost_flutter/utils/file.dart';
import 'package:mattermost_flutter/components/files.dart';

class EnhanceProps {
  final Database database;
  final PostModel post;

  EnhanceProps({required this.database, required this.post});
}

Future<List<FileInfo>> filesLocalPathValidation(List<FileModel> files, String authorId) async {
  List<FileInfo> filesInfo = [];
  for (var file in files) {
    var info = file.toFileInfo(authorId);
    if (info.localPath != null) {
      var exists = await fileExists(info.localPath!);
      if (!exists) {
        info.localPath = null;
      }
    }
    filesInfo.add(info);
  }
  return filesInfo;
}

class EnhancedFiles extends StatelessWidget {
  final EnhanceProps enhanceProps;

  EnhancedFiles({required this.enhanceProps});

  @override
  Widget build(BuildContext context) {
    final post = enhanceProps.post;
    final database = enhanceProps.database;
    final publicLinkEnabled = observeConfigBooleanValue(database, 'EnablePublicLink').asStream();
    final filesInfo = queryFilesForPost(database, post.id).observeWithColumns(['local_path']).switchMap((files) {
      return filesLocalPathValidation(files, post.userId).asStream();
    });

    return Provider.value(
      value: EnhanceProps(database: database, post: post),
      child: Files(),
    );
  }
}
