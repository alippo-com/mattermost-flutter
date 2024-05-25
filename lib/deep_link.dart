// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/material.dart';
import 'package:mattermost_flutter/types/asset.dart';

class QuickActionAttachmentProps {
  bool disabled;
  int? fileCount;
  bool maxFilesReached;
  int maxFileCount;
  Function(List<Asset>) onUploadFiles;
  String? testID;

  QuickActionAttachmentProps({
    required this.disabled,
    this.fileCount,
    required this.maxFilesReached,
    required this.maxFileCount,
    required this.onUploadFiles,
    this.testID,
  });
}
