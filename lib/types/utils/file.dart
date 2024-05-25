// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'file_info.dart';

abstract class ExtractedFileInfo implements Partial<FileInfo> {
  final String name;
  final String mimeType;

  const ExtractedFileInfo({this.name, this.mimeType});
}

typedef UploadExtractedFile = Function(List<ExtractedFileInfo>? files);