// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:mattermost_flutter/types/asset.dart'; // Assuming a similar structure exists or a Dart equivalent of 'Asset' is defined there.

class QuickActionAttachmentProps {
  final bool disabled;
  final int? fileCount;
  final bool maxFilesReached;
  final int maxFileCount;
  final Function(List<Asset>) onUploadFiles;
  final String? testID;

  QuickActionAttachmentProps({
    required this.disabled,
    this.fileCount,
    required this.maxFilesReached,
    required this.maxFileCount,
    required this.onUploadFiles,
    this.testID,
  });
}