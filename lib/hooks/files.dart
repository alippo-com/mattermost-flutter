// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:mattermost_flutter/utils/file.dart';
import 'package:mattermost_flutter/context/server.dart';
import 'package:mattermost_flutter/actions/remote/file.dart';
import 'package:mattermost_flutter/types/file_info.dart';

class ImageAttachments {
  final List<FileInfo> images;
  final List<FileInfo> nonImages;

  ImageAttachments(this.images, this.nonImages);
}

ImageAttachments useImageAttachments(List<FileInfo> filesInfo, bool publicLinkEnabled) {
  final String serverUrl = useServerUrl();
  List<FileInfo> images = [];
  List<FileInfo> nonImages = [];

  for (var file in filesInfo) {
    bool imageFile = isImage(file);
    bool videoFile = isVideo(file);
    String uri;

    if (imageFile || (videoFile && publicLinkEnabled)) {
      if (file.localPath != null) {
        uri = file.localPath!;
      } else {
        uri = (isGif(file) || videoFile) ? buildFileUrl(serverUrl, file.id!) : buildFilePreviewUrl(serverUrl, file.id!);
      }
      images.add(file.copyWith(uri: uri));
    } else {
      uri = file.uri;
      if (videoFile) {
        uri = buildFileUrl(serverUrl, file.id!);
      }
      nonImages.add(file.copyWith(uri: uri));
    }
  }

  return ImageAttachments(images, nonImages);
}
