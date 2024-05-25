import 'package:mattermost_flutter/types/database/models/servers/file.dart';

bool shouldUpdateFileRecord(FileModel e, FileInfo n) {
  return (n.postId != e.postId) ||
      (n.name != e.name) ||
      (n.extension != e.extension) ||
      (n.size != e.size) ||
      ((n.mimeType ?? '') != e.mimeType) ||
      (n.width != null && n.width != e.width) ||
      (n.height != null && n.height != e.height) ||
      (n.miniPreview != null && n.miniPreview != e.imageThumbnail) ||
      (n.localPath != null && n.localPath != e.localPath);
}
