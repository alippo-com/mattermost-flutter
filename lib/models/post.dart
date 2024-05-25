import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class Post {
  static const String tableName = 'Post';
  static const String channelId = 'channel_id';
  static const String createAt = 'create_at';
  static const String deleteAt = 'delete_at';
  static const String editAt = 'edit_at';
  static const String isPinned = 'is_pinned';
  static const String message = 'message';
  static const String messageSource = 'message_source';
  static const String metadata = 'metadata';
  static const String originalId = 'original_id';
  static const String pendingPostId = 'pending_post_id';
  static const String previousPostId = 'previous_post_id';
  static const String props = 'props';
  static const String rootId = 'root_id';
  static const String type = 'type';
  static const String updateAt = 'update_at';
  static const String userId = 'user_id';

  static Future<Database> getDatabase() async {
    final dbPath = await getDatabasesPath();
    return openDatabase(
      join(dbPath, 'mattermost.db'),
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE $tableName('
          '$channelId TEXT, '
          '$createAt INTEGER, '
          '$deleteAt INTEGER, '
          '$editAt INTEGER, '
          '$isPinned INTEGER, '
          '$message TEXT, '
          '$messageSource TEXT, '
          '$metadata TEXT, '
          '$originalId TEXT, '
          '$pendingPostId TEXT, '
          '$previousPostId TEXT, '
          '$props TEXT, '
          '$rootId TEXT, '
          '$type TEXT, '
          '$updateAt INTEGER, '
          '$userId TEXT'
          ')',
        );
      },
      version: 1,
    );
  }
}