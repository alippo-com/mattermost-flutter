// Converted from ./mattermost-mobile/app/utils/files.tsx

import 'package:mattermost_flutter/utils/gallery.dart';
import '../types/database/models/servers/channel.dart';

int getNumberFileMenuOptions(bool canDownloadFiles, bool publicLinkEnabled) {
  int numberItems = 1;
  numberItems += canDownloadFiles ? 1 : 0;
  numberItems += publicLinkEnabled ? 1 : 0;
  return numberItems;
}

Map<String, String?> getChannelNamesWithID(List<ChannelModel> fileChannels) {
  return fileChannels.fold<Map<String, String?>>({}, (acc, v) {
    acc[v.id] = v.displayName;
    return acc;
  });
}

List<FileInfo> getOrderedFileInfos(List<FileInfo> fileInfos) {
  fileInfos.sort((a, b) => (b.createAt ?? 0) - (a.createAt ?? 0));
  return fileInfos;
}

Map<String, int?> getFileInfosIndexes(List<FileInfo> orderedFilesForGallery) {
  return orderedFilesForGallery.asMap().map((idx, v) => MapEntry(v.id, idx));
}

List<GalleryItemType> getOrderedGalleryItems(List<FileInfo> orderedFileInfos) {
  return orderedFileInfos.map((f) => fileToGalleryItem(f, f.userId)).toList();
}

String pathWithPrefix(String prefix, String path) {
  final p = path.startsWith(prefix) ? '' : prefix;
  return '$p$path';
}
