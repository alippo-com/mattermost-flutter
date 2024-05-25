// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:watermelondb/watermelondb.dart';
import 'package:watermelondb/Relation.dart';
import 'package:mattermost_flutter/types/database/models/servers/post.dart';

class FileModel extends Model {
  static final table = 'File';

  static final associations = {
    'post': 'belongs_to',
  };

  String extension;
  int height;
  String imageThumbnail;
  String? localPath;
  String mimeType;
  String name;
  String postId;
  int size;
  int width;
  Relation<PostModel> post;

  FileModel({
    required this.extension,
    required this.height,
    required this.imageThumbnail,
    this.localPath,
    required this.mimeType,
    required this.name,
    required this.postId,
    required this.size,
    required this.width,
    required this.post,
  });

  FileInfo toFileInfo(String authorId) {
    // Implement the conversion logic to FileInfo here
  }
}
