// Dart Code: ./mattermost_flutter/lib/queries/servers/file.dart

import 'package:nozbe_watermelondb/database.dart';
import 'package:nozbe_watermelondb/queries/where.dart';

import 'package:mattermost_flutter/constants/database.dart';
import 'package:mattermost_flutter/types/database/models/servers/file.dart';

class FileQueries {
  static const String FILE = MM_TABLES['SERVER']['FILE'];

  static Future<FileModel?> getFileById(Database database, String fileId) async {
    try {
      final record = await database.get<FileModel>(FILE).find(fileId);
      return record;
    } catch (e) {
      return null;
    }
  }

  static Query<FileModel> queryFilesForPost(Database database, String postId) {
    return database.get<FileModel>(FILE).query(
      Where('post_id', postId),
    );
  }

  static Stream<List<FileModel>> observeFilesForPost(Database database, String postId) {
    return queryFilesForPost(database, postId).watch();
  }
}
