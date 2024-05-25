
// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:mattermost_flutter/types/file_model.dart';

bool shouldUpdateFileRecord(FileModel e, FileInfo n) {
  return (n.postId != e.postId) ||
         (n.name != e.name) ||
         (n.extension != e.extension) ||
         (n.size != e.size) ||
         ((n.mimeType ?? '') != e.mimeType) ||
         (n.width != null && n.width != e.width) ||
         (n.height != null && n.height != e.height) ||
         (n.imageThumbnail != null && n.imageThumbnail != e.imageThumbnail) ||
         (n.localPath != null && n.localPath != e.localPath);
}
